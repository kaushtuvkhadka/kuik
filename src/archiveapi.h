#pragma once

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>


class ArchiveAPI : public QObject {
    Q_OBJECT

public:
    explicit ArchiveAPI(QObject *parent = nullptr);

    Q_INVOKABLE void startDownload(QString url);

    Q_INVOKABLE void fetchCurated();

    Q_INVOKABLE void search(const QString &query);

//***********Q_invokable = qt macro/keyword, allows QML to call the function directly
// ***************jaba user le genre choose garcha it lets interface (qml) to call archiveApi.fetchGenre("<genre>")
    Q_INVOKABLE void fetchGenre(const QString &genre);

signals:

    void curatedReady(QVariantList movies);


    void searchResultsReady(QVariantList movies);

//*******jaba backend le movie fetch garisakcha yesle signal pathaucha homepage.qml ko connection ma bhayeko function ma
    void genreResultsReady(QVariantList movies);

    void errorOccurred(const QString &message);

    void loadingChanged(bool loading);

    void downloadProgress(int percentage);

    void curatedMovieReady(QVariantMap movie);
    void searchMovieReady(QVariantMap movie);
    void genreMovieReady(QVariantMap movie);

private slots:
    void onSearchReply(QNetworkReply *reply, bool isCurated);
    //***************search query bata reply(metadata) aaisakepachi yo run huncha
    void onGenreReply(QNetworkReply *reply);

private:
    enum RequestType {
        SearchRequest,
        CuratedRequest,
        GenreRequest
    };

    QNetworkAccessManager *net;

    QVariantList parseSearchResponse(const QJsonDocument &doc);

    void resolveVideoUrls(QVariantList partials, RequestType requestType);

    int pendingResolutions = 0;
    QVariantList resolvedCurated;
    QVariantList resolvedSearch;


    static QString posterUrl(const QString &identifier);

    static QString streamUrl(const QString &identifier, const QString &filename);

    static QString bestMp4(const QJsonArray &files, const QString &identifier);

    static bool Block(const QString &text);

    struct ResolveState {
        QVariantList pending;
        QVariantList resolved;
        int index = 0;
    };

    ResolveState curatedState;
    ResolveState searchState;
    ResolveState genreState;

    int curatedGeneration = 0;
    int searchGeneration = 0;
    int genreGeneration = 0;

    ResolveState& stateFor(RequestType type);
    int& generationFor(RequestType type);
    void fetchNextMovie(RequestType requestType, int generation);
};
