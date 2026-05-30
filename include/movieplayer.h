#pragma once
#include <QObject>

class MoviePlayer : public QObject {
    Q_OBJECT

public:
    explicit MoviePlayer(QObject *parent = nullptr);
    ~MoviePlayer();
};
