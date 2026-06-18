#include "archiveapi.h"
#include <QUrlQuery>
#include <QUrl>
#include <QNetworkRequest>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>
#include <QStandardPaths>
#include <QFileInfo>
#include <QDir>
#include <QFile>

QString ArchiveAPI::posterUrl(const QString &id) {
    return QString("https://archive.org/services/img/%1").arg(id);
}

// Fixed: Removed ArchiveAPI:: call prefix within class definition context
QString ArchiveAPI::streamUrl(const QString &id, const QString &filename) {
    return QString("https://archive.org/download/%1/%2").arg(id, filename);
}

QString ArchiveAPI::bestMp4(const QJsonArray &files, const QString &id) {
    QString best512, bestMp4, bestAny;

    for (const QJsonValue &v : files) {
        QJsonObject f = v.toObject();
        QString name = f["name"].toString();
        QString fmt  = f["format"].toString().toLower();
        QString lname = name.toLower();

        if (!lname.endsWith(".mp4")) continue;
        if (lname.contains("orig")) continue;

        if (lname.contains("512kb") || lname.contains("512") ) {
            best512 = name;
        } else if (fmt.contains("h.264") || fmt.contains("mpeg4") || fmt.contains("mp4")) {
            if (bestMp4.isEmpty()) bestMp4 = name;
        } else {
            if (bestAny.isEmpty()) bestAny = name;
        }
    }

    QString chosen = !best512.isEmpty() ? best512
                     : !bestMp4.isEmpty() ? bestMp4
                                          : bestAny;

    if (chosen.isEmpty()) return QString();
    return streamUrl(id, chosen);
}

ArchiveAPI::ArchiveAPI(QObject *parent) : QObject(parent) {
    net = new QNetworkAccessManager(this);
}
void ArchiveAPI::startDownload(QString url) {
    if (url.isEmpty()) {
        qWarning() << "Download URL is empty.";
        return;
    }

    qDebug() << "Download initiated for URL:" << url;

    QUrl qurl(url);
    QString fileName = QFileInfo(qurl.path()).fileName();
    if (fileName.isEmpty()) {
        fileName = "downloaded_video.mp4";
    }

    // --- SYSTEM VIDEOS LOCATION LOGIC ---
    // QStandardPaths::MoviesLocation targets the OS user's default Videos folder
    QString standardVideoDir = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation);
    QString targetDirPath = standardVideoDir + QDir::separator() + "kuik" + QDir::separator() + "downloads";

    // Enforce folder creation on disk if it doesn't exist yet
    QDir dir(targetDirPath);
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    QString fullFilePath = targetDirPath + QDir::separator() + fileName;
    // ------------------------------------

    QFile *localFile = new QFile(fullFilePath, this);
    if (!localFile->open(QIODevice::WriteOnly)) {
        qWarning() << "Failed to open local target file path location:" << fullFilePath;
        delete localFile;
        emit errorOccurred("Failed to save target file to Videos/kuik/downloads destination.");
        return;
    }

    QNetworkRequest request(qurl);
    QNetworkReply *reply = net->get(request);

    // Write network stream buffers progressively as data slices reach the network interface
    connect(reply, &QNetworkReply::readyRead, this, [reply, localFile]() {
        if (localFile->isOpen()) {
            localFile->write(reply->readAll());
        }
    });

    // Handle progress indicator monitoring percentages
    connect(reply, &QNetworkReply::downloadProgress, this, [this](qint64 bytesReceived, qint64 bytesTotal) {
        if (bytesTotal > 0) {
            int percentage = static_cast<int>((bytesReceived * 100) / bytesTotal);
            emit downloadProgress(percentage);
            qDebug() << "Current download lifecycle progress:" << percentage << "%";
        }
    });

    // Close and flush open disk storage objects when download completes
    connect(reply, &QNetworkReply::finished, this, [this, reply, localFile, fullFilePath]() {
        reply->deleteLater();

        if (localFile->isOpen()) {
            localFile->close();
        }
        localFile->deleteLater();

        if (reply->error() == QNetworkReply::NoError) {
            qDebug() << "Download completed successfully. Saved to:" << fullFilePath;
        } else {
            qWarning() << "Download failed:" << reply->errorString();
            QFile::remove(fullFilePath); // Clean up incomplete file fragments
            emit errorOccurred("Download failed: " + reply->errorString());
        }
    });
}
void ArchiveAPI::fetchCurated() {
    emit loadingChanged(true);
    QUrl url("https://archive.org/advancedsearch.php");
    QUrlQuery q;
    q.addQueryItem("q", "collection:feature_films AND mediatype:movies AND -subject:\"adult\"");
    q.addQueryItem("fl[]", "identifier");
    q.addQueryItem("fl[]", "title");
    q.addQueryItem("fl[]", "year");
    q.addQueryItem("fl[]", "subject");
    q.addQueryItem("fl[]", "description");
    q.addQueryItem("fl[]", "downloads");
    q.addQueryItem("sort[]", "downloads desc");
    q.addQueryItem("rows",  "30");
    q.addQueryItem("page",  "1");
    q.addQueryItem("output","json");
    url.setQuery(q);

    QNetworkReply *reply = net->get(QNetworkRequest(url));
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        onSearchReply(reply, true);
    });
}

void ArchiveAPI::search(const QString &query) {
    if (query.trimmed().isEmpty()) return;
    emit loadingChanged(true);

    QUrl url("https://archive.org/advancedsearch.php");
    QUrlQuery q;
    QString qStr = QString("(%1) AND mediatype:movies AND collection:feature_films").arg(query.trimmed());
    q.addQueryItem("q",      qStr);
    q.addQueryItem("fl[]",   "identifier");
    q.addQueryItem("fl[]",   "title");
    q.addQueryItem("fl[]",   "year");
    q.addQueryItem("fl[]",   "subject");
    q.addQueryItem("fl[]",   "description");
    q.addQueryItem("fl[]",   "downloads");
    q.addQueryItem("sort[]", "downloads desc");
    q.addQueryItem("rows",   "20");
    q.addQueryItem("page",   "1");
    q.addQueryItem("output", "json");
    url.setQuery(q);

    QNetworkReply *reply = net->get(QNetworkRequest(url));
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        onSearchReply(reply, false);
    });
}

void ArchiveAPI::onSearchReply(QNetworkReply *reply, bool isCurated) {
    reply->deleteLater();

    if (reply->error() != QNetworkReply::NoError) {
        emit loadingChanged(false);
        emit errorOccurred("Network error: " + reply->errorString());
        return;
    }

    QByteArray data = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(data);

    if (doc.isNull()) {
        emit loadingChanged(false);
        emit errorOccurred("Failed to parse response from Archive.org");
        return;
    }

    QVariantList partials = parseSearchResponse(doc);

    if (partials.isEmpty()) {
        emit loadingChanged(false);
        if (isCurated) emit curatedReady({});
        else           emit searchResultsReady({});
        return;
    }

    resolveVideoUrls(partials, isCurated);
}

QVariantList ArchiveAPI::parseSearchResponse(const QJsonDocument &doc) {
    QVariantList result;
    QJsonObject root   = doc.object();
    QJsonObject resp   = root["response"].toObject();
    QJsonArray  docs   = resp["docs"].toArray();

    for (const QJsonValue &v : docs) {
        QJsonObject item = v.toObject();
        QString id = item["identifier"].toString();
        if (id.isEmpty()) continue;

        QString genre;
        QJsonValue subj = item["subject"];
        if (subj.isArray()) {
            QStringList parts;
            for (const auto &s : subj.toArray())
                parts << s.toString();
            genre = parts.first();
        } else {
            genre = subj.toString().split(";").first().trimmed();
        }
        if (genre.isEmpty()) genre = "Film";

        QString desc;
        QJsonValue dv = item["description"];
        if (dv.isArray()) desc = dv.toArray().first().toString();
        else              desc = dv.toString();

        if (desc.length() > 300) desc = desc.left(300) + "...";

        QVariantMap m;
        m["identifier"]  = id;
        m["title"]       = item["title"].toString();
        m["year"]        = item["year"].toString();
        m["genre"]       = genre;
        m["description"] = desc;
        m["poster_url"]  = posterUrl(id);
        m["video_url"]   = "";
        m["rating"]      = QString::number(qMin(9.9, (item["downloads"].toDouble() / 50000.0) * 8.0 + 5.0), 'f', 1);

        result.append(m);
    }
    return result;
}

void ArchiveAPI::resolveVideoUrls(QVariantList partials, bool isCurated) {
    int total = partials.size();
    pendingResolutions = total;

    auto resolved = std::make_shared<QVariantList>();
    auto pending  = std::make_shared<int>(total);

    for (const QVariant &v : partials) {
        QVariantMap movie = v.toMap();
        QString id = movie["identifier"].toString();

        QUrl url(QString("https://archive.org/metadata/%1").arg(id));
        QNetworkReply *reply = net->get(QNetworkRequest(url));

        connect(reply, &QNetworkReply::finished, this,
                [this, reply, movie, resolved, pending, isCurated]() mutable {
                    reply->deleteLater();

                    if (reply->error() == QNetworkReply::NoError) {
                        QByteArray data = reply->readAll();
                        QJsonDocument doc = QJsonDocument::fromJson(data);
                        if (!doc.isNull()) {
                            QJsonObject root  = doc.object();
                            QJsonArray  files = root["files"].toArray();
                            QString     id    = movie["identifier"].toString();
                            QString     vurl  = bestMp4(files, id);
                            if (!vurl.isEmpty()) {
                                QVariantMap m = movie;
                                m["video_url"] = vurl;
                                resolved->append(m);
                            }
                        }
                    }

                    (*pending)--;
                    if (*pending == 0) {
                        emit loadingChanged(false);
                        if (isCurated) emit curatedReady(*resolved);
                        else           emit searchResultsReady(*resolved);
                    }
                }
                );
    }
}