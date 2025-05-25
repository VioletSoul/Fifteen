import sys
import random
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QUrl
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine

# Класс модели игры, наследуется от QObject для взаимодействия с QML
class GameModel(QObject):
    # Сигнал, который уведомляет QML об изменении списка плиток
    tilesChanged = pyqtSignal()
    # Сигнал, который уведомляет о победе в игре
    gameWon = pyqtSignal()

    def __init__(self):
        super().__init__()
        # Инициализация списка плиток в правильном порядке: 1..15 и пустая плитка (0)
        self._tiles = list(range(1, 16)) + [0]
        # Перемешиваем плитки при старте
        self.shuffle()

    # Свойство tiles, доступное из QML, с уведомлением об изменениях
    @pyqtProperty(list, notify=tilesChanged)
    def tiles(self):
        return self._tiles

    # Слот для перемещения плитки по индексу
    @pyqtSlot(int)
    def moveTile(self, index):
        # Находим индекс пустой плитки (0)
        zero_index = self._tiles.index(0)
        # Проверяем, можно ли переместить плитку (только если она соседняя с пустой)
        if self._canMove(index, zero_index):
            # Меняем местами выбранную плитку и пустую
            self._tiles[zero_index], self._tiles[index] = self._tiles[index], self._tiles[zero_index]
            # Уведомляем QML, что плитки изменились
            self.tilesChanged.emit()
            # Проверяем, собраны ли все плитки в правильном порядке
            if self._checkWin():
                # Если да, кидаем сигнал победы
                self.gameWon.emit()

    # Слот для перемешивания плиток
    @pyqtSlot()
    def shuffle(self):
        while True:
            # Перемешиваем плитки случайным образом
            random.shuffle(self._tiles)
            # Проверяем, что головоломка решаема и еще не решена
            if self._isSolvable() and not self._checkWin():
                break
        # Уведомляем QML об изменении плиток после перемешивания
        self.tilesChanged.emit()

    # Вспомогательный метод: проверка, можно ли переместить плитку (соседство с пустой)
    def _canMove(self, tile_index, zero_index):
        # Получаем координаты плитки и пустой клетки (row, column)
        row_tile, col_tile = divmod(tile_index, 4)
        row_zero, col_zero = divmod(zero_index, 4)
        # Можно переместить, если плитка находится слева, справа, сверху или снизу от пустой
        return (abs(row_tile - row_zero) == 1 and col_tile == col_zero) or \
            (abs(col_tile - col_zero) == 1 and row_tile == row_zero)

    # Проверка, собраны ли плитки в правильном порядке (1..15 и пустая в конце)
    def _checkWin(self):
        return self._tiles == list(range(1, 16)) + [0]

    # Проверка, решаема ли текущая конфигурация плиток
    def _isSolvable(self):
        inv_count = 0
        # Список плиток без пустой
        tiles = [t for t in self._tiles if t != 0]
        # Подсчёт инверсий — пар плиток, стоящих в неправильном порядке
        for i in range(len(tiles)):
            for j in range(i + 1, len(tiles)):
                if tiles[i] > tiles[j]:
                    inv_count += 1
        # Определяем строку пустой плитки с низа (для правила решаемости)
        zero_row_from_bottom = 4 - (self._tiles.index(0) // 4)
        # Правила решаемости для пятнашек
        if zero_row_from_bottom % 2 == 0:
            return inv_count % 2 == 1
        else:
            return inv_count % 2 == 0

if __name__ == "__main__":
    # Создаём приложение Qt GUI
    app = QGuiApplication(sys.argv)
    # Устанавливаем иконку окна
    app.setWindowIcon(QIcon("15.png"))

    # Специфичная настройка для Windows (идентификатор приложения)
    if sys.platform.startswith("win"):
        import ctypes
        myappid = 'GameOfFifteen'
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)

    # Создаём движок QML
    engine = QQmlApplicationEngine()

    # Создаём экземпляр модели игры
    game_model = GameModel()
    # Передаём модель в контекст QML под именем "gameModel"
    engine.rootContext().setContextProperty("gameModel", game_model)

    # Загружаем QML интерфейс
    engine.load(QUrl("main.qml"))

    # Если загрузка не удалась — выходим
    if not engine.rootObjects():
        sys.exit(-1)

    # Получаем корневой объект QML (главное окно)
    root = engine.rootObjects()[0]

    # Функция, которая вызывается при победе — показывает модальное окно
    def on_game_won():
        modal_overlay = root.findChild(QObject, "modalOverlay")
        if modal_overlay:
            modal_overlay.setProperty("visible", True)

    # Подключаем сигнал победы к функции отображения окна
    game_model.gameWon.connect(on_game_won)

    # Запускаем главный цикл приложения
    sys.exit(app.exec())
