#include "InternetArchive.h"
#include <QDebug>   // qDebug() is Qt's version of cout, cleaner for Qt apps

InternetArchive::InternetArchive(QObject *parent) : QObject(parent) {
    // constructor - runs when object is created
}

void InternetArchive::fetch(const QString &query) {
    qDebug() << "fetch called with:" << query;
    // TODO: curl API call goes here
}

QString InternetArchive::getVideoUrl(const QString &identifier) {
    qDebug() << "getVideoUrl called with:" << identifier;
    // TODO: curl API call goes here
    return "";  // returns empty string for now
}