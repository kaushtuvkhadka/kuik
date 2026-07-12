import QtQuick

Rectangle {
    id: movieCard
    width: 160
    height: 240
    radius: 8
    color: "#1e1e1e"
    clip: true

    property string movie_title:  "Movie"
    property string movie_year:   "2024"
    property string movie_genre:  "Genre"
    property real   movie_rating: 0.0
    property string poster_url:   ""

    signal cardClicked()

    // Poster area
    Rectangle {
        id: poster_area
        anchors.top: parent.top
        width: parent.width
        height: parent.height - 60
        color: "#2a2a2a"

        // Placeholder shown while image loads or is missing
        Text {
            anchors.centerIn: parent
            text: "🎬"
            font.pixelSize: 36
            visible: poster_url === "" || poster_img.status === Image.Error ||
                     poster_img.status === Image.Loading
        }

        Image {
            id: poster_img
            anchors.fill: parent
            source: movieCard.poster_url
            fillMode: Image.PreserveAspectCrop
            visible: source !== "" && status === Image.Ready

            // Fade in when loaded
            opacity: 0
            onStatusChanged:{
                if (status === Image.Ready){
                    fadeIn.start()
                }

                else if(status == Image.Error){                           //Poster load bhayena bhane yo print hunxa
                    console.error("[MovieCard] Poster failed to load:", movieCard.movie_title, "->", movieCard.poster_url)
                }
            }
            NumberAnimation on opacity {
                id: fadeIn
                to: 1
                duration: 300
                running: false
            }
        }

        // Rating badge top-right
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 6
            width: 38
            height: 20
            radius: 4
            color: "#cc000000"
            visible: movieCard.movie_rating > 0

            Text {
                anchors.centerIn: parent
                text: "★ " + movieCard.movie_rating
                color: "#ffcc00"
                font.pixelSize: 10
                font.bold: true
            }
        }
    }

    // Text info area
    Column {
        anchors.top: poster_area.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8
        spacing: 3

        Text {
            text: movieCard.movie_title
            color: "#ffffff"
            font.pixelSize: 12
            font.bold: true
            elide: Text.ElideRight
            width: parent.width
        }

        Text {
            text: (movieCard.movie_year !== "" ? movieCard.movie_year : "—") +
                  " · " + movieCard.movie_genre
            color: "#888888"
            font.pixelSize: 10
            elide: Text.ElideRight
            width: parent.width
        }
    }

    // Hover overlay
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "#ffffff"
        opacity: hover_area.containsMouse ? 0.07 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // Red left border accent on hover
    Rectangle {
        width: 3
        height: parent.height
        color: "#e50914"
        opacity: hover_area.containsMouse ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
        id: hover_area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: movieCard.cardClicked()
    }
}
