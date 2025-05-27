import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 1.15

ApplicationWindow {
    // Main application window
    visible: true
    width: 420
    height: 470
    title: "Fifteen Puzzle"
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height
    color: "#2e3440" // Window background color

    // Game area container for the tile grid
    Rectangle {
        id: gameArea
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        width: 370
        height: 370
        radius: 12 // Rounded corners
        color: "#3b4252" // Game area background color
        border.color: "#4c566a" // Border color
        border.width: 1

        // 4x4 grid for the tiles
        Grid {
            id: grid
            columns: 4
            spacing: 8
            anchors.fill: parent
            anchors.margins: 13

            // Create tiles according to gameModel.tiles
            Repeater {
                model: gameModel ? gameModel.tiles.length : 0
                delegate: Rectangle {
                    // Single tile
                    width: 80
                    height: 80
                    radius: 14
                    clip: true

                    // Gradient background for the tile (empty tile is transparent)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: (gameModel && gameModel.tiles[index] === 0) ? "transparent" : "#6aaa2b" }
                        GradientStop { position: 0.5; color: (gameModel && gameModel.tiles[index] === 0) ? "transparent" : "#4a7c33" }
                        GradientStop { position: 1.0; color: (gameModel && gameModel.tiles[index] === 0) ? "transparent" : "#2f4d1a" }
                    }

                    // Tile border (transparent for empty tile)
                    border.color: (gameModel && gameModel.tiles[index] === 0) ? "transparent" : "#1f3310"
                    border.width: (gameModel && gameModel.tiles[index] === 0) ? 0 : 3

                    // Inner highlight for the tile
                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: "transparent"
                        border.color: "#9dd14e"
                        border.width: 1
                        opacity: 0.4
                        anchors.margins: 4
                    }

                    // Simple shadow under the tile for elevation effect
                    Rectangle {
                        anchors.fill: parent
                        radius: 14
                        color: "#00000040"
                        anchors.margins: -2
                        z: -1
                    }

                    // Tile number text
                    Text {
                        anchors.centerIn: parent
                        text: (gameModel && gameModel.tiles[index] !== 0) ? gameModel.tiles[index] : ""
                        font.pixelSize: 34
                        font.bold: true
                        color: "#0f2c09"
                        smooth: true

                        // Text shadow effect
                        Item {
                            anchors.fill: parent
                            z: -1
                            Text {
                                anchors.centerIn: parent
                                text: (gameModel && gameModel.tiles[index] !== 0) ? gameModel.tiles[index] : ""
                                font.pixelSize: 34
                                font.bold: true
                                color: "#00000080"
                                x: 1
                                y: 1
                                smooth: true
                            }
                        }
                    }

                    // Tile click area
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: (gameModel && gameModel.tiles[index] === 0) ? Qt.ArrowCursor : Qt.PointingHandCursor
                        onClicked: {
                            if (gameModel) gameModel.moveTile(index)
                        }
                    }
                }
            }
        }
    }

    // Shuffle button, move counter, and shuffle counter
    // Placed side by side for better visibility
    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: gameArea.bottom
        anchors.topMargin: 20
        spacing: 20

        Button {
            id: shuffleButton
            text: "Shuffle"
            width: 100
            height: 40
            font.pixelSize: 16
            font.bold: true
            onClicked: {
                if (gameModel) gameModel.shuffle()
            }
        }

        Label {
            id: movesLabel
            text: "Moves: " + (gameModel ? gameModel.moves : 0)
            font.pixelSize: 16
            font.bold: true
            color: "#e0e6d4"
        }

        Label {
            id: shufflesLabel
            text: "Shuffles: " + (gameModel ? gameModel.shuffleCount : 0)
            font.pixelSize: 16
            font.bold: true
            color: "#e0e6d4"
        }
    }

    // Modal overlay for win notification
    Rectangle {
        id: modalOverlay
        objectName: "modalOverlay" // For Python to find
        anchors.fill: parent
        color: "#00000080" // Semi-transparent black background
        visible: false // Hidden by default
        z: 1000 // On top of everything

        // Message box inside the overlay
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
                // Vertical layout for message and button
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // Congratulations message
                Label {
                    text: "You solved the puzzle!"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#e0e6d4"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // Close button
                Button {
                    text: "Close"
                    width: 100
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: modalOverlay.visible = false
                }
            }
        }
    }

    // Easter egg modal overlay
    Rectangle {
        id: easterEggModal
        anchors.fill: parent
        color: "#80000000"
        visible: false
        z: 1001

        Rectangle {
            width: 360
            height: 140
            radius: 10
            color: "#4a7c33"
            anchors.centerIn: parent

            ColumnLayout {
                anchors.fill: parent
                spacing: 10
                anchors.margins: 15

                Text {
                    id: eggText
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    color: "#e0e6d4"
                    font.pixelSize: 18
                    font.bold: true
                    wrapMode: Text.Wrap // Enable text wrapping
                }

                Button {
                    text: "Close"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: easterEggModal.visible = false
                }
            }
        }
    }

    // Connection to easter egg signal from Python
    Connections {
        target: gameModel
        function onEasterEggSignal(message) {
            eggText.text = message
            easterEggModal.visible = true
        }
    }
}
