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
#include <QCoreApplication>


//Archive ko resource bata url lai build garxa,  These 2
QString ArchiveAPI::posterUrl(const QString &id) {
    // Thumbnail create
    return QString("https://archive.org/services/img/%1").arg(id);
}



QString ArchiveAPI::streamUrl(const QString &id, const QString &filename) {   //Direct vidoe file ko url create, .mp4 jasto
    return QString("https://archive.org/download/%1/%2").arg(id, filename);     //Nwtroking include hunna, direct url xa bhane matra play hunxa
}



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
           t.contains("xxx") ||
           t.contains("hentai");
}



//Best quality lai pick garxa
QString ArchiveAPI::bestMp4(const QJsonArray &files, const QString &id) {
    QString best512, bestMp4, bestAny;

    for (const QJsonValue &v : files) {
        QJsonObject f = v.toObject();
        QString name = f["name"].toString();
        QString fmt  = f["format"].toString().toLower();
        QString lname = name.toLower();

        if (!lname.endsWith(".mp4"))
            continue;


        // Thuloooooooo vid lai skip garxa
        if (lname.contains("orig"))
            continue;

        if (lname.contains("512kb") || lname.contains("512") ) {
            best512 = name;
        }
        else if (fmt.contains("h.264") || fmt.contains("mpeg4") || fmt.contains("mp4")) {
            if (bestMp4.isEmpty()) bestMp4 = name;
        }
        else {
            if (bestAny.isEmpty()) bestAny = name;
        }
    }

    QString chosen = !best512.isEmpty() ? best512          //best select
                     : !bestMp4.isEmpty() ? bestMp4
                                          : bestAny;

    if (chosen.isEmpty())
        return QString();
    return streamUrl(id, chosen);                           // actual streaming URL build garxa
}


//Http request garne, need to check
ArchiveAPI::ArchiveAPI(QObject *parent) : QObject(parent) {
    net = new QNetworkAccessManager(this);
    net->setTransferTimeout(20000);                                 //Server lai respond time cap, milisec
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
    QString targetDirPath = QString(PROJECT_ROOT_DIR) + "/downloads";
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
    // Write network stream buffers progressively as data slices
    // reach the network interface
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



//recommandation ko lagi, iniital view when loading the app
void ArchiveAPI::fetchCurated() {
    emit loadingChanged(true);

    QUrl url("https://archive.org/advancedsearch.php");
    QUrlQuery q;


    // Downloads according, movies haru lai fetch garxa, top 10/20 bhanya jasto
    q.addQueryItem("q",
                   "collection:feature_films AND mediatype:movies AND -subject:\"adult\"");     //adult tag bhako file lai neglect garxa
    q.addQueryItem("fl[]", "identifier");
    q.addQueryItem("fl[]", "title");
    q.addQueryItem("fl[]", "year");
    q.addQueryItem("fl[]", "subject");
    q.addQueryItem("fl[]", "description");
    q.addQueryItem("fl[]", "downloads");
    q.addQueryItem("sort[]", "downloads desc");
    q.addQueryItem("rows",  "30");                //kati ota fetch garne
    q.addQueryItem("page",  "1");
    q.addQueryItem("output","json");
    // qDebug() << " Recommendation";
    url.setQuery(q);                                            //chosen bata url build

    QNetworkReply *reply = net->get(QNetworkRequest(url));
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {                        //htp request
        onSearchReply(reply, true);
        qDebug() << "Top movies fetch";
        qDebug() << "--" << reply ;
    });
}


// Search user bata
void ArchiveAPI::search(const QString &query) {
    if (query.trimmed().isEmpty())
        return;                          //No action
    emit loadingChanged(true);                                      //Load bhairako dekhauxa

    QUrl url("https://archive.org/advancedsearch.php");
    QUrlQuery q;


    //Video aaune marta banako
    QString qStr = QString("(%1) AND mediatype:movies AND collection:feature_films")   //featured matra dekhauxa
                       // QString qStr = QString("(%1) AND mediatype:movies")
                       .arg(query.trimmed());

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

    QNetworkReply *reply = net->get(QNetworkRequest(url));                                  //File request hunxa
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        onSearchReply(reply, false);
        qDebug() << "Search result";
    });
}







//Search function call, Start point
void ArchiveAPI::onSearchReply(QNetworkReply *reply, bool isCurated) {
    reply->deleteLater();
    qDebug() << "\nMain call/initiate";
    if (reply->error() != QNetworkReply::NoError) {
        emit loadingChanged(false);

                                                    //Error Message Print Haru
        QString msg;
        if(reply->error() == QNetworkReply::TimeoutError){
            msg = "Server didnt respond. \n Check Internet!!";
        }
        else if(reply->error() == QNetworkReply::HostNotFoundError){
            msg = "No Intenet!!!!!";
        }
        else
            msg = "Network Error. \n" + reply->errorString();
        emit errorOccurred(msg);
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

        if (isCurated)
            emit curatedReady({});
        else
            emit searchResultsReady({});

        return;
    }

    resolveVideoUrls(partials, isCurated ? CuratedRequest : SearchRequest);
}








//******qml ma archiveApi.fetchGenre("<genre>") call huncha upon cliking that genre button, it sends the genre here
void ArchiveAPI::fetchGenre(const QString &genre) {
    if (genre.trimmed().isEmpty())
        return;  //*****if empty stops execution

    emit loadingChanged(true); //loading signal send garcha so ui knows to dispaly loading animation


    QUrl url("https://archive.org/advancedsearch.php");
    QUrlQuery q; //******* for setting values that go after https://archive.org/advancedsearch.php



    //***** -subject: adult le chai adult content lai filter garcha
    QString qStr = QString("subject:(%1) AND mediatype:movies AND collection:feature_films AND -subject:\"adult\"")
                       .arg(genre.trimmed().toLower()); //********** (%1) ko thau ma chai genre lai rakhidincha (%1 = placeholder)
    q.addQueryItem("q",      qStr);
    q.addQueryItem("fl[]",   "identifier");//***** fl = field list, yesle chai server lai yo yo chai pathaunu vanera specify garcha
    q.addQueryItem("fl[]",   "title");
    q.addQueryItem("fl[]",   "year");
    q.addQueryItem("fl[]",   "subject");
    q.addQueryItem("fl[]",   "description");
    q.addQueryItem("fl[]",   "downloads");
    q.addQueryItem("sort[]", "downloads desc"); //****** sort the result by downloads = popular
    q.addQueryItem("rows",   "15"); //******** only first 15 matches dinu vanera magne
    //only use 10 for now, baki 5 as backups, working video format xaina bhane

    q.addQueryItem("page",   "1"); //******* first page matra herne
    q.addQueryItem("output", "json");//****** output chai json format ma mageko

    url.setQuery(q); //** aghi ko base url ma sabbai query lai append garcha

    QNetworkReply *reply = net->get(QNetworkRequest(url));
    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        onGenreReply(reply);
    });
}


void ArchiveAPI::onGenreReply(QNetworkReply *reply) {
    reply->deleteLater();//*****memory leak avoid garna reply lai delete garcha from ram as soon as the function finishes

    if (reply->error() != QNetworkReply::NoError) { //****** if connection timed out load garcha ani error message send garcha
        emit loadingChanged(false);
        emit errorOccurred("Network error: " + reply->errorString());
        return;
    }

    QByteArray data = reply->readAll(); //**** data vanne variable ma sabbai returned info (as text byte) lai store garcha
    QJsonDocument doc = QJsonDocument::fromJson(data);//raw text lai json structure ma convert garcha

    if (doc.isNull()) { //**** if kei pani return ayena archive bata
        emit loadingChanged(false);
        emit errorOccurred("Failed to parse response from Archive.org");
        return;
    }

    QVariantList partials = parseSearchResponse(doc);//*******json ko formatting clean garcha ani neat list jasto banaucha

    if (partials.isEmpty()) {
        emit loadingChanged(false);
        emit genreResultsReady({});
        return;
    }

    resolveVideoUrls(partials, GenreRequest);
}



//Error checck hunxa ani json parse, if error aayo bhane result aaudaina natra url build hunxaS
QVariantList ArchiveAPI::parseSearchResponse(const QJsonDocument &doc) {
    QVariantList result;

    QJsonObject root   = doc.object();
    QJsonObject resp   = root["response"].toObject();
    QJsonArray  const docs   = resp["docs"].toArray();

    //Details haru fetch garxa, title, desc, genre.....
    for (const QJsonValue &v : docs) {
        QJsonObject item = v.toObject();
        QString id = item["identifier"].toString();
        if (id.isEmpty())
            continue;

        QString title = item["title"].toString();

        // strig ra array both
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
        if (genre.isEmpty())
            genre = "Film";


        //string ne huna sakxa, array ne
        QString desc;
        QJsonValue dv = item["description"];
        if (dv.isArray())
            desc = dv.toArray().first().toString();
        else
            desc = dv.toString();

        // Description 300 character bhanda badhi xa bhane cut gardinxa
        if (desc.length() > 300)
            desc = desc.left(300) + "...";



        //Block/Ignore garxa if blocked word xa bhbane----------               ***** Print remove kaam bhayepaxi***********
        if (Block(title) || Block(genre) || Block(desc)) {
            static int i = 1;
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

        //Fake rating calculator
        // m["rating"]      = QString::number(
        //                        qMin(9.9, (item["downloads"].toDouble() / 50000.0) * 8.0 + 5.0),
        //                        'f', 1);

        result.append(m);
    }

    return result;
}



//file find garxa ani play, best quality haru choose hunxa
void ArchiveAPI::resolveVideoUrls(QVariantList partials, RequestType requestType) {
    int total = partials.size();
    pendingResolutions = total; //*******partials (metadata ko size)


    auto resolved = std::make_shared<QVariantList>();//****list that will collect movies when tiniharuko url is found
    auto pending  = std::make_shared<int>(total);//****** counter, jun start huncha at total no of movies and counts down to 0

    for (const QVariant &v : partials) {//*****loop chalaucha for each movie to find its video file
        QVariantMap movie = v.toMap();
        QString id = movie["identifier"].toString(); //*** each movie ko aafnai identifier huncha,string ma convert garcha

        QUrl url(QString("https://archive.org/metadata/%1").arg(id));//*****%1 ko thau ma aaba movie ko identifier jancha
        QNetworkReply *reply = net->get(QNetworkRequest(url));

        connect(reply, &QNetworkReply::finished, this,
                [this, reply, movie, resolved, pending, requestType]() mutable { //lambda function
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
                        if (requestType == CuratedRequest) {
                            emit curatedReady(*resolved);
                        }
                        else if (requestType == SearchRequest) {
                            emit searchResultsReady(*resolved);
                        }
                        else if (requestType == GenreRequest) {
                            //******10 ota movie lai matra liyeko
                            QVariantList finalResults;
                            for (int i = 0; i < resolved->size() && i < 10; ++i) {
                                finalResults.append(resolved->at(i));
                            }
                            emit genreResultsReady(finalResults);
                        }
                    }
                }
                );
    }
}
