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


    Q_INVOKABLE void fetchCurated();


    Q_INVOKABLE void search(const QString &query);

signals:

    void curatedReady(QVariantList movies);


    void searchResultsReady(QVariantList movies);

    void errorOccurred(const QString &message);

    void loadingChanged(bool loading);

private slots:
    void onSearchReply(QNetworkReply *reply, bool isCurated);

private:
    QNetworkAccessManager *net;

    QVariantList parseSearchResponse(const QJsonDocument &doc);

    void resolveVideoUrls(QVariantList partials, bool isCurated);

    int pendingResolutions = 0;
    QVariantList resolvedCurated;
    QVariantList resolvedSearch;


    static QString posterUrl(const QString &identifier);

    static QString streamUrl(const QString &identifier, const QString &filename);

    static QString bestMp4(const QJsonArray &files, const QString &identifier);
};
