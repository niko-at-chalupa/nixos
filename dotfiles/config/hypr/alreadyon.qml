import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Widgets

PanelWindow {
    id: osd

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "osd-workspace"

    implicitWidth: osdBox.implicitWidth + 48
    implicitHeight: osdBox.implicitHeight + 32

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onClicked: (mouse) => { mouse.accepted = false }
    }

    mask: null
    color: "transparent"

    property bool osdVisible: false
    visible: osdVisible

    readonly property int activeWsId: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 0

    readonly property var workspaceNames: [
        "zero", "one", "two", "three", "four", "five",
        "six", "seven", "eight", "nine", "ten"
    ]

    FileView {
        id: flagFile
        path: "/tmp/qs-osd-workspace"
        watchChanges: true
        onFileChanged: {
            osd.osdVisible = true
            hideTimer.restart()
        }
    }

    Timer {
        id: hideTimer
        interval: 600  // was 2000, adjust to taste
        onTriggered: osd.osdVisible = false
    }

    Rectangle {
        id: osdBox
        anchors.centerIn: parent
        implicitWidth: row.implicitWidth + 40
        implicitHeight: row.implicitHeight + 24

        opacity: osd.osdVisible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        radius: 14

        Rectangle {
            id: leftSideSquarePatch
            width: parent.radius
            height: parent.height
            color: parent.color
            anchors.left: parent.left
        }

        color: "#151217"

        Rectangle {
            width: 4
            height: parent.height
            color: "#DDB9F8"
        }

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 40
            anchors.rightMargin: 40
            spacing: 40
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1
            Layout.fillHeight: true

            RowLayout {
                id: row
                anchors.centerIn: parent
                spacing: 14

                ColumnLayout {
                    spacing: -2
                    Text {
                        text: "You're already on"
                        color: "#CECBF6"
                        font.pixelSize: 14
                        Layout.bottomMargin: -3
                    }
                    Text {
                        text: "workspace " + (osd.workspaceNames[osd.activeWsId] || osd.activeWsId) + ","
                        color: "#ffffff"
                        font.pixelSize: 20
                        font.weight: Font.Medium
                    }
                    Text {
                        text: "try again!!"
                        color: "#CECBF6"
                        font.pixelSize: 14
                    }
                }
            }
        }
    }
}
