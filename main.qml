import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: 420
    height: 500
    title: "Пятнашки на PyQt6"
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height
    color: "#2e3440"

    Rectangle {
        id: gameArea
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        width: 370
        height: 370
        radius: 12
        color: "#3b4252"
        border.color: "#4c566a"
        border.width: 1

        Grid {
            id: grid
            columns: 4
            spacing: 8
            anchors.fill: parent
            anchors.margins: 8

            Repeater {
                model: gameModel ? gameModel.tiles.length : 0
                delegate: Rectangle {
                    width: 80
                    height: 80
                    radius: 12
                    clip: true

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: gameModel.tiles[index] === 0 ? "transparent" : "#4a7c33" }
                        GradientStop { position: 1.0; color: gameModel.tiles[index] === 0 ? "transparent" : "#2f4d1a" }
                    }

                    border.color: gameModel.tiles[index] === 0 ? "transparent" : "#2a3b11"
                    border.width: gameModel.tiles[index] === 0 ? 0 : 2

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 10
                        color: "transparent"
                        border.color: "white"
                        border.width: 1
                        opacity: gameModel.tiles[index] === 0 ? 0 : 0.25
                    }

                    Text {
                        anchors.centerIn: parent
                        text: gameModel.tiles[index] === 0 ? "" : gameModel.tiles[index]
                        font.pixelSize: 32
                        font.bold: true
                        color: "#e0e6d4"
                        smooth: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: gameModel.tiles[index] === 0 ? Qt.ArrowCursor : Qt.PointingHandCursor
                        onClicked: gameModel.moveTile(index)
                    }
                }
            }
        }
    }

    Button {
        text: "Перемешать"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: gameArea.bottom
        anchors.topMargin: 25
        width: 120
        height: 40
        font.pixelSize: 16
        onClicked: gameModel.shuffle()
    }

    Rectangle {
        id: modalOverlay
        anchors.fill: parent
        color: "#00000080"
        visible: false
        z: 1000

        Rectangle {
            id: messageBox
            width: 280
            height: 120
            radius: 12
            color: "#4a7c33"
            border.color: "#2f4d1a"
            border.width: 2
            anchors.centerIn: parent

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Label {
                    text: "Вы собрали все плитки!"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#e0e6d4"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: "Закрыть"
                    width: 100
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: modalOverlay.visible = false
                }
            }
        }
    }

    Connections {
        target: gameModel
        function onGameWon() {
            modalOverlay.visible = true
        }
    }
}
