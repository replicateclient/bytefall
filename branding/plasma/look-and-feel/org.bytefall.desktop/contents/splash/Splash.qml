import QtQuick 2.15

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "#060b10"

    property real fade: 0.0

    Timer {
        interval: 16
        running: true
        repeat: true
        onTriggered: {
            root.fade = Math.min(1, root.fade + 0.02)
        }
    }

    Image {
        id: logo
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -48
        source: "/usr/share/icons/hicolor/scalable/apps/bytefall.svg"
        sourceSize.width: 180
        sourceSize.height: 180
        width: 180
        height: 180
        fillMode: Image.PreserveAspectFit
        opacity: root.fade * (0.92 + 0.08 * Math.sin(spinner.rotation * Math.PI / 180))
    }

    Item {
        id: spinner
        width: 44
        height: 44
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: logo.bottom
        anchors.topMargin: 22

        RotationAnimator on rotation {
            from: 0
            to: 360
            duration: 1200
            loops: Animation.Infinite
            running: true
        }

        Repeater {
            model: 8

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: "#67e8f9"
                opacity: root.fade * (0.25 + (index / 10))
                antialiasing: true
                x: spinner.width / 2 - width / 2 + Math.cos((index / 8) * Math.PI * 2) * 16
                y: spinner.height / 2 - height / 2 + Math.sin((index / 8) * Math.PI * 2) * 16
            }
        }
    }
}
