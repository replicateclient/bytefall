import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    title: "Bytefall Welcome"
    width: 920
    height: 660
    minimumWidth: 860
    minimumHeight: 620
    property bool liveSession: Launcher.isLiveSession()
    property string selectedGpu: liveSession ? Launcher.gpuSelection() : "none"
    property string recommendedGpu: Launcher.recommendedGpuSelection()
    property string gpuSummary: Launcher.detectedGpuSummary()
    property bool gpuChoiceComplete: !liveSession || selectedGpu.length > 0
    property bool showGpuLockHint: false

    onClosing: function(close) {
        if (liveSession && !gpuChoiceComplete) {
            close.accepted = false
            showGpuLockHint = true
        }
    }

    pageStack.initialPage: Kirigami.Page {
        id: page
        padding: 0

        background: Rectangle {
            color: "#071015"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.gridUnit * 1.5
            spacing: Kirigami.Units.smallSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.gridUnit

                Image {
                    source: "file:///usr/share/icons/hicolor/scalable/apps/bytefall.svg"
                    sourceSize.width: 88
                    sourceSize.height: 88
                    Layout.preferredWidth: 88
                    Layout.preferredHeight: 88
                    fillMode: Image.PreserveAspectFit
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Kirigami.Heading {
                        text: "Welcome to Bytefall"
                        level: 1
                        color: "#effaff"
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        text: liveSession
                            ? "Set up the install profile, then start the installer."
                            : "Bytefall is installed and ready. Keep this welcome screen on startup or turn it off below."
                        color: "#abc2ca"
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: liveSession
                radius: 14
                color: "#0c171d"
                border.color: showGpuLockHint && !gpuChoiceComplete ? "#6ee7ff" : "#1d313a"
                border.width: 1

                ColumnLayout {
                    id: contentColumn
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.gridUnit
                    spacing: Kirigami.Units.smallSpacing

                    RowLayout {
                        Layout.fillWidth: true

                        Kirigami.Heading {
                            text: "Graphics"
                            level: 3
                            color: "#f1fbff"
                        }

                        Item { Layout.fillWidth: true }

                        Controls.Label {
                            text: recommendedGpu.length > 0 && recommendedGpu !== "none"
                                ? "Recommended: " + recommendedGpu.toUpperCase()
                                : "Recommended: AUTO"
                            color: "#71dfff"
                        }
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        text: gpuSummary
                        color: "#9cb7c1"
                        wrapMode: Text.WordWrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 1
                        rowSpacing: Kirigami.Units.smallSpacing
                        columnSpacing: 0

                        Repeater {
                            model: [
                                {
                                    key: "auto",
                                    title: "Auto",
                                    body: "Detect the current GPU and install the matching driver stack."
                                },
                                {
                                    key: "amd",
                                    title: "AMD",
                                    body: "Mesa OpenGL and Vulkan Radeon."
                                },
                                {
                                    key: "nvidia",
                                    title: "NVIDIA",
                                    body: "NVIDIA drivers, OpenGL, Vulkan, and Wayland support."
                                },
                                {
                                    key: "none",
                                    title: "None",
                                    body: "Skip dedicated AMD or NVIDIA packages."
                                }
                            ]

                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.minimumHeight: optionRow.implicitHeight + Kirigami.Units.gridUnit * 0.75
                                radius: 10
                                color: selectedGpu === modelData.key ? "#0f2028" : "#0a141a"
                                border.color: selectedGpu === modelData.key ? "#56d7f7" : "#1a2c34"
                                border.width: 1

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        selectedGpu = modelData.key
                                        Launcher.setGpuSelection(modelData.key)
                                        showGpuLockHint = false
                                    }
                                }

                                RowLayout {
                                    id: optionRow
                                    anchors.fill: parent
                                    anchors.margins: Kirigami.Units.smallSpacing * 1.75
                                    spacing: Kirigami.Units.smallSpacing

                                    Controls.RadioButton {
                                        checked: selectedGpu === modelData.key
                                        onClicked: {
                                            selectedGpu = modelData.key
                                            Launcher.setGpuSelection(modelData.key)
                                            showGpuLockHint = false
                                        }
                                    }

                                    Controls.Label {
                                        text: modelData.title
                                        color: "#ecf7fb"
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        Layout.preferredWidth: 68
                                    }

                                    Controls.Label {
                                        Layout.fillWidth: true
                                        text: modelData.body
                                        color: "#8da7b0"
                                        wrapMode: Text.WordWrap
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        visible: showGpuLockHint && !gpuChoiceComplete
                        text: "Pick Auto, AMD, NVIDIA, or None before closing this window."
                        color: "#8be9ff"
                        wrapMode: Text.WordWrap
                    }
                }
            }

            Controls.Label {
                Layout.fillWidth: true
                visible: !liveSession
                text: "You can keep this welcome screen on startup or turn it off below."
                color: "#7f99a3"
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.gridUnit

                Controls.Button {
                    Layout.alignment: Qt.AlignLeft
                    text: "Install Bytefall"
                    icon.name: "system-software-install"
                    highlighted: true
                    visible: liveSession
                    enabled: gpuChoiceComplete
                    Layout.preferredWidth: 220
                    onClicked: {
                        if (Launcher.launchInstaller()) {
                            Qt.quit()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                Controls.CheckBox {
                    Layout.alignment: Qt.AlignRight
                    text: "Show on startup"
                    checked: Launcher.autostartEnabled()
                    onToggled: Launcher.setAutostartEnabled(checked)
                }
            }
        }
    }
}
