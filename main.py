import sys
import random
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QUrl
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine

class GameModel(QObject):
    tilesChanged = pyqtSignal()
    gameWon = pyqtSignal()

    def __init__(self):
        super().__init__()
        self._tiles = list(range(1, 16)) + [0]
        self.shuffle()

    @pyqtProperty(list, notify=tilesChanged)
    def tiles(self):
        return self._tiles

    @pyqtSlot(int)
    def moveTile(self, index):
        zero_index = self._tiles.index(0)
        if self._canMove(index, zero_index):
            self._tiles[zero_index], self._tiles[index] = self._tiles[index], self._tiles[zero_index]
            self.tilesChanged.emit()
            if self._checkWin():
                self.gameWon.emit()

    @pyqtSlot()
    def shuffle(self):
        while True:
            random.shuffle(self._tiles)
            if self._isSolvable() and not self._checkWin():
                break
        self.tilesChanged.emit()

    def _canMove(self, tile_index, zero_index):
        row_tile, col_tile = divmod(tile_index, 4)
        row_zero, col_zero = divmod(zero_index, 4)
        return (abs(row_tile - row_zero) == 1 and col_tile == col_zero) or \
            (abs(col_tile - col_zero) == 1 and row_tile == row_zero)

    def _checkWin(self):
        return self._tiles == list(range(1, 16)) + [0]

    def _isSolvable(self):
        inv_count = 0
        tiles = [t for t in self._tiles if t != 0]
        for i in range(len(tiles)):
            for j in range(i + 1, len(tiles)):
                if tiles[i] > tiles[j]:
                    inv_count += 1
        zero_row_from_bottom = 4 - (self._tiles.index(0) // 4)
        if zero_row_from_bottom % 2 == 0:
            return inv_count % 2 == 1
        else:
            return inv_count % 2 == 0

if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    app.setWindowIcon(QIcon("15.png"))

    if sys.platform.startswith("win"):
        import ctypes
        myappid = 'GameOfFifteen'
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)

    engine = QQmlApplicationEngine()

    game_model = GameModel()
    engine.rootContext().setContextProperty("gameModel", game_model)

    engine.load(QUrl("main.qml"))

    if not engine.rootObjects():
        sys.exit(-1)

    root = engine.rootObjects()[0]

    def on_game_won():
        modal_overlay = root.findChild(QObject, "modalOverlay")
        if modal_overlay:
            modal_overlay.setProperty("visible", True)

    game_model.gameWon.connect(on_game_won)

    sys.exit(app.exec())
