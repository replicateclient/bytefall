import QtQuick 2.15
import calamares.slideshow 1.0

Presentation {
    Slide {
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#09141a" }
                GradientStop { position: 1.0; color: "#050b0f" }
            }

            Image {
                anchors.centerIn: parent
                source: "bytefall.svg"
                width: 230
                height: 230
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }
    }
}
