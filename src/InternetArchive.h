#ifndef INTERNETARCHIVE_H
#define INTERNETARCHIVE_H

#include <QObject>
#include <QVariantList>
#include <string>

class InternetArchive : public QObject {
    Q_OBJECT

public:
    explicit InternetArchive(QObject *parent = nullptr);
    Q_INVOKABLE void fetch(const QString &query);
    Q_INVOKABLE QString getVideoUrl(const QString &identifier);

signals:
    void recommendationsChanged();

private:
    QVariantList m_recommendations;
    std::string curlGet(const std::string &url);
};

#endif