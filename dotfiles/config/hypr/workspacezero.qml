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
    WlrLayershell.namespace: "osd-workspace-zero"
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

    FileView {
        id: flagFile
        path: "/tmp/qs-workspace-zero"
        watchChanges: true
        onFileChanged: {
            osd.osdVisible = true
            hideTimer.restart()
        }
    }
    Timer {
        id: hideTimer
        interval: 600
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
                        text: "You're already at the"
                        color: "#CECBF6"
                        font.pixelSize: 14
                        Layout.bottomMargin: -3
                    }
                    Text {
                        text: "first workspace."
                        color: "#ffffff"
                        font.pixelSize: 20
                        font.weight: Font.Medium
                    }
                    Text {
                        text: "You can't go back further!!"
                        color: "#CECBF6"
                        font.pixelSize: 14
                    }
                }
            }
        }
    }
}
