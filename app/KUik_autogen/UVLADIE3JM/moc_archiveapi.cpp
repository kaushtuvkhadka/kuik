/****************************************************************************
** Meta object code from reading C++ file 'archiveapi.h'
**
** Created by: The Qt Meta Object Compiler version 69 (Qt 6.11.1)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../../../src/archiveapi.h"
#include <QtNetwork/QSslError>
#include <QtCore/qmetatype.h>

#include <QtCore/qtmochelpers.h>

#include <memory>


#include <QtCore/qxptype_traits.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'archiveapi.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 69
#error "This file was generated using the moc from 6.11.1. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
QT_WARNING_DISABLE_GCC("-Wuseless-cast")
namespace {
struct qt_meta_tag_ZN10ArchiveAPIE_t {};
} // unnamed namespace

template <> constexpr inline auto ArchiveAPI::qt_create_metaobjectdata<qt_meta_tag_ZN10ArchiveAPIE_t>()
{
    namespace QMC = QtMocConstants;
    QtMocHelpers::StringRefStorage qt_stringData {
        "ArchiveAPI",
        "curatedReady",
        "",
        "QVariantList",
        "movies",
        "searchResultsReady",
        "genreResultsReady",
        "errorOccurred",
        "message",
        "loadingChanged",
        "loading",
        "downloadProgress",
        "percentage",
        "curatedMovieReady",
        "QVariantMap",
        "movie",
        "searchMovieReady",
        "genreMovieReady",
        "onSearchReply",
        "QNetworkReply*",
        "reply",
        "isCurated",
        "onGenreReply",
        "startDownload",
        "url",
        "fetchCurated",
        "search",
        "query",
        "fetchGenre",
        "genre"
    };

    QtMocHelpers::UintData qt_methods {
        // Signal 'curatedReady'
        QtMocHelpers::SignalData<void(QVariantList)>(1, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 3, 4 },
        }}),
        // Signal 'searchResultsReady'
        QtMocHelpers::SignalData<void(QVariantList)>(5, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 3, 4 },
        }}),
        // Signal 'genreResultsReady'
        QtMocHelpers::SignalData<void(QVariantList)>(6, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 3, 4 },
        }}),
        // Signal 'errorOccurred'
        QtMocHelpers::SignalData<void(const QString &)>(7, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 8 },
        }}),
        // Signal 'loadingChanged'
        QtMocHelpers::SignalData<void(bool)>(9, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Bool, 10 },
        }}),
        // Signal 'downloadProgress'
        QtMocHelpers::SignalData<void(int)>(11, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::Int, 12 },
        }}),
        // Signal 'curatedMovieReady'
        QtMocHelpers::SignalData<void(QVariantMap)>(13, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 14, 15 },
        }}),
        // Signal 'searchMovieReady'
        QtMocHelpers::SignalData<void(QVariantMap)>(16, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 14, 15 },
        }}),
        // Signal 'genreMovieReady'
        QtMocHelpers::SignalData<void(QVariantMap)>(17, 2, QMC::AccessPublic, QMetaType::Void, {{
            { 0x80000000 | 14, 15 },
        }}),
        // Slot 'onSearchReply'
        QtMocHelpers::SlotData<void(QNetworkReply *, bool)>(18, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 19, 20 }, { QMetaType::Bool, 21 },
        }}),
        // Slot 'onGenreReply'
        QtMocHelpers::SlotData<void(QNetworkReply *)>(22, 2, QMC::AccessPrivate, QMetaType::Void, {{
            { 0x80000000 | 19, 20 },
        }}),
        // Method 'startDownload'
        QtMocHelpers::MethodData<void(QString)>(23, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 24 },
        }}),
        // Method 'fetchCurated'
        QtMocHelpers::MethodData<void()>(25, 2, QMC::AccessPublic, QMetaType::Void),
        // Method 'search'
        QtMocHelpers::MethodData<void(const QString &)>(26, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 27 },
        }}),
        // Method 'fetchGenre'
        QtMocHelpers::MethodData<void(const QString &)>(28, 2, QMC::AccessPublic, QMetaType::Void, {{
            { QMetaType::QString, 29 },
        }}),
    };
    QtMocHelpers::UintData qt_properties {
    };
    QtMocHelpers::UintData qt_enums {
    };
    return QtMocHelpers::metaObjectData<ArchiveAPI, qt_meta_tag_ZN10ArchiveAPIE_t>(QMC::MetaObjectFlag{}, qt_stringData,
            qt_methods, qt_properties, qt_enums);
}
Q_CONSTINIT const QMetaObject ArchiveAPI::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10ArchiveAPIE_t>.stringdata,
    qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10ArchiveAPIE_t>.data,
    qt_static_metacall,
    nullptr,
    qt_staticMetaObjectRelocatingContent<qt_meta_tag_ZN10ArchiveAPIE_t>.metaTypes,
    nullptr
} };

void ArchiveAPI::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    auto *_t = static_cast<ArchiveAPI *>(_o);
    if (_c == QMetaObject::InvokeMetaMethod) {
        switch (_id) {
        case 0: _t->curatedReady((*reinterpret_cast<std::add_pointer_t<QVariantList>>(_a[1]))); break;
        case 1: _t->searchResultsReady((*reinterpret_cast<std::add_pointer_t<QVariantList>>(_a[1]))); break;
        case 2: _t->genreResultsReady((*reinterpret_cast<std::add_pointer_t<QVariantList>>(_a[1]))); break;
        case 3: _t->errorOccurred((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 4: _t->loadingChanged((*reinterpret_cast<std::add_pointer_t<bool>>(_a[1]))); break;
        case 5: _t->downloadProgress((*reinterpret_cast<std::add_pointer_t<int>>(_a[1]))); break;
        case 6: _t->curatedMovieReady((*reinterpret_cast<std::add_pointer_t<QVariantMap>>(_a[1]))); break;
        case 7: _t->searchMovieReady((*reinterpret_cast<std::add_pointer_t<QVariantMap>>(_a[1]))); break;
        case 8: _t->genreMovieReady((*reinterpret_cast<std::add_pointer_t<QVariantMap>>(_a[1]))); break;
        case 9: _t->onSearchReply((*reinterpret_cast<std::add_pointer_t<QNetworkReply*>>(_a[1])),(*reinterpret_cast<std::add_pointer_t<bool>>(_a[2]))); break;
        case 10: _t->onGenreReply((*reinterpret_cast<std::add_pointer_t<QNetworkReply*>>(_a[1]))); break;
        case 11: _t->startDownload((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 12: _t->fetchCurated(); break;
        case 13: _t->search((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        case 14: _t->fetchGenre((*reinterpret_cast<std::add_pointer_t<QString>>(_a[1]))); break;
        default: ;
        }
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        switch (_id) {
        default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
        case 9:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QNetworkReply* >(); break;
            }
            break;
        case 10:
            switch (*reinterpret_cast<int*>(_a[1])) {
            default: *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType(); break;
            case 0:
                *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType::fromType< QNetworkReply* >(); break;
            }
            break;
        }
    }
    if (_c == QMetaObject::IndexOfMethod) {
        if (QtMocHelpers::indexOfMethod<void (ArchiveAPI::*)(QVariantList )>(_a, &ArchiveAPI::curatedReady, 0))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArchiveAPI::*)(QVariantList )>(_a, &ArchiveAPI::searchResultsReady, 1))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArchiveAPI::*)(QVariantList )>(_a, &ArchiveAPI::genreResultsReady, 2))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArchiveAPI::*)(const QString & )>(_a, &ArchiveAPI::errorOccurred, 3))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArchiveAPI::*)(bool )>(_a, &ArchiveAPI::loadingChanged, 4))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArchiveAPI::*)(int )>(_a, &ArchiveAPI::downloadProgress, 5))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArchiveAPI::*)(QVariantMap )>(_a, &ArchiveAPI::curatedMovieReady, 6))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArchiveAPI::*)(QVariantMap )>(_a, &ArchiveAPI::searchMovieReady, 7))
            return;
        if (QtMocHelpers::indexOfMethod<void (ArchiveAPI::*)(QVariantMap )>(_a, &ArchiveAPI::genreMovieReady, 8))
            return;
    }
}

const QMetaObject *ArchiveAPI::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ArchiveAPI::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_staticMetaObjectStaticContent<qt_meta_tag_ZN10ArchiveAPIE_t>.strings))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int ArchiveAPI::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 15)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 15;
    }
    if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 15)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 15;
    }
    return _id;
}

// SIGNAL 0
void ArchiveAPI::curatedReady(QVariantList _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 0, nullptr, _t1);
}

// SIGNAL 1
void ArchiveAPI::searchResultsReady(QVariantList _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 1, nullptr, _t1);
}

// SIGNAL 2
void ArchiveAPI::genreResultsReady(QVariantList _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 2, nullptr, _t1);
}

// SIGNAL 3
void ArchiveAPI::errorOccurred(const QString & _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 3, nullptr, _t1);
}

// SIGNAL 4
void ArchiveAPI::loadingChanged(bool _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 4, nullptr, _t1);
}

// SIGNAL 5
void ArchiveAPI::downloadProgress(int _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 5, nullptr, _t1);
}

// SIGNAL 6
void ArchiveAPI::curatedMovieReady(QVariantMap _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 6, nullptr, _t1);
}

// SIGNAL 7
void ArchiveAPI::searchMovieReady(QVariantMap _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 7, nullptr, _t1);
}

// SIGNAL 8
void ArchiveAPI::genreMovieReady(QVariantMap _t1)
{
    QMetaObject::activate<void>(this, &staticMetaObject, 8, nullptr, _t1);
}
QT_WARNING_POP
