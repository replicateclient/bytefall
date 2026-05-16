import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Kirigami.ApplicationWindow {
    id: root
    title: "Bytefall Welcome"
    width: 960
    height: 700
    minimumWidth: 900
    minimumHeight: 660

    property bool liveSession: Launcher.isLiveSession()
    property int step: 0
    property string selectedGpu: liveSession ? Launcher.gpuSelection() : "none"
    property string selectedProfile: liveSession ? Launcher.installProfileSelection() : "default"
    property string recommendedGpu: Launcher.recommendedGpuSelection()
    property string gpuSummary: Launcher.detectedGpuSummary()
    property bool gpuChoiceComplete: !liveSession || selectedGpu.length > 0
    property bool profileChoiceComplete: !liveSession || selectedProfile.length > 0
    property bool setupComplete: !liveSession || (gpuChoiceComplete && profileChoiceComplete)
    property bool showLockHint: false

    readonly property var stepItems: [
        { step: 0, title: "Welcome" },
        { step: 1, title: "Graphics" },
        { step: 2, title: "Profile" }
    ]

    onClosing: function(close) {
        if (liveSession && !setupComplete) {
            close.accepted = false
            showLockHint = true
        }
    }

    pageStack.initialPage: Kirigami.Page {
        padding: 0

        background: Rectangle {
            color: "#071015"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.gridUnit * 1.5
            spacing: Kirigami.Units.gridUnit

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.gridUnit

                Image {
                    source: "file:///usr/share/icons/hicolor/scalable/apps/bytefall.svg"
                    sourceSize.width: 72
                    sourceSize.height: 72
                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 72
                    fillMode: Image.PreserveAspectFit
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Kirigami.Heading {
                        text: "Bytefall 0.1 Aurora"
                        level: 1
                        color: "#effaff"
                    }

                    Controls.Label {
                        Layout.fillWidth: true
                        text: liveSession
                            ? "Finish the quick setup, then install Bytefall to disk."
                            : "Bytefall is installed. You can keep this screen on startup or turn it off below."
                        color: "#a9c3cc"
                        wrapMode: Text.WordWrap
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: liveSession
                spacing: Kirigami.Units.smallSpacing

                Repeater {
                    model: root.stepItems

                    delegate: Rectangle {
                        required property var modelData
                        property int stepIndex: modelData.step

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        radius: 8
                        color: root.step === stepIndex ? "#11242c" : "#0a151a"
                        border.color: root.step === stepIndex ? "#6ee7ff" : "#1b3038"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Kirigami.Units.smallSpacing

                            Rectangle {
                                Layout.preferredWidth: 18
                                Layout.preferredHeight: 18
                                radius: 9
                                color: root.step > stepIndex ? "#65dfff" : "transparent"
                                border.color: root.step >= stepIndex ? "#65dfff" : "#4a6570"
                                border.width: 1

                                Controls.Label {
                                    anchors.centerIn: parent
                                    text: root.step > stepIndex ? "OK" : String(stepIndex + 1)
                                    color: root.step > stepIndex ? "#041014" : "#dff9ff"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }
                            }

                            Controls.Label {
                                text: modelData.title
                                color: "#e8f7fb"
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: "#0b171d"
                border.color: showLockHint && !setupComplete ? "#6ee7ff" : "#1b3038"
                border.width: 1

                Item {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.gridUnit * 1.25

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Kirigami.Units.gridUnit
                        visible: !liveSession || root.step === 0

                        Item { Layout.fillHeight: true }

                        Image {
                            source: "file:///usr/share/icons/hicolor/scalable/apps/bytefall.svg"
                            sourceSize.width: 148
                            sourceSize.height: 148
                            Layout.preferredWidth: 148
                            Layout.preferredHeight: 148
                            Layout.alignment: Qt.AlignHCenter
                            fillMode: Image.PreserveAspectFit
                        }

                        Kirigami.Heading {
                            text: "Welcome to Bytefall"
                            level: 2
                            color: "#effaff"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Controls.Label {
                            Layout.maximumWidth: 660
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: "Bytefall is an Arch-based KDE system shaped for a clean workstation: fast tools, sharp visuals, and a setup that stays reproducible."
                            color: "#a9c3cc"
                            wrapMode: Text.WordWrap
                        }

                        Controls.Label {
                            Layout.maximumWidth: 620
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            visible: liveSession
                            text: "The next two steps choose graphics drivers and the installed system profile."
                            color: "#75dfff"
                            wrapMode: Text.WordWrap
                        }

                        Item { Layout.fillHeight: true }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Kirigami.Units.gridUnit
                        visible: liveSession && root.step === 1

                        RowLayout {
                            Layout.fillWidth: true

                            Kirigami.Heading {
                                text: "Graphics Driver"
                                level: 2
                                color: "#effaff"
                            }

                            Item { Layout.fillWidth: true }

                            Controls.Label {
                                text: recommendedGpu.length > 0 && recommendedGpu !== "none"
                                    ? "Recommended: " + recommendedGpu.toUpperCase()
                                    : "Recommended: AUTO"
                                color: "#75dfff"
                            }
                        }

                        Controls.Label {
                            Layout.fillWidth: true
                            text: gpuSummary
                            color: "#9fb8c1"
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: Kirigami.Units.smallSpacing

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
                                        body: "Install Mesa OpenGL and Vulkan Radeon packages."
                                    },
                                    {
                                        key: "nvidia",
                                        title: "NVIDIA",
                                        body: "Install NVIDIA drivers, settings, OpenGL, Vulkan, and Wayland support."
                                    },
                                    {
                                        key: "none",
                                        title: "None",
                                        body: "Skip dedicated AMD or NVIDIA packages."
                                    }
                                ]

                                delegate: OptionRow {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    checked: root.selectedGpu === modelData.key
                                    title: modelData.title
                                    body: modelData.body
                                    onPicked: {
                                        root.selectedGpu = modelData.key
                                        Launcher.setGpuSelection(modelData.key)
                                        root.showLockHint = false
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: Kirigami.Units.gridUnit
                        visible: liveSession && root.step === 2

                        Kirigami.Heading {
                            text: "Install Profile"
                            level: 2
                            color: "#effaff"
                        }

                        Controls.Label {
                            Layout.fillWidth: true
                            text: "Choose what the installed Bytefall system should become."
                            color: "#9fb8c1"
                            wrapMode: Text.WordWrap
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: Kirigami.Units.smallSpacing

                            Repeater {
                                model: [
                                    {
                                        key: "default",
                                        title: "Default Bytefall",
                                        body: "Lean Plasma desktop with everyday apps, fast utilities, Bytefall visuals, and no heavy dev stack."
                                    },
                                    {
                                        key: "dev",
                                        title: "Dev Bytefall",
                                        body: "Full workstation profile with VS Code, Python, CMake, compilers, containers, VMs, and debugging tools."
                                    },
                                    {
                                        key: "server",
                                        title: "Server Bytefall",
                                        body: "Lightweight LXQt desktop for services. Removes Plasma, wallpapers, workstation apps, and dev tools."
                                    }
                                ]

                                delegate: OptionRow {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    checked: root.selectedProfile === modelData.key
                                    title: modelData.title
                                    body: modelData.body
                                    onPicked: {
                                        root.selectedProfile = modelData.key
                                        Launcher.setInstallProfileSelection(modelData.key)
                                        root.showLockHint = false
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Controls.Label {
                Layout.fillWidth: true
                visible: showLockHint && !setupComplete
                text: "Finish the graphics and profile steps before closing this window or starting the installer."
                color: "#8be9ff"
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.gridUnit

                Controls.Button {
                    text: "Back"
                    icon.name: "go-previous"
                    visible: liveSession && root.step > 0
                    onClicked: root.step -= 1
                }

                Item { Layout.fillWidth: true }

                Controls.CheckBox {
                    text: "Show on startup"
                    visible: !liveSession
                    checked: Launcher.autostartEnabled()
                    onToggled: Launcher.setAutostartEnabled(checked)
                }

                Controls.Button {
                    text: root.step === 0 ? "Start" : "Next"
                    icon.name: root.step === 0 ? "go-next" : "go-next"
                    visible: liveSession && root.step < 2
                    enabled: root.step === 0 || (root.step === 1 && gpuChoiceComplete)
                    onClicked: root.step += 1
                }

                Controls.Button {
                    text: "Install Bytefall"
                    icon.name: "system-software-install"
                    highlighted: true
                    visible: liveSession && root.step === 2
                    enabled: setupComplete
                    Layout.preferredWidth: 210
                    onClicked: {
                        if (Launcher.launchInstaller()) {
                            Qt.quit()
                        }
                    }
                }
            }
        }
    }

    component OptionRow: Rectangle {
        id: option

        signal picked()

        property bool checked: false
        property string title: ""
        property string body: ""

        Layout.minimumHeight: 86
        radius: 10
        color: checked ? "#10242c" : "#09151a"
        border.color: checked ? "#65dfff" : "#1b3038"
        border.width: 1

        MouseArea {
            anchors.fill: parent
            onClicked: option.picked()
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.gridUnit * 0.75
            spacing: Kirigami.Units.smallSpacing

            Controls.RadioButton {
                checked: option.checked
                onClicked: option.picked()
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Controls.Label {
                    text: option.title
                    color: "#edfaff"
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                }

                Controls.Label {
                    Layout.fillWidth: true
                    text: option.body
                    color: "#9fb8c1"
                    font.pixelSize: 13
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
