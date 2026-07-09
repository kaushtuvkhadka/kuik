#include "archiveapi.h"
#include "constants.h"
#include <QUrlQuery>
#include <QUrl>
#include <QNetworkRequest>
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>



//Helpers ------Archive ko resource bata url lai build garxa,  These 2
QString ArchiveAPI::posterUrl(const QString &id) {
    // Thumbnail create
return ArchiveConstants::kBaseUrl + ArchiveConstants::kPosterImagePath.arg(id);}


QString ArchiveAPI::streamUrl(const QString &id, const QString &filename) {   //Direct vidoe file ko url create, .mp4 jasto
return ArchiveConstants::kBaseUrl + ArchiveConstants::kDownloadPath.arg(id, filename);}


//Blocking words
bool ArchiveAPI::Block(const QString &text){
    QString t = text.toLower();

    if (t.isEmpty())
        return false;

        //blocked/ignore words haru
    return t.contains("sex") ||
           t.contains("sexual") ||
           t.contains("adult") ||
           t.contains("nude") ||
           t.contains("nudist") ||
           t.contains("molester") ||
           t.contains("xxx");
}


//Best quality lai pick garxa
QString ArchiveAPI::bestMp4(const QJsonArray &files, const QString &id) {
    QString best512, bestMp4, bestAny;

    for (const QJsonValue &v : files) {
        QJsonObject f = v.toObject();
        QString name = f["name"].toString();
        QString fmt  = f["format"].toString().toLower();
        QString lname = name.toLower();

        if (!lname.endsWith(".mp4")) continue;


        // Thuloooooooo vid lai skip garxa
        if (lname.contains("orig")) continue;

        if (lname.contains("512kb") || lname.contains("512") ) {
            best512 = name;
        } else if (fmt.contains("h.264") || fmt.contains("mpeg4") || fmt.contains("mp4")) {
            if (bestMp4.isEmpty()) bestMp4 = name;
        } else {
            if (bestAny.isEmpty()) bestAny = name;
        }
    }

    QString chosen = !best512.isEmpty() ? best512          //best select
                   : !bestMp4.isEmpty() ? bestMp4
                   : bestAny;

    if (chosen.isEmpty()) return QString();
    return streamUrl(id, chosen);                           // actual streaming URL build garxa
}



//Http request garne, need to check
ArchiveAPI::ArchiveAPI(QObject *parent) : QObject(parent) {
    net = new QNetworkAccessManager(this);
}



//recommandation ko lagi, iniital view when loading the app
void ArchiveAPI::fetchCurated() {
    emit loadingChanged(true);

QUrl url(ArchiveConstants::kBaseUrl + ArchiveConstants::kAdvancedSearchPath);
QUrlQuery q;


    // Downloads according, movies haru lai fetch garxa, top 10/20 bhanya jasto
   q.addQueryItem("q", ArchiveConstants::kCuratedQueryFilter);    //adult tag bhako file lai neglect garxa
    q.addQueryItem("fl[]", "identifier");
    q.addQueryItem("fl[]", "title");
    q.addQueryItem("fl[]", "year");
    q.addQueryItem("fl[]", "subject");
    q.addQueryItem("fl[]", "description");
    q.addQueryItem("fl[]", "downloads");
    q.addQueryItem("sort[]", "downloads desc");
    q.addQueryItem("rows",  QString::number(ArchiveConstants::kCuratedResultRows));                //kati ota fetch garne
    q.addQueryItem("page",  "1");
    q.addQueryItem("output","json");

    url.setQuery(q);                                            //chosen bata url build

    QNetworkReply *reply = net->get(QNetworkRequest(url));
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {                        //htp request
        onSearchReply(reply, true);
        qDebug() << "Top movies fetch";
    });
}


// Search user bata
void ArchiveAPI::search(const QString &query) {
    if (query.trimmed().isEmpty()) return;                          //No action
    emit loadingChanged(true);                                      //Load bhairako dekhauxa

QUrl url(ArchiveConstants::kBaseUrl + ArchiveConstants::kAdvancedSearchPath);
QUrlQuery q;


    //Video aaune marta banako
   QString qStr = ArchiveConstants::kSearchQueryTemplate.arg(query.trimmed());      //featured matra dekhauxa
    q.addQueryItem("q",      qStr);
    q.addQueryItem("fl[]",   "identifier");
    q.addQueryItem("fl[]",   "title");
    q.addQueryItem("fl[]",   "year");
    q.addQueryItem("fl[]",   "subject");
    q.addQueryItem("fl[]",   "description");
    q.addQueryItem("fl[]",   "downloads");
    q.addQueryItem("sort[]", "downloads desc");
q.addQueryItem("rows",   QString::number(ArchiveConstants::kSearchResultRows));
    q.addQueryItem("page",   "1");
    q.addQueryItem("output", "json");

    url.setQuery(q);

    QNetworkReply *reply = net->get(QNetworkRequest(url));                                  //File request hunxa
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        onSearchReply(reply, false);
        qDebug() << "Search result";
    });
}



//Search function call
void ArchiveAPI::onSearchReply(QNetworkReply *reply, bool isCurated) {
    reply->deleteLater();

    qDebug() << "\nMain call/initiate";

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



//Error checck hunxa ani json parse, if error aayo bhane result aaudaina natra url build hunxaS
QVariantList ArchiveAPI::parseSearchResponse(const QJsonDocument &doc) {
    QVariantList result;

    QJsonObject root   = doc.object();
    QJsonObject resp   = root["response"].toObject();
    QJsonArray  docs   = resp["docs"].toArray();



    //Details haru fetch garxa, title, desc, genre.....
    for (const QJsonValue &v : docs) {
        QJsonObject item = v.toObject();
        QString id = item["identifier"].toString();

            if (id.isEmpty()) continue;

            QString title = item["title"].toString();

            // strig ra array both
            QString genre;

            QJsonValue subj = item["subject"];

            if (subj.isArray()) {
                QStringList parts;
                    for (const auto &s : subj.toArray())
                        parts << s.toString();

                genre = parts.first();
            }
            else {
                genre = subj.toString().split(";").first().trimmed();
            }

            if (genre.isEmpty()) genre = "Film";


            //string ne huna sakxa, array ne
            QString desc;
            QJsonValue dv = item["description"];
            if (dv.isArray()) desc = dv.toArray().first().toString();
            else              desc = dv.toString();

            // Description 300 character bhanda badhi xa bhane cut gardinxa
            if (desc.length() > 300) desc = desc.left(300) + "...";



            //Block/Ignore garxa if blocked word xa bhbane-------------------Print remove kaam bhayepaxi
            if (Block(title) || Block(genre) || Block(desc)) {
                int i = 1;
                qDebug() << "Block  " << i << "\n";
                i++;
                continue;
            }

            QVariantMap m;
            m["identifier"]  = id;
            m["title"]       = title;
            m["year"]        = item["year"].toString();
            m["genre"]       = genre;
            m["description"] = desc;
            m["poster_url"]  = posterUrl(id);
            m["video_url"]   = "";
            m["rating"]      = QString::number(
                                   qMin(9.9, (item["downloads"].toDouble() / 50000.0) * 8.0 + 5.0),
                                   'f', 1);

            result.append(m);
        }

    return result;
}



//file find garxa ani play, best quality haru choose hunxa
void ArchiveAPI::resolveVideoUrls(QVariantList partials, bool isCurated) {
    int total = partials.size();
    pendingResolutions = total;


    auto resolved = std::make_shared<QVariantList>();
    auto pending  = std::make_shared<int>(total);

    for (const QVariant &v : partials) {
        QVariantMap movie = v.toMap();
        QString id = movie["identifier"].toString();

QUrl url(ArchiveConstants::kBaseUrl + ArchiveConstants::kMetadataPath.arg(id));
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
