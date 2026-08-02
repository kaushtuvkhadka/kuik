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




    AudioOutput {
        id: audio_output
        volume: vol_slider.value / 100.0
    }

    //Playback controls haru
    MediaPlayer {
        id: media_player
        source: playerPage.video_url
        videoOutput: video_output
        audioOutput: audio_output

        onPositionChanged: {
            if (!seek_bar.pressed)
                seek_bar.value = media_player.position
        }
        onDurationChanged: {
            if (media_player.duration > 0)
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
        }
    }

    // Controls haru ko overlay
    Item {
        id: controls_overlay
        anchors.fill: parent
        opacity: 1
        Behavior on opacity { NumberAnimation { duration: 350 } }

        // Background MouseArea — shows/hides controls on hover/click
        // Declared FIRST inside overlay so sliders/buttons (declared later) sit on top and receive input
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton
            onPositionChanged: { controls_overlay.opacity = 1; hide_timer.restart() }
            onClicked:         { controls_overlay.opacity = 1; hide_timer.restart() }
        }

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
                    
                    Image {
                        anchors.centerIn: parent
                        width: 18; height: 18
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'><path fill='%23ffffff' d='M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z'/></svg>"
                    }


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

        // Bottom Controls
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width; height: 110
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "#dd000000" }
            }

            // Block mouse events from falling through to the background MouseArea
            // Using propagateComposedEvents so sliders still work
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.NoButton   // Don't accept any clicks — let sliders/buttons handle them
                onPositionChanged: { controls_overlay.opacity = 1; hide_timer.restart() }
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
                    CustomSlider {
                        id: seek_bar
                        Layout.fillWidth: true
                        from: 0
                        to: media_player.duration > 0 ? media_player.duration : 1
                        value: 0

                        function applySeek() {
                            media_player.position = value
                            if (typeof media_player.setPosition === "function") {
                                media_player.setPosition(value)
                            }
                        }

                        onPressedChanged: {
                            if (!pressed) {
                                applySeek()
                            }
                        }
                        onMoved: {
                            applySeek()
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
                        btnIconPath: media_player.playbackState === MediaPlayer.PlayingState 
                                     ? "M6 19h4V5H6v14zm8-14v14h4V5h-4z" // Pause
                                     : "M8 5v14l11-7z"                   // Play

                        onBtnClicked: {
                            if (media_player.playbackState === MediaPlayer.PlayingState)
                                media_player.pause()
                            else
                                media_player.play()
                        }
                    }




                    //Vol button
                    Image {
                        id: vol_icon
                        width: 22; height: 22
                        Layout.alignment: Qt.AlignVCenter
                        property real lastVolume: 80
                        property string p: vol_slider.value === 0 
                                              ? "M16.5 12c0-1.77-1.02-3.29-2.5-4.03v2.21l2.45 2.45c.03-.2.05-.41.05-.63zm2.5 0c0 .94-.2 1.82-.54 2.64l1.51 1.51C20.63 14.91 21 13.5 21 12c0-4.28-2.99-7.86-7-8.77v2.06c2.89.86 5 3.54 5 6.71zM4.27 3L3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.18v2.06c1.38-.31 2.63-.95 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3zM12 4L9.91 6.09 12 8.18V4z"
                                              : (vol_slider.value < 50 
                                                ? "M18.5 12c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM5 9v6h4l5 5V4L9 9H5z" 
                                                : "M3 9v6h4l5 5V4L8 9H3zm13.5 3c0-1.77-1.02-3.29-2.5-4.03v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06c2.89.86 5 3.54 5 6.71s-2.11 5.85-5 6.71v2.06c4.01-.91 7-4.49 7-8.77s-2.99-7.86-7-8.77z")
                        source: "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'><path fill='%23ffffff' d='" + p + "'/></svg>"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (vol_slider.value > 0) {
                                    vol_icon.lastVolume = vol_slider.value
                                    vol_slider.value = 0
                                } else {
                                    vol_slider.value = vol_icon.lastVolume > 0 ? vol_icon.lastVolume : 80
                                }
                            }
                        }
                    }
                    //vol slider
                    CustomSlider {
                        id: vol_slider
                        Layout.preferredWidth: 90
                        Layout.alignment: Qt.AlignVCenter
                        from: 0; to: 100; value: 80
                        onValueChanged: {
                            audio_output.volume = value / 100.0
                        }
                    }





                    //10s back
                    CtrlBtn {
                        btnIconPath: "M11.99 5V1l-5 5 5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6h-2c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8zm-1.1 11h-.85v-3.26l-1.01.31v-.69l1.77-.63h.09V16zm4.28-1.76c0 .32-.03.6-.1.82-.07.23-.17.42-.29.57-.12.15-.27.26-.45.33-.18.07-.39.11-.64.11s-.46-.04-.64-.11-.33-.18-.45-.33-.22-.34-.29-.57-.1-.5-.1-.82v-1.67c0-.32.03-.6.1-.82.07-.22.17-.41.29-.56.12-.14.27-.25.45-.32.18-.07.39-.1.64-.1s.46.03.64.1c.18.07.33.18.45.32.12.15.22.34.29.56.07.22.1.5.1.82v1.67zm-1.42-1.84c-.09-.08-.2-.11-.34-.11-.13 0-.25.04-.33.11-.08.08-.13.19-.16.34-.03.14-.04.33-.04.57v1.89c0 .24.01.44.04.58.03.14.09.25.17.33.08.07.19.11.32.11.14 0 .25-.04.34-.11.08-.07.14-.19.17-.33.03-.14.04-.34.04-.58v-1.89c0-.24-.01-.43-.04-.57-.03-.14-.09-.25-.17-.34z"
                        onBtnClicked: {
                            var target = Math.max(0, media_player.position - 10000)
                            media_player.position = target
                            if (typeof media_player.setPosition === "function") media_player.setPosition(target)
                            seek_bar.value = target
                        }
                    }
                    //10s aagadi
                    CtrlBtn {
                        btnIconPath: "M18 13c0 3.31-2.69 6-6 6s-6-2.69-6-6 2.69-6 6-6v4l5-5-5-5v4c-4.42 0-8 3.58-8 8s3.58 8 8 8 8-3.58 8-8h-2zm-6.28-2.24c-.09-.08-.2-.11-.34-.11-.13 0-.25.04-.33.11-.08.08-.13.19-.16.34-.03.14-.04.33-.04.57v1.89c0 .24.01.44.04.58.03.14.09.25.17.33.08.07.19.11.32.11.14 0 .25-.04.34-.11.08-.07.14-.19.17-.33.03-.14.04-.34.04-.58v-1.89c0-.24-.01-.43-.04-.57-.03-.14-.09-.25-.17-.34zm2.84.82c0 .32-.03.6-.1.82-.07.23-.17.42-.29.57-.12.15-.27.26-.45.33-.18.07-.39.11-.64.11s-.46-.04-.64-.11c-.18-.07-.33-.18-.45-.33-.12-.15-.22-.34-.29-.57-.07-.22-.1-.5-.1-.82v-1.67c0-.32.03-.6.1-.82.07-.22.17-.41.29-.56.12-.14.27-.25.45-.32.18-.07.39-.1.64-.1s.46.03.64.1c.18.07.33.18.45.32.12.15.22.34.29.56.07.22.1.5.1.82v1.67zm-3.32-3.83v-.69l1.77-.63h.09v4.58h-.85v-3.26l-1.01.3z"
                        onBtnClicked: {
                            var target = Math.min(media_player.duration, media_player.position + 10000)
                            media_player.position = target
                            if (typeof media_player.setPosition === "function") media_player.setPosition(target)
                            seek_bar.value = target
                        }
                    }




                    Item { Layout.fillWidth: true }                         //Khali space fill




                    //settings
                    CtrlBtn {
                        btnIconPath: "M19.14,12.94c0.04-0.3,0.06-0.61,0.06-0.94c0-0.32-0.02-0.64-0.06-0.94l2.03-1.58c0.18-0.14,0.23-0.41,0.12-0.61 l-1.92-3.32c-0.12-0.22-0.37-0.29-0.59-0.22l-2.39,0.96c-0.5-0.38-1.03-0.7-1.62-0.94L14.4,2.81c-0.04-0.24-0.24-0.41-0.48-0.41 h-3.84c-0.24,0-0.43,0.17-0.47,0.41L9.25,5.35C8.66,5.59,8.12,5.92,7.63,6.29L5.24,5.33c-0.22-0.08-0.47,0-0.59,0.22L2.73,8.87 C2.62,9.08,2.66,9.34,2.86,9.48l2.03,1.58C4.84,11.36,4.8,11.69,4.8,12s0.02,0.64,0.06,0.94l-2.03,1.58 c-0.18,0.14-0.23,0.41-0.12,0.61l1.92,3.32c0.12,0.22,0.37,0.29,0.59,0.22l2.39-0.96c0.5,0.38,1.03,0.7,1.62,0.94l0.36,2.54 c0.05,0.24,0.24,0.41,0.48,0.41h3.84c0.24,0,0.43-0.17,0.47-0.41l0.36-2.54c0.59-0.24,1.13-0.56,1.62-0.94l2.39,0.96 c0.22,0.08,0.47,0,0.59-0.22l1.92-3.32c0.12-0.22,0.07-0.49-0.12-0.61L19.14,12.94z M12,15.6c-1.98,0-3.6-1.62-3.6-3.6 s1.62-3.6,3.6-3.6s3.6,1.62,3.6,3.6S13.98,15.6,12,15.6z"
                        active: settingsOpen                                //true flase
                        onBtnClicked: settingsOpen = !settingsOpen
                    }


                    CtrlBtn {
                        btnIconPath: "M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z" // Download
                        onBtnClicked: {
                            // Safely invokes the non-static download execution pipeline method inside your ArchiveAPI object model wrapper instance
                            archiveApi.startDownload(playerPage.video_url)
                        }
                    }

                    //fullscreen
                    CtrlBtn {
                        btnIconPath: "M7 14H5v5h5v-2H7v-3zm-2-4h2V7h3V5H5v5zm12 7h-3v2h5v-5h-2v3zM14 5v2h3v3h2V5h-5z"
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
        property string btnIconPath: ""
        property bool   active:  false                                  //button select xa ke nai
        signal btnClicked()

        width: 34; height: 34; radius: 17
        color: active ? "#33e50914"
                      : _ma.containsMouse ? "#33ffffff" : "transparent"

        Behavior on color { ColorAnimation { duration: 120 } }
        Layout.alignment: Qt.AlignVCenter

        Image {
            anchors.centerIn: parent
            width: 20; height: 20
            source: parent.btnIconPath !== "" ? "data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'><path fill='" + (parent.active ? "%23e50914" : "%23ffffff") + "' d='" + parent.btnIconPath + "'/></svg>" : ""
            visible: parent.btnIconPath !== ""
        }
        MouseArea {
            id: _ma
            anchors.fill: parent; hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.btnClicked()
        }
    }

    //*+*+*+*+*+ Custom styled Slider to match the red brand theme natively **+*+*+*+*
    component CustomSlider: Slider {
        id: control
        live: true
        implicitHeight: 28
        focusPolicy: Qt.StrongFocus
        background: Rectangle {
            x: control.leftPadding
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: control.availableWidth
            height: 4
            radius: 2
            color: "#44ffffff"

            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                color: "#e50914"
                radius: 2
            }
        }
        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            width: control.pressed ? 16 : 14
            height: control.pressed ? 16 : 14
            radius: width / 2
            color: "#e50914"
            Behavior on width { NumberAnimation { duration: 100 } }
            Behavior on height { NumberAnimation { duration: 100 } }
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
