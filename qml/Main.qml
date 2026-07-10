import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: root
    width: 1280
    height: 720
    minimumWidth: 1024
    minimumHeight: 600
    visibility: Window.Maximized
    visible: true
    title: "KUik"
    color: "#0f0f0f"

    // --- Cache for the curated movie data ---
    // We start fetching this the moment the app opens (see below),
    // while the user is still busy on Signup/Login. By the time they
    // reach HomePage, this is likely already filled in, so HomePage
    // shows instantly instead of showing its own loading spinner
    // for better user experience
    property var cachedMovies: []
    property bool moviesCached: false

    Connections {
    target: archiveApi
    function onCuratedReady(movies) {
        root.cachedMovies = movies
        root.moviesCached = true
        }
    }

    // Kick off the fetch as soon as the app window exists :
    // this runs in the background no matter which page (Signup/Login) is shown
    Component.onCompleted: {
        archiveApi.fetchCurated()
    }

    StackView {
        id: stackView
        anchors.fill: parent

        // Decide the very first page:
        // - accountManager.accountExists() checks the saved JSON file for any accounts.
        // - true  -> show Login (someone already signed up)
        // - false -> show Signup (first time opening the app)
        initialItem: accountManager.accountExists() ? loginPageComponent : signupPageComponent
    }

    Component {
            id: homePageComponent
            Loader {
                source: "qrc:/qt/qml/KUik/qml/pages/HomePage.qml"
                onLoaded: {
                    item.appStack = stackView
                    // Hand over any already-fetched movie data, so HomePage
                    // doesn't need to call the API again
                    if (root.moviesCached) {
                        item.setPreloadedMovies(root.cachedMovies)
                        } else {
                        item.startFetch()
                    }
                }
            }
        }

        Component {
            id: signupPageComponent
            Loader {
                source: "qrc:/qt/qml/KUik/qml/pages/Signup.qml"
                onLoaded: item.appStack = stackView
            }
        }

        Component {
            id: loginPageComponent
            Loader {
                source: "qrc:/qt/qml/KUik/qml/pages/Login.qml"
                onLoaded: item.appStack = stackView
            }
        }
}
