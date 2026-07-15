#pragma once
// This file DECLARES our AccountManager class.
// It lists what functions exist, but the actual code for them lives in accountmanager.cpp

#include <QObject>
#include <QString>

// QObject lets this class talk to QML (send signals, be called from QML)
class AccountManager : public QObject
{
    Q_OBJECT  // Required macro so Qt's tools can connect this class to QML

public:
    // Constructor
    explicit AccountManager(QObject *parent = nullptr);

    // Q_INVOKABLE means QML is allowed to call this function directly
    // Checks if an account already exists in our saved file.
    // Returns true -> show Login page. Returns false -> show Signup page.
    Q_INVOKABLE bool accountExists();

    // Creates a new account and saves it to file.
    // Returns true if successful, false if something went wrong
    Q_INVOKABLE bool signup(const QString &username, const QString &password);

    // Checks if the given username/password match a saved account.
    // Returns true if login is correct, false if not.
    Q_INVOKABLE bool login(const QString &username, const QString &password);

    // Returns the username of whoever is currently logged in.
    // Empty string means nobody is logged in yet.
    Q_INVOKABLE QString currentUser();

    // Clears the logged-in user. Called when the user logs out.
    Q_INVOKABLE void logout();

    private:
    // Remembers who's logged in during this app session (not saved to disk).
    QString loggedInUser;
};