#include "accountmanager.h"

// Essential Qt's built-in tools for reading/writing JSON files
#include <QFile>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

// Helper function (only used inside this file) that returns
// the full path to our accounts.json file, e.g.C:/Users/YourName/Documents/KUik/kuik-main/saved/accounts.json
static QString accountsFilePath()
{
    // We save it inside the actual project folder (not wherever the .exe happens to run from),
    // using PROJECT_ROOT_DIR — a path Qt fills in automatically at build time.
    QString folder = QString(PROJECT_ROOT_DIR) + "/saved";

    // Make sure the folder actually exists, create it if not.
    QDir().mkpath(folder);      //QDir().mkpath(folder) : creates a folder (and any missing parent folders) if it doesn't already exist. Safe to call even if it already exists

    return folder + "/accounts.json";
}

// Constructor
AccountManager::AccountManager(QObject *parent) : QObject(parent)
{
}

bool AccountManager::accountExists()
{
    QFile file(accountsFilePath());

    // If no files exists means no accounts have signed up
    if (!file.exists())
        return false;

    // Open the file for reading
    if (!file.open(QIODevice::ReadOnly))
        return false;

    // Read the whole file content as raw text
    QByteArray data = file.readAll();
    file.close();

    // To turn that raw text into a JSON document we can inspect
    QJsonDocument doc = QJsonDocument::fromJson(data);      //QJsonDocument::fromJson(data) — takes raw text (bytes) and parses it into a structured JSON object we can actually read fields from

    // JSON File: { "accounts": [ {...}, {...} ] }
    QJsonArray accounts = doc.object()["accounts"].toArray();       //doc.object()["accounts"].toArray() — pulls out the "accounts" field from our JSON and converts it into a list (array) we can loop through.

    // If there's at least 1 account saved, return true
    return accounts.size() > 0;
}

bool AccountManager::signup(const QString &username, const QString &password)
{
    QJsonArray accounts;

    // First, load any existing accounts (so we don't overwrite them)
    QFile readFile(accountsFilePath());
    if (readFile.exists() && readFile.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(readFile.readAll());
        accounts = doc.object()["accounts"].toArray();
        readFile.close();
    }

    // We allow up to 15 accounts total
    if (accounts.size() >= 15) {
        qDebug() << "Signup blocked: account limit reached";
        return false;
    }

    // Build a JSON object for the new account
    QJsonObject newAccount;
    newAccount["username"] = username;
    newAccount["password"] = password; // Note: plain text is fine for this small local use

    accounts.append(newAccount);

    // Wrap it back into the { "accounts": [...] } structure
    QJsonObject root;
    root["accounts"] = accounts;
    QJsonDocument doc(root);

    // Write it to the file
    QFile writeFile(accountsFilePath());
    if (!writeFile.open(QIODevice::WriteOnly)) {
        qDebug() << "Signup failed: could not open file for writing";
        return false;
    }

    writeFile.write(doc.toJson());
    writeFile.close();

    return true;
}

bool AccountManager::login(const QString &username, const QString &password)
{
    QFile file(accountsFilePath());
    if (!file.exists() || !file.open(QIODevice::ReadOnly))
        return false;

    QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
    file.close();

    QJsonArray accounts = doc.object()["accounts"].toArray();

    // Go through every saved account and check for a existing account
    for (const QJsonValue &val : accounts) {
        QJsonObject account = val.toObject();
        if (account["username"].toString() == username &&
            account["password"].toString() == password) {
            loggedInUser = username; // Remember who's logged in
            return true; // Found a match
        }
    }

    return false; // If No match found
}

QString AccountManager::currentUser()
{
    return loggedInUser;
}

void AccountManager::logout()
{
    loggedInUser.clear();
}