import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia


Item {
    id: playerPage


    //DetailsPage bata aako properties haru
    property var    appStack:    null
    property string video_url:   ""                                 //Video url save
    property string movie_title: ""

    //Features haru
    property bool  settingsOpen:  false
    property real  playbackSpeed: 1.0


    //Background
    Rectangle {
        anchors.fill: parent                                        //entire page lai cover garxa
        color: "#000000"
    }



    //Playback controls haru
    MediaPlayer {
        id: media_player
        source: playerPage.video_url
        videoOutput: video_output
        audioOutput: AudioOutput {
            volume: vol_slider.value / 100.
        }

        onPositionChanged: {
            if (!seek_bar.pressed)
                seek_bar.value = media_player.position
        }
        onDurationChanged: {
            seek_bar.to = media_player.duration
        }
        onPlaybackStateChanged: {
            hide_timer.restart()                                    //controls auto hide hune timer
            controls_overlay.opacity = 1
        }
        onErrorOccurred: function(error, errorString) {
            error_text.text = "Playback error: " + errorString
            error_banner.visible = true
        }
    }

    //Vid ko surface
    VideoOutput {
        id: video_output
        anchors.fill: parent
    }

    //progress bar auto hide garne
    Timer {
        id: hide_timer
        interval: 3500
        running: true
        repeat: false
        onTriggered: {
            if (media_player.playbackState === MediaPlayer.PlayingState)
                controls_overlay.opacity = 0
        }
    }


    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onPositionChanged: { controls_overlay.opacity = 1; hide_timer.restart() }
        onClicked:         { controls_overlay.opacity = 1; hide_timer.restart() }
    }


    Rectangle {
        id: error_banner
        visible: false
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 80

        width: error_text.width + 40
        height: 40
        radius: 6                                                             //Error text ko looks
        color: "#cc330000"
        border.color: "#e50914"
        border.width: 1
        z: 20

        Text {
            id: error_text
            anchors.centerIn: parent
            color: "#ffaaaa"
            font.pixelSize: 13
        }
        MouseArea {
            anchors.fill: parent
            onClicked: error_banner.visible = false
        }
    }

    //Setting panel features haru
    Rectangle {
        id: settings_panel
        width: 230
        height: settings_col.implicitHeight + 32
        radius: 10
        color: "#f0111111"
        border.color: "#2a2a2a"
        border.width: 1
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 118
        anchors.rightMargin: 20
        z: 10
        visible: settingsOpen
        opacity: settingsOpen ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }

        Column {
            id: settings_col
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 20

            Text { text: "Settings"; color: "#ffffff"; font.pixelSize: 13; font.bold: true }

            //Speed controls
            Column {
                width: parent.width
                spacing: 8
                Text { text: "Playback Speed"; color: "#aaaaaa"; font.pixelSize: 11 }
                Row {
                    spacing: 6
                    Repeater {
                        model: [
                            { label: "0.5×",  rate: 0.5  },
                            { label: "0.75×", rate: 0.75 },
                            { label: "1×",    rate: 1.0  },
                            { label: "1.5×",  rate: 1.5  },
                            { label: "2×",    rate: 2.0  }
                        ]
                        Rectangle {
                            width: sp_lbl.width + 14; height: 26; radius: 13
                            color: playerPage.playbackSpeed === modelData.rate ? "#e50914" : "#2a2a2a"
                            border.color: playerPage.playbackSpeed === modelData.rate ? "#e50914" : "#3a3a3a"
                            border.width: 1
                            Text {
                                id: sp_lbl
                                anchors.centerIn: parent
                                text: modelData.label; color: "#ffffff"; font.pixelSize: 11
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    playerPage.playbackSpeed  = modelData.rate
                                    media_player.playbackRate = modelData.rate
                                }
                            }
                        }
                    }
                }
            }

            //Settings ma volume, bahira already xa so paxi remove
            Column {
                width: parent.width
                spacing: 8
                Text { text: "Volume  " + Math.round(vol_slider.value) + "%"; color: "#aaaaaa"; font.pixelSize: 11 }

                Slider {
                    id: settings_vol
                    width: parent.width
                    from: 0; to: 100; value: vol_slider.value
                    onValueChanged: vol_slider.value = value
                }
            }
        }
    }

    // Controls haru ko overlay
    Item {
        id: controls_overlay
        anchors.fill: parent
        opacity: 1
        Behavior on opacity { NumberAnimation { duration: 350 } }


        Rectangle {
            anchors.top: parent.top
            width: parent.width; height: 80
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#bb000000" }                              //Overlay ko background
                GradientStop { position: 1.0; color: "transparent" }
            }
            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 16
                spacing: 12

                // Back button
                Rectangle {
                    width: 32; height: 32; radius: 16
                    color: back_ma.containsMouse ? "#44ffffff" : "transparent"                  //Highliht hunxa mouse hover garda
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { anchors.centerIn: parent; text: "◀"; color: "#fff"; font.pixelSize: 14 }


                    MouseArea {
                        id: back_ma
                        anchors.fill: parent; hoverEnabled: true                            //Mouse le click garne banaune
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            media_player.stop()
                            if (playerPage.appStack)
                                playerPage.appStack.pop()                               //Back to previos page
                        }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: playerPage.movie_title
                    color: "#ffffff"; font.pixelSize: 15; font.bold: true
                    elide: Text.ElideRight                                                 //Screen bahira text jana didaina
                    width: playerPage.width - 180
                }
            }
        }

        // ── Bottom gradient + controls ─────────────────────────────────
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 110
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "#dd000000" }
            }

            Column {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                anchors.bottomMargin: 12
                spacing: 4

                //Seek bar
                RowLayout {
                    width: parent.width
                    spacing: 10

                    Text {
                        text: formatTime(media_player.position)
                        color: "#ffffff"; font.pixelSize: 12
                        Layout.preferredWidth: 45
                    }

                    //Time jummp garxa, bar ma click garyo bhane skip to there
                    Slider {
                        id: seek_bar
                        Layout.fillWidth: true
                        from: 0; to: 1; value: 0
                        onPressedChanged: {
                            if (!pressed) media_player.position = value
                        }
                    }

                    Text {
                        text: formatTime(media_player.duration)             //total duration media ko format garera
                        color: "#888888"; font.pixelSize: 12
                        Layout.preferredWidth: 45
                        horizontalAlignment: Text.AlignRight
                    }
                }


                RowLayout {
                    width: parent.width
                    spacing: 2

                    //Buttons haru
                    CtrlBtn {
                        btnIcon: media_player.playbackState === MediaPlayer.PlayingState ? "⭕" : "▶"

                        onBtnClicked: {
                            if (media_player.playbackState === MediaPlayer.PlayingState)
                                media_player.pause()
                            else
                                media_player.play()
                        }
                    }

                    //10s back
                    CtrlBtn {
                        btnIcon: "↺"
                        onBtnClicked: media_player.position = Math.max(0, media_player.position - 10000)            //Math le media cap rakhxa
                    }

                    //10s aagadi
                    CtrlBtn {
                        btnIcon: "↻"
                        onBtnClicked: media_player.position = Math.min(media_player.duration, media_player.position + 10000)
                    }



                    Item { Layout.fillWidth: true }                         //Khali space fill


                    //Vol button
                    Text {
                        text: vol_slider.value === 0 ? "🔇" : vol_slider.value < 50 ? "🔉" : "🔊"
                        color: "#ffffff"; font.pixelSize: 15
                        Layout.alignment: Qt.AlignVCenter
                    }

                    //vol slider
                    Slider {
                        id: vol_slider
                        width: 80; from: 0; to: 100; value: 80                      //80 ma initiate hunxa
                        Layout.alignment: Qt.AlignVCenter
                    }

                    //settings
                    CtrlBtn {
                        btnIcon: "⚙"
                        active: settingsOpen                                //true flase
                        onBtnClicked: settingsOpen = !settingsOpen
                    }

                    //fullscreen
                    CtrlBtn {
                        btnIcon: "⛶"
                        onBtnClicked: {
                            var w = Window.window
                            w.visibility = w.visibility === Window.FullScreen
                                           ? Window.Maximized
                                           : Window.FullScreen
                        }
                    }
                }
            }
        }
    }


    component CtrlBtn: Rectangle {
        property string btnIcon: ""
        property bool   active:  false                                  //button select xa ke nai
        signal btnClicked()

        width: 34; height: 34; radius: 17
        color: active ? "#33e50914"
                      : _ma.containsMouse ? "#33ffffff" : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }
        Layout.alignment: Qt.AlignVCenter

        Text {
            anchors.centerIn: parent
            text: parent.btnIcon
            color: parent.active ? "#e50914" : "#ffffff"
            font.pixelSize: 16
        }
        MouseArea {
            id: _ma
            anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.btnClicked()
        }
    }

    //time format
    function formatTime(ms) {
        if (ms <= 0) return "00:00"
        var s   = Math.floor(ms / 1000)
        var h   = Math.floor(s / 3600)
        var m   = Math.floor((s % 3600) / 60)
        var sec = s % 60
        var mm  = m   < 10 ? "0" + m   : m
        var ss  = sec < 10 ? "0" + sec : sec
        if (h > 0) return (h < 10 ? "0" + h : h) + ":" + mm + ":" + ss
        return mm + ":" + ss
    }

    Component.onCompleted: {
        if (video_url !== "") media_player.play()
    }
}
