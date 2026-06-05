#include "InternetArchive.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <curl/curl.h>

#define log qDebug()

// curl needs this to collect response data
static size_t writeCallback(void *contents, size_t size, size_t nmemb, std::string *output) {
    output->append((char *)contents, size * nmemb);
    return size * nmemb;
}

InternetArchive::InternetArchive(QObject *parent) : QObject(parent) {}

// sends HTTP GET request, returns response as string
std::string InternetArchive::curlGet(const std::string &url) {
    CURL *curl = curl_easy_init();
    std::string response;
    if (curl) {
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &response);
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 15L);

        CURLcode res = curl_easy_perform(curl);

        if (res != CURLE_OK) {
            qDebug() << "curl error:" << curl_easy_strerror(res);
        }

        curl_easy_cleanup(curl);
    }
    return response;
}

// searches archive.org and fills recommendations list
void InternetArchive::fetch(const QString &query) {
    std::string url = ("https://archive.org/advancedsearch.php?q=" + query + "+mediatype:movies&fl=identifier&fl=title&fl=year&rows=5&output=json").toStdString();

    qDebug() << "fetching URL:" << QString::fromStdString(url);

    std::string raw = curlGet(url);
    QJsonDocument doc = QJsonDocument::fromJson(QByteArray::fromStdString(raw));
    QJsonArray items = doc["response"]["docs"].toArray();

    QVariantList results;
    for (const QJsonValue &item : items) {
        QVariantMap movie;
        movie["title"]      = item["title"].toString();
        movie["year"]       = item["year"].toString();
        movie["identifier"] = item["identifier"].toString();
        movie["poster_url"] = "https://archive.org/services/img/" + item["identifier"].toString();
        movie["video_url"]  = "";
        movie["genre"]      = "";
        movie["rating"]     = 0.0;
        movie["description"] = "";
        results.append(movie);
    }

    m_recommendations = results;
    qDebug() << "fetch result count:" << results.size();

    qDebug() << "||";
    emit recommendationsChanged();
}

// gets direct mp4 url for a given identifier
QString InternetArchive::getVideoUrl(const QString &identifier) {
    log << identifier;
    std::string url = "https://archive.org/metadata/" + identifier.toStdString();
    std::string raw = curlGet(url);

    log << raw;

    QJsonDocument doc = QJsonDocument::fromJson(QByteArray::fromStdString(raw));
    QJsonArray files = doc["files"].toArray();

    log << files;

    for (const QJsonValue &file : files) {
        QString name = file["name"].toString();
        if (name.endsWith(".mp4")) {
            return "https://archive.org/download/" + identifier + "/" + name;
        }
    }
    return "";
}