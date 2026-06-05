import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"

Rectangle {
    id: homePage
    width: parent.width
    height: parent.height
    color: "#0f0f0f"

    property var appStack: null
    property var recommendations: [
        {
            title: "The Kid",
            year: "1921",
            genre: "Comedy",
            rating: 8.3,
            identifier: "TheKid1921",
            poster_url: "",
            video_url: "",
            description: "A tramp raises an abandoned child."
        }
    ]

    onRecommendationsChanged: {
        console.log("recommendations count:", recommendations.length)
    }
    property var top_picks: []

    Column {
        width: parent.width
        height: parent.height
        spacing: 0

        NavBar {
            id: nav_bar
            width: parent.width
            onSearchRequested: function(query) { console.log("Search:", query) }
            onMenuClicked: { console.log("Menu Clicked") }
        }

        ScrollView {
            width: parent.width
            height: homePage.height - nav_bar.height
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: parent.width
                spacing: 32
                topPadding: 32
                bottomPadding: 32

                // Recommendations Section
                Column {
                    width: parent.width
                    spacing: 16
                    leftPadding: 32

                    Text {
                        text: "Recommendations"
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Row {
                        spacing: 16
                        Repeater {
                            model: recommendations
                            MovieCard {
                                movie_title: modelData.title
                                movie_year: modelData.year
                                movie_genre: modelData.genre
                                movie_rating: modelData.rating
                                onCardClicked: {
                                    if (homePage.appStack) {
                                        homePage.appStack.push(
                                            "qrc:/qt/qml/KUik/qml/pages/DetailPage.qml",
                                            {
                                                movie_title:       modelData.title,
                                                movie_year:        modelData.year,
                                                movie_genre:       modelData.genre,
                                                movie_rating:      modelData.rating,
                                                movie_description: modelData.description,
                                                poster_url:        modelData.poster_url,
                                                video_url:         "",
                                                movie_identifier:  modelData.identifier,
                                                appStack:          homePage.appStack
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }

                // Top Picks Section
                Column {
                    width: parent.width
                    spacing: 16
                    leftPadding: 32

                    Text {
                        text: "Top Picks"
                        color: "#ffffff"
                        font.pixelSize: 18
                        font.bold: true
                    }

                    Row {
                        spacing: 16
                        Repeater {
                            model: top_picks
                            MovieCard {
                                movie_title: modelData.title
                                movie_year: modelData.year
                                movie_genre: modelData.genre
                                movie_rating: modelData.rating
                                onCardClicked: {
                                    if (homePage.appStack) {
                                        homePage.appStack.push(
                                            "qrc:/qt/qml/KUik/qml/pages/DetailPage.qml",
                                            {
                                                movie_title:       modelData.title,
                                                movie_year:        modelData.year,
                                                movie_genre:       modelData.genre,
                                                movie_rating:      modelData.rating,
                                                movie_description: modelData.description,
                                                poster_url:        modelData.poster_url,
                                                video_url:         "",
                                                movie_identifier:  modelData.identifier,
                                                appStack:          homePage.appStack
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // InternetArchive.fetch("charlie chaplin")
    }
}