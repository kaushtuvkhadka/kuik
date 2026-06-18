#include <QtQml/qqmlprivate.h>
#include <QtCore/qdir.h>
#include <QtCore/qurl.h>
#include <QtCore/qhash.h>
#include <QtCore/qstring.h>

namespace QmlCacheGeneratedCode {
namespace _qt_qml_KUik_qml_Main_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_KUik_qml_pages_HomePage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_KUik_qml_pages_DetailPage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_KUik_qml_pages_PlayerPage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_KUik_qml_pages_SearchPage_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_KUik_qml_components_NavBar_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_KUik_qml_components_MovieCard_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_KUik_qml_components_SearchBar_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_KUik_qml_components_VideoControls_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}
namespace _qt_qml_KUik_qml_components_LoadingSpinner_qml { 
    extern const unsigned char qmlData[];
    extern const QQmlPrivate::AOTCompiledFunction aotBuiltFunctions[];
    const QQmlPrivate::CachedQmlUnit unit = {
        reinterpret_cast<const QV4::CompiledData::Unit*>(&qmlData), &aotBuiltFunctions[0], nullptr
    };
}

}
namespace {
struct Registry {
    Registry();
    ~Registry();
    QHash<QString, const QQmlPrivate::CachedQmlUnit*> resourcePathToCachedUnit;
    static const QQmlPrivate::CachedQmlUnit *lookupCachedUnit(const QUrl &url);
};

Q_GLOBAL_STATIC(Registry, unitRegistry)


Registry::Registry() {
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/KUik/qml/Main.qml"), &QmlCacheGeneratedCode::_qt_qml_KUik_qml_Main_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/KUik/qml/pages/HomePage.qml"), &QmlCacheGeneratedCode::_qt_qml_KUik_qml_pages_HomePage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/KUik/qml/pages/DetailPage.qml"), &QmlCacheGeneratedCode::_qt_qml_KUik_qml_pages_DetailPage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/KUik/qml/pages/PlayerPage.qml"), &QmlCacheGeneratedCode::_qt_qml_KUik_qml_pages_PlayerPage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/KUik/qml/pages/SearchPage.qml"), &QmlCacheGeneratedCode::_qt_qml_KUik_qml_pages_SearchPage_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/KUik/qml/components/NavBar.qml"), &QmlCacheGeneratedCode::_qt_qml_KUik_qml_components_NavBar_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/KUik/qml/components/MovieCard.qml"), &QmlCacheGeneratedCode::_qt_qml_KUik_qml_components_MovieCard_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/KUik/qml/components/SearchBar.qml"), &QmlCacheGeneratedCode::_qt_qml_KUik_qml_components_SearchBar_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/KUik/qml/components/VideoControls.qml"), &QmlCacheGeneratedCode::_qt_qml_KUik_qml_components_VideoControls_qml::unit);
    resourcePathToCachedUnit.insert(QStringLiteral("/qt/qml/KUik/qml/components/LoadingSpinner.qml"), &QmlCacheGeneratedCode::_qt_qml_KUik_qml_components_LoadingSpinner_qml::unit);
    QQmlPrivate::RegisterQmlUnitCacheHook registration;
    registration.structVersion = 0;
    registration.lookupCachedQmlUnit = &lookupCachedUnit;
    QQmlPrivate::qmlregister(QQmlPrivate::QmlUnitCacheHookRegistration, &registration);
}

Registry::~Registry() {
    QQmlPrivate::qmlunregister(QQmlPrivate::QmlUnitCacheHookRegistration, quintptr(&lookupCachedUnit));
}

const QQmlPrivate::CachedQmlUnit *Registry::lookupCachedUnit(const QUrl &url) {
    if (url.scheme() != QLatin1String("qrc"))
        return nullptr;
    QString resourcePath = QDir::cleanPath(url.path());
    if (resourcePath.isEmpty())
        return nullptr;
    if (!resourcePath.startsWith(QLatin1Char('/')))
        resourcePath.prepend(QLatin1Char('/'));
    return unitRegistry()->resourcePathToCachedUnit.value(resourcePath, nullptr);
}
}
int QT_MANGLE_NAMESPACE(qInitResources_qmlcache_KUik_GUI)() {
    ::unitRegistry();
    return 1;
}
Q_CONSTRUCTOR_FUNCTION(QT_MANGLE_NAMESPACE(qInitResources_qmlcache_KUik_GUI))
int QT_MANGLE_NAMESPACE(qCleanupResources_qmlcache_KUik_GUI)() {
    return 1;
}
