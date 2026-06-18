#ifndef ARCHIVEAPI_H
#define ARCHIVEAPI_H

#include <QObject>
#include <QtQml>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QVariantList>
#include <QJsonDocument>
#include <QJsonArray>

class ArchiveAPI : public QObject {
    Q_OBJECT
    QML_ELEMENT

public:
    explicit ArchiveAPI(QObject *parent = nullptr);

    // QML-invokable methods
    Q_INVOKABLE void startDownload(QString url);
    Q_INVOKABLE void fetchCurated();
    Q_INVOKABLE void search(const QString &query);

    // Helpers
    static QString posterUrl(const QString &id);
    QString streamUrl(const QString &id, const QString &filename); // Non-static member function

signals:
    void loadingChanged(bool loading);
    void errorOccurred(QString error);
    void curatedReady(QVariantList results);
    void searchResultsReady(QVariantList results);
    void downloadProgress(int percentage); // Signal to track progress in QML if desired

private:
    QNetworkAccessManager *net;
    int pendingResolutions = 0;

    QVariantList parseSearchResponse(const QJsonDocument &doc);
    void resolveVideoUrls(QVariantList partials, bool isCurated);
    void onSearchReply(QNetworkReply *reply, bool isCurated);
    QString bestMp4(const QJsonArray &files, const QString &id);
};

#endif // ARCHIVEAPI_H