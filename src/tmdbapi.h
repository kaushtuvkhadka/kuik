//*+*+*+*+*+ TMDB API backend — header file with enhanced multi-candidate search & result scoring **+*+*+*+*
#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantMap>
#include <QString>
#include <QStringList>

//*+*+*+*+*+ TmdbAPI class — searches TMDB using title, year, and identifier with fallback candidates **+*+*+*+*
class TmdbAPI : public QObject {
    Q_OBJECT

public:
    explicit TmdbAPI(QObject *parent = nullptr);

    //*+*+*+*+*+ QML-callable function: searches TMDB for a movie by title, optional year, and optional identifier **+*+*+*+*
    Q_INVOKABLE void searchMovie(const QString &title, const QString &year = "", const QString &identifier = "");

signals:
    //*+*+*+*+*+ Emitted when TMDB lookup completes — result map contains:
    //  "found"      (bool)   — whether a match was found
    //  "rating"     (double) — TMDB vote_average (0-10)
    //  "overview"   (string) — TMDB plot summary
    //  "title"      (string) — the query title (for matching in QML)
    // **+*+*+*+*
    void tmdbResultReady(QVariantMap result);

private:
    QNetworkAccessManager *net;

    //*+*+*+*+*+ Decodes HTML entities like &amp;, &quot;, &#39; in titles **+*+*+*+*
    static QString decodeHtml(const QString &str);

    //*+*+*+*+*+ Extracts a clean 4-digit year (YYYY) from raw year or title strings **+*+*+*+*
    static QString extractCleanYear(const QString &rawYear, const QString &rawTitle);

    //*+*+*+*+*+ Sanitizes messy Archive.org titles into clean movie search queries **+*+*+*+*
    static QString sanitizeTitle(const QString &raw);

    //*+*+*+*+*+ Converts snake_case / camelCase Archive.org identifiers into clean search terms **+*+*+*+*
    static QString sanitizeIdentifier(const QString &rawId);

    //*+*+*+*+*+ Builds a prioritized list of search query candidates from specific to broad **+*+*+*+*
    static QStringList buildSearchCandidates(const QString &title, const QString &identifier);

    //*+*+*+*+*+ Scores and selects the best matching result object from TMDB API response **+*+*+*+*
    static QJsonObject selectBestResult(const QJsonArray &results, const QString &cleanYear);

    //*+*+*+*+*+ Executes a single search attempt in the retry chain **+*+*+*+*
    void trySearch(const QString &originalTitle, const QStringList &candidates,
                   int index, const QString &cleanYear, bool useYearFilter);
};
