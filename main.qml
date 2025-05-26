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

    Rectangle {
        // Game area container for the tile grid
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

        Grid {
            // 4x4 grid for the tiles
            id: grid
            columns: 4
            spacing: 8
            anchors.fill: parent
            anchors.margins: 8

            Repeater {
                // Create tiles according to gameModel.tiles
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

                    Rectangle {
                        // Inner highlight for the tile
                        anchors.fill: parent
                        radius: 14
                        color: "transparent"
                        border.color: "#9dd14e"
                        border.width: 1
                        opacity: 0.4
                        anchors.margins: 4
                    }

                    Rectangle {
                        // Simple shadow under the tile for elevation effect
                        anchors.fill: parent
                        radius: 14
                        color: "#00000040"
                        anchors.margins: -2
                        z: -1
                    }

                    Text {
                        // Tile number text
                        anchors.centerIn: parent
                        text: (gameModel && gameModel.tiles[index] !== 0) ? gameModel.tiles[index] : ""
                        font.pixelSize: 34
                        font.bold: true
                        color: "#e0e6d4"
                        smooth: true

                        Item {
                            // Text shadow effect
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

                    MouseArea {
                        // Tile click area
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

    Button {
        // Shuffle button
        text: "Shuffle"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: gameArea.bottom
        anchors.topMargin: 25
        width: 140
        height: 40
        font.pixelSize: 16
        onClicked: {
            if (gameModel) gameModel.shuffle()
        }
    }

    Label {
        // Move counter label
        text: "Moves: " + (gameModel ? gameModel.moves : 0)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.children[parent.children.length - 2].bottom
        anchors.topMargin: 10
        font.pixelSize: 16
        color: "#e0e6d4"
    }

    Rectangle {
        // Modal overlay for win notification
        id: modalOverlay
        objectName: "modalOverlay" // For Python to find
        anchors.fill: parent
        color: "#00000080" // Semi-transparent black background
        visible: false // Hidden by default
        z: 1000 // On top of everything

        Rectangle {
            // Message box inside the overlay
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

                Label {
                    // Congratulations message
                    text: "You solved the puzzle!"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#e0e6d4"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    // Close button
                    text: "Close"
                    width: 100
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: modalOverlay.visible = false
                }
            }
        }
    }
}
