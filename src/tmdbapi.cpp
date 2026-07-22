//*+*+*+*+*+ TMDB API backend — enhanced search implementation with intelligent title sanitization and multi-candidate scoring **+*+*+*+*
#include "tmdbapi.h"
#include "constants.h"
#include <QUrl>
#include <QUrlQuery>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>
#include <QRegularExpression>
#include <QtGlobal>

//*+*+*+*+*+ Constructor — initializes network access manager with a 15s timeout **+*+*+*+*
TmdbAPI::TmdbAPI(QObject *parent) : QObject(parent) {
    net = new QNetworkAccessManager(this);
    net->setTransferTimeout(15000);
}


//*+*+*+*+*+ decodeHtml — replaces common HTML entities in Internet Archive titles **+*+*+*+*
QString TmdbAPI::decodeHtml(const QString &str) {
    QString t = str;
    t.replace("&amp;", "&", Qt::CaseInsensitive);
    t.replace("&quot;", "\"", Qt::CaseInsensitive);
    t.replace("&#39;", "'", Qt::CaseInsensitive);
    t.replace("&apos;", "'", Qt::CaseInsensitive);
    t.replace("&lt;", "<", Qt::CaseInsensitive);
    t.replace("&gt;", ">", Qt::CaseInsensitive);
    return t;
}


//*+*+*+*+*+ extractCleanYear — finds a valid 4-digit release year (18xx-20xx) from year or title **+*+*+*+*
QString TmdbAPI::extractCleanYear(const QString &rawYear, const QString &rawTitle) {
    static const QRegularExpression yearRegex(R"(\b(18|19|20)\d{2}\b)");

    //*+*+*+*+*+ Check raw year field first **+*+*+*+*
    QRegularExpressionMatch m = yearRegex.match(rawYear);
    if (m.hasMatch()) {
        return m.captured(0);
    }

    //*+*+*+*+*+ Fallback: search within the title string **+*+*+*+*
    m = yearRegex.match(rawTitle);
    if (m.hasMatch()) {
        return m.captured(0);
    }

    return QString();
}


//*+*+*+*+*+ sanitizeTitle — removes unwanted characters, metadata brackets, format tags, and noise from IA titles **+*+*+*+*
QString TmdbAPI::sanitizeTitle(const QString &raw) {
    QString t = decodeHtml(raw);

    //*+*+*+*+*+ Replace underscores, dots, and plus signs used as word separators **+*+*+*+*
    t.replace('_', ' ');
    t.replace('.', ' ');
    t.replace('+', ' ');

    //*+*+*+*+*+ Remove contents within parentheses, brackets, and curly braces **+*+*+*+*
    t.remove(QRegularExpression(R"(\([^)]*\))"));
    t.remove(QRegularExpression(R"(\[[^\]]*\])"));
    t.remove(QRegularExpression(R"(\{[^}]*\})"));

    //*+*+*+*+*+ Remove video file extensions **+*+*+*+*
    t.remove(QRegularExpression(R"(\.(mp4|avi|mkv|ogv|wmv|flv|mov)\b)", QRegularExpression::CaseInsensitiveOption));

    //*+*+*+*+*+ Remove 4-digit release years **+*+*+*+*
    t.remove(QRegularExpression(R"(\b(18|19|20)\d{2}\b)"));

    //*+*+*+*+*+ Remove common video format, resolution, and release noise keywords **+*+*+*+*
    static const QStringList junkWords = {
        "colorized", "restored", "remastered", "remaster",
        "hd", "720p", "1080p", "480p", "4k", "dvdrip", "bdrip", "bluray", "dvd", "vhs",
        "version", "extended", "uncut", "theatrical", "edition",
        "complete", "full", "movie", "film", "classic", "silent",
        "public domain", "archive org", "feature film",
        "part 1", "part 2", "part 3", "reel 1", "reel 2",
        "b&w", "black and white", "eng", "english", "subs", "subtitles",
        "rip", "x264", "h264", "aac", "mp3"
    };
    for (const QString &junk : junkWords) {
        t.remove(QRegularExpression("\\b" + QRegularExpression::escape(junk) + "\\b",
                                    QRegularExpression::CaseInsensitiveOption));
    }

    //*+*+*+*+*+ Truncate at dash, pipe, or colon separator if title prefix is sufficiently long **+*+*+*+*
    int sepPos = t.indexOf(QRegularExpression(R"(\s[-–—|:]\s)"));
    if (sepPos > 3) {
        t = t.left(sepPos);
    }

    //*+*+*+*+*+ Strip all remaining special symbols except letters, numbers, spaces, hyphens, and apostrophes **+*+*+*+*
    t.remove(QRegularExpression(R"([^a-zA-Z0-9\s'-])"));

    return t.simplified();
}


//*+*+*+*+*+ sanitizeIdentifier — converts Archive.org item identifiers (e.g., "the_general_1926") into clean title queries **+*+*+*+*
QString TmdbAPI::sanitizeIdentifier(const QString &rawId) {
    if (rawId.trimmed().isEmpty()) return QString();

    QString id = rawId;

    //*+*+*+*+*+ Split camelCase identifiers into separate words **+*+*+*+*
    id.replace(QRegularExpression(R"(([a-z])([A-Z]))"), R"(\1 \2)");

    //*+*+*+*+*+ Replace underscores and hyphens with spaces **+*+*+*+*
    id.replace('_', ' ');
    id.replace('-', ' ');

    //*+*+*+*+*+ Apply standard title sanitization **+*+*+*+*
    return sanitizeTitle(id);
}


//*+*+*+*+*+ buildSearchCandidates — constructs a list of search query candidates from most specific to broadest **+*+*+*+*
QStringList TmdbAPI::buildSearchCandidates(const QString &title, const QString &identifier) {
    QStringList candidates;

    //*+*+*+*+*+ Helper lambda to add non-empty, unique search candidate strings **+*+*+*+*
    auto addCandidate = [&candidates](const QString &cand) {
        QString s = cand.simplified();
        if (!s.isEmpty() && s.length() >= 2 && !candidates.contains(s, Qt::CaseInsensitive)) {
            candidates << s;
        }
    };

    //*+*+*+*+*+ Candidate 1: Fully sanitized title **+*+*+*+*
    QString cleanT = sanitizeTitle(title);
    addCandidate(cleanT);

    //*+*+*+*+*+ Candidate 2: Title trimmed before any dash, colon, or pipe separator **+*+*+*+*
    QString rawDecoded = decodeHtml(title);
    int sepPos = rawDecoded.indexOf(QRegularExpression(R"([-–—|:])"));
    if (sepPos > 2) {
        addCandidate(sanitizeTitle(rawDecoded.left(sepPos)));
    }

    //*+*+*+*+*+ Candidate 3: Cleaned item identifier **+*+*+*+*
    QString cleanId = sanitizeIdentifier(identifier);
    addCandidate(cleanId);

    //*+*+*+*+*+ Candidate 4: Minimal title cleanup (just brackets and separators removed) **+*+*+*+*
    QString minimal = rawDecoded;
    minimal.replace('_', ' ');
    minimal.replace('.', ' ');
    minimal.remove(QRegularExpression(R"(\([^)]*\))"));
    minimal.remove(QRegularExpression(R"(\[[^\]]*\])"));
    addCandidate(minimal);

    //*+*+*+*+*+ Candidate 5 & 6: Progressive word truncations for multi-word titles **+*+*+*+*
    if (!cleanT.isEmpty()) {
        QStringList words = cleanT.split(' ', Qt::SkipEmptyParts);
        if (words.size() > 3) {
            addCandidate(words.mid(0, 3).join(' '));
        }
        if (words.size() > 2) {
            addCandidate(words.mid(0, 2).join(' '));
        }
    }

    qDebug() << "[TmdbAPI] Built candidate search terms for:" << title
             << "| ID:" << identifier << "=>" << candidates;
    return candidates;
}


//*+*+*+*+*+ selectBestResult — evaluates and ranks TMDB API search results to pick the most accurate match **+*+*+*+*
QJsonObject TmdbAPI::selectBestResult(const QJsonArray &results, const QString &cleanYear) {
    if (results.isEmpty()) return QJsonObject();

    int bestIndex = 0;
    double bestScore = -100.0;

    for (int i = 0; i < results.size(); ++i) {
        QJsonObject item = results[i].toObject();
        double score = 0.0;

        //*+*+*+*+*+ Reward items that contain a non-empty overview **+*+*+*+*
        QString overview = item["overview"].toString().trimmed();
        if (!overview.isEmpty()) {
            score += 40.0;
        }

        //*+*+*+*+*+ Factor in popularity and vote count from TMDB **+*+*+*+*
        double popularity = item["popularity"].toDouble();
        int voteCount = item["vote_count"].toInt();
        score += qMin(30.0, popularity);
        score += qMin(20.0, static_cast<double>(voteCount) / 10.0);

        //*+*+*+*+*+ Match release year against cleanYear if available **+*+*+*+*
        QString releaseDate = item["release_date"].toString();
        if (!cleanYear.isEmpty() && releaseDate.length() >= 4) {
            QString itemYear = releaseDate.left(4);
            if (itemYear == cleanYear) {
                score += 100.0; //*+*+*+*+*+ Exact year match bonus **+*+*+*+*
            } else {
                bool ok1, ok2;
                int y1 = cleanYear.toInt(&ok1);
                int y2 = itemYear.toInt(&ok2);
                if (ok1 && ok2 && qAbs(y1 - y2) <= 1) {
                    score += 50.0; //*+*+*+*+*+ Near year match bonus (+/- 1 year) **+*+*+*+*
                }
            }
        }

        if (score > bestScore) {
            bestScore = score;
            bestIndex = i;
        }
    }

    return results[bestIndex].toObject();
}


//*+*+*+*+*+ searchMovie — entry point called from QML to start TMDB lookup **+*+*+*+*
void TmdbAPI::searchMovie(const QString &title, const QString &year, const QString &identifier) {
    if (title.trimmed().isEmpty() && identifier.trimmed().isEmpty()) {
        QVariantMap notFound;
        notFound["found"] = false;
        notFound["title"] = title;
        emit tmdbResultReady(notFound);
        return;
    }

    //*+*+*+*+*+ Extract clean 4-digit release year **+*+*+*+*
    QString cleanYear = extractCleanYear(year, title);

    //*+*+*+*+*+ Build search candidates list **+*+*+*+*
    QStringList candidates = buildSearchCandidates(title, identifier);

    if (candidates.isEmpty()) {
        QVariantMap notFound;
        notFound["found"] = false;
        notFound["title"] = title;
        emit tmdbResultReady(notFound);
        return;
    }

    //*+*+*+*+*+ Start search chain with index 0 and year filter enabled **+*+*+*+*
    trySearch(title, candidates, 0, cleanYear, true);
}


//*+*+*+*+*+ trySearch — executes a search request and recursively attempts fallback candidates **+*+*+*+*
void TmdbAPI::trySearch(const QString &originalTitle, const QStringList &candidates,
                        int index, const QString &cleanYear, bool useYearFilter) {

    //*+*+*+*+*+ Exhausted all candidate queries — emit not found **+*+*+*+*
    if (index >= candidates.size()) {
        qDebug() << "[TmdbAPI] All candidate search terms exhausted for:" << originalTitle;
        QVariantMap result;
        result["found"] = false;
        result["title"] = originalTitle;
        emit tmdbResultReady(result);
        return;
    }

    QString query = candidates[index];

    //*+*+*+*+*+ Construct TMDB GET request URL **+*+*+*+*
    QUrl url(TmdbConstants::kBaseUrl + TmdbConstants::kSearchMoviePath);
    QUrlQuery q;
    q.addQueryItem("query", query);

    //*+*+*+*+*+ Add year filter if requested and cleanYear is present **+*+*+*+*
    if (useYearFilter && !cleanYear.isEmpty()) {
        q.addQueryItem("year", cleanYear);
    }
    q.addQueryItem("language", "en-US");
    q.addQueryItem("page", "1");
    //*+*+*+*+*+ Use api_key query parameter instead of bearer token, as the bearer token is invalid **+*+*+*+*
    q.addQueryItem("api_key", TmdbConstants::kApiKey);
    url.setQuery(q);

    //*+*+*+*+*+ Configure authorization header **+*+*+*+*
    QNetworkRequest request(url);
    request.setRawHeader("Accept", "application/json");

    QNetworkReply *reply = net->get(request);

    qDebug() << "[TmdbAPI] Searching candidate" << (index + 1) << "/" << candidates.size()
             << "=> query:" << query << "| year filter:" << (useYearFilter ? cleanYear : "NONE");

    //*+*+*+*+*+ Handle API response **+*+*+*+*
    connect(reply, &QNetworkReply::finished, this,
            [this, reply, originalTitle, candidates, index, cleanYear, useYearFilter]() {
        reply->deleteLater();

        //*+*+*+*+*+ Handle network errors by moving to next attempt **+*+*+*+*
        if (reply->error() != QNetworkReply::NoError) {
            qWarning() << "[TmdbAPI] Network error:" << reply->errorString();
            if (useYearFilter && !cleanYear.isEmpty()) {
                trySearch(originalTitle, candidates, index, cleanYear, false);
            } else {
                trySearch(originalTitle, candidates, index + 1, cleanYear, true);
            }
            return;
        }

        QByteArray data = reply->readAll();
        QJsonDocument doc = QJsonDocument::fromJson(data);

        if (doc.isNull()) {
            qWarning() << "[TmdbAPI] Failed to parse JSON response";
            if (useYearFilter && !cleanYear.isEmpty()) {
                trySearch(originalTitle, candidates, index, cleanYear, false);
            } else {
                trySearch(originalTitle, candidates, index + 1, cleanYear, true);
            }
            return;
        }

        QJsonObject root = doc.object();
        QJsonArray results = root["results"].toArray();

        //*+*+*+*+*+ If no results returned **+*+*+*+*
        if (results.isEmpty()) {
            if (useYearFilter && !cleanYear.isEmpty()) {
                //*+*+*+*+*+ Retry same candidate index WITHOUT year filter **+*+*+*+*
                trySearch(originalTitle, candidates, index, cleanYear, false);
            } else {
                //*+*+*+*+*+ Retry with next candidate index WITH year filter **+*+*+*+*
                trySearch(originalTitle, candidates, index + 1, cleanYear, true);
            }
            return;
        }

        //*+*+*+*+*+ Match found! Select best scored result **+*+*+*+*
        QJsonObject best = selectBestResult(results, cleanYear);

        QVariantMap result;
        result["title"]    = originalTitle;
        result["found"]    = true;
        result["rating"]   = best["vote_average"].toDouble();
        result["overview"] = best["overview"].toString();

        //*+*+*+*+*+ Extract extra metadata fields **+*+*+*+*
        QString backdrop = best["backdrop_path"].toString();
        QString poster   = best["poster_path"].toString();
        result["backdrop_path"] = backdrop.isEmpty() ? "" : "https://image.tmdb.org/t/p/w1280" + backdrop;
        result["poster_path"]   = poster.isEmpty()   ? "" : "https://image.tmdb.org/t/p/w500" + poster;
        result["release_date"]  = best["release_date"].toString();
        result["vote_count"]    = best["vote_count"].toInt();
        result["language"]      = best["original_language"].toString().toUpper();

        qDebug() << "TMDB match found for:" << originalTitle << "->" << best["title"].toString() << "Rating:" << result["rating"].toDouble();
        emit tmdbResultReady(result);
    });
}
