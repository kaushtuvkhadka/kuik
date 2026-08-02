import QtQuick

Item {
    id: spinner
    width: 48
    height: 48

    property color spinnerColor: "#e50914"

    // Outer track (grey ring)
    Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        radius: width / 2
        color: "transparent"
        border.color: "#2a2a2a"
        border.width: 4
    }

    // Spinning arc
    Rectangle {
        id: arc
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        radius: width / 2
        color: "transparent"
        border.color: spinner.spinnerColor
        border.width: 4
        layer.enabled: true

        Rectangle {
            x: parent.width / 2
            y: 0
            width: parent.width / 2
            height: parent.height / 2
            color: "#0f0f0f"
        }

        RotationAnimator {
            target: arc
            from: 0
            to: 360
            duration: 900
            loops: Animation.Infinite
            running: spinner.visible
        }
    }
}
