import QtQuick  // Base module for all QML elements like Rectangle, Text, Image etc

Rectangle {     //Base rectangle for movie card
    id: movieCard
    width: 160
    height: 220
    radius: 8
    color: "#1e1e1e"    //dark gray card background
    clip: true          //cuts off any thing out of boundry

    // property keyword creates a variable that parent can set from outside for us from api
    property string movie_title: "Movie"    //devault value if nothing is passed
    property string movie_year: "2024"
    property string movie_genre: "Genre"
    property real movie_rating: 0.0         // real= decimal number like float in c++
    property string poster_url: ""          // empty = no poster yet

    signal cardClicked()    // signal fires event to whoever is using this card

    // Poster Area
    Rectangle {
        id: poster_area
        anchors.top: parent.top     //stick to top of card
        width: parent.width         //same width as of card
        height: parent.height - 50  //leaves 50x space for text info
        color: "#2a2a2a"            //lighter gray for placeholder

        // Emoji shown when poster image is not available
        Text {
            anchors.centerIn: parent    //centre inside poster area
            text: "🎬"
            font.pixelSize: 36
            visible: poster_url === "" // show only when poster_url is empty
        }

        //Image element loads and displays the poster
        Image {
            anchors.fill: parent    //stretches to fill entire poster_area
            source: movieCard.poster_url    //the poster url
            fillMode: Image.PreserveAspectCrop      //fills area without stretching
            visible: poster_url !== ""      //only when poster url exist
        }
    }

    // Text-Info Area
    Column {        //stacks its childrens vertically
        anchors.top: poster_area.bottom     //sits below poster
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8          // 8px padding in all sides
        spacing: 2      // 2px gap between title and year/genre text

        Text {      // Movie title text
            text: movieCard.movie_title
            color: "#ffffff"        //white text
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight      // Hides long titles with "Movie Ti..."
            width: parent.width         // needed for elide to work
        }

        Text {     //Year and genre
            text: movieCard.movie_year + "." + movieCard.movie_genre
            color: "#888888"    //gray, not appealing like movie_title
            font.pixelSize: 11
            elide: Text.ElideRight
            width: parent.width
        }
    }

    // Hover overlay - Highlighting effect
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "#ffffff"
        opacity: hover_area.containsMouse ? 0.05 : 0    //small tint of 0.05 opacity

        Behavior on opacity {   //Behavior animation transition between 0.05 to 0 instead of directly switching
            NumberAnimation {
                duration: 150   // animation for 150ms
            }
        }
    }

    // Red Left Border - shows which card you are hovering on
    Rectangle {
        width: 3    // thin strip at left edge
        height: parent.height
        color: "#e50914"    //Netflix red accent
        opacity: hover_area.contaionsMouse ? 1:0    //fully visible on Hover

        Behavior on opacity {
            NumberAnimation {
                duration: 150   // animation for 150ms
            }
        }
    }

    // Mouse Area - handles all mouse interactions like clicks, hover detection
    MouseArea {
        id: hover_area      //  id used above by two hover rectangles
        anchors.fill: parent    //covers entire card
        hoverEnabled: true      //needed for containsMouse to work
        cursorShape: Qt.PointingHandCursor      //hand cursor on hover
        onClicked: movieCard.cardClicked()      //fires signal we called above
    }
}
