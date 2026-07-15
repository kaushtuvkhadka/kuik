#include "watchhistorymanager.h"

#include <QFile>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

// Same pattern as accountmanager.cpp: build the file path using
// PROJECT_ROOT_DIR so it always saves inside the project's "saved" folder.
static QString historyFilePath()
{
    QString folder = QString(PROJECT_ROOT_DIR) + "/saved";
    QDir().mkpath(folder);
    return folder + "/watch_history.json";
}

WatchHistoryManager::WatchHistoryManager(QObject *parent) : QObject(parent)
{
}

void WatchHistoryManager::addToHistory(const QString &username, const QVariantMap &movie)
{
    if (username.isEmpty())
        return;

    // Our JSON file looks like:
    // { "history": { "aryan": [ {...movie...}, {...movie...} ], "demo1": [...] } }
    QJsonObject root;

    QFile readFile(historyFilePath());
    if (readFile.exists() && readFile.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(readFile.readAll());
        root = doc.object();
        readFile.close();
    }

    QJsonObject historyObj = root["history"].toObject();
    QJsonArray userHistory = historyObj[username].toArray();

    // Turn the incoming movie (QVariantMap from QML) into a JSON object
    QJsonObject movieObj = QJsonObject::fromVariantMap(movie);

    // Avoid duplicate back-to-back entries if the same movie is opened twice in a row
    if (!userHistory.isEmpty() &&
        userHistory.last().toObject()["identifier"] == movieObj["identifier"]) {
        return;
    }

    userHistory.append(movieObj);

    historyObj[username] = userHistory;
    root["history"] = historyObj;

    QJsonDocument doc(root);
    QFile writeFile(historyFilePath());
    if (!writeFile.open(QIODevice::WriteOnly)) {
        qDebug() << "Failed to write watch history";
        return;
    }
    writeFile.write(doc.toJson());
    writeFile.close();
}

QVariantList WatchHistoryManager::getHistory(const QString &username)
{
    QVariantList result;

    QFile file(historyFilePath());
    if (!file.exists() || !file.open(QIODevice::ReadOnly))
        return result; // No history yet — return empty list

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    QJsonObject historyObj = doc.object()["history"].toObject();
    QJsonArray userHistory = historyObj[username].toArray();

    // Reverse order so most recently watched shows first
    for (int i = userHistory.size() - 1; i >= 0; --i) {
        result.append(userHistory[i].toVariant());
    }

    return result;
}