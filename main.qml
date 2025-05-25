import QtQuick 6.2
import QtQuick.Controls 6.2
import QtQuick.Layouts 1.15

ApplicationWindow {
    // Основное окно приложения
    visible: true
    width: 420
    height: 500
    title: "Пятнашки на PyQt6"
    minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height
    color: "#2e3440" // Цвет фона окна

    Rectangle {
        // Область с игрой — контейнер для сетки плиток
        id: gameArea
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 20
        width: 370
        height: 370
        radius: 12 // Скругление углов
        color: "#3b4252" // Цвет фона игрового поля
        border.color: "#4c566a" // Цвет рамки
        border.width: 1

        Grid {
            // Сетка 4x4 для плиток
            id: grid
            columns: 4
            spacing: 8
            anchors.fill: parent
            anchors.margins: 8

            Repeater {
                // Создаёт плитки по количеству элементов в gameModel.tiles
                model: gameModel ? gameModel.tiles.length : 0
                delegate: Rectangle {
                    // Одна плитка
                    width: 80
                    height: 80
                    radius: 14
                    clip: true

                    // Градиентный фон плитки для объёма
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: (gameModel && gameModel.tiles[index] === 0) ? "transparent" : "#6aaa2b" }
                        GradientStop { position: 0.5; color: (gameModel && gameModel.tiles[index] === 0) ? "transparent" : "#4a7c33" }
                        GradientStop { position: 1.0; color: (gameModel && gameModel.tiles[index] === 0) ? "transparent" : "#2f4d1a" }
                    }

                    // Рамка плитки, прозрачная для пустой плитки
                    border.color: (gameModel && gameModel.tiles[index] === 0) ? "transparent" : "#1f3310"
                    border.width: (gameModel && gameModel.tiles[index] === 0) ? 0 : 3

                    Rectangle {
                        // Внутренний светлый контур для создания объёма
                        anchors.fill: parent
                        radius: 14
                        color: "transparent"
                        border.color: "#9dd14e"
                        border.width: 1
                        opacity: 0.4
                        anchors.margins: 4
                    }

                    Rectangle {
                        // Простая тень под плиткой для эффекта подъёма
                        anchors.fill: parent
                        radius: 14
                        color: "#00000040"
                        anchors.margins: -2
                        z: -1
                    }

                    Text {
                        // Текст с номером плитки
                        anchors.centerIn: parent
                        text: (gameModel && gameModel.tiles[index] !== 0) ? gameModel.tiles[index] : ""
                        font.pixelSize: 34
                        font.bold: true
                        color: "#e0e6d4"
                        smooth: true

                        Item {
                            // Тень текста — дублирующий текст с небольшим сдвигом
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
                        // Область взаимодействия для кликов по плитке
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
        // Кнопка для перемешивания плиток
        text: "Перемешать"
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

    Rectangle {
        // Модальное окно с сообщением о победе
        id: modalOverlay
        objectName: "modalOverlay" // Имя для поиска из Python
        anchors.fill: parent
        color: "#00000080" // Полупрозрачный чёрный фон
        visible: false // Скрыто по умолчанию
        z: 1000 // Поверх всего

        Rectangle {
            // Окно с сообщением внутри модального фона
            id: messageBox
            width: 280
            height: 120
            radius: 12
            color: "#4a7c33"
            border.color: "#2f4d1a"
            border.width: 2
            anchors.centerIn: parent

            ColumnLayout {
                // Вертикальный лэйаут для текста и кнопки
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Label {
                    // Текст поздравления
                    text: "Вы собрали все плитки!"
                    font.pixelSize: 20
                    font.bold: true
                    color: "#e0e6d4"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    // Кнопка закрытия модального окна
                    text: "Закрыть"
                    width: 100
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: modalOverlay.visible = false
                }
            }
        }
    }
}
