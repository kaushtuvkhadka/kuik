#pragma once
// Declares WatchHistoryManager — tracks which movies each account has watched.
// Works the same way as AccountManager: QML calls these functions, the actual
// logic lives in watchhistorymanager.cpp, and everything is saved to a JSON file.

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QVariantList>

class WatchHistoryManager : public QObject
{
    Q_OBJECT

public:
    explicit WatchHistoryManager(QObject *parent = nullptr);

    // Adds a movie to the given user's watch history.
    // 'movie' should contain title, year, genre, rating, poster_url, identifier
    // (basically the same fields already used elsewhere in the app).
    Q_INVOKABLE void addToHistory(const QString &username, const QVariantMap &movie);

    // Returns the given user's watch history as a list (most recent first).
    Q_INVOKABLE QVariantList getHistory(const QString &username);
};
