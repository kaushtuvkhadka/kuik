#pragma once
#include <QObject>

class ApiFetcher : public QObject {
    Q_OBJECT

public:
    explicit ApiFetcher(QObject *parent = nullptr);
    ~ApiFetcher();
};
