import sys
import random
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QUrl
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine

class GameModel(QObject):
    # Signals for QML communication
    tilesChanged = pyqtSignal()            # Emitted when tiles change
    gameWon = pyqtSignal()                 # Emitted when the game is won
    movesChanged = pyqtSignal()            # Emitted when moves counter changes
    easterEggSignal = pyqtSignal(str)      # Emitted when easter egg is triggered

    def __init__(self):
        super().__init__()
        # Initialize tiles (1-15 and empty tile as 0)
        self._tiles = list(range(1, 16)) + [0]
        # Initialize move counter
        self._moves = 0
        # Initialize shuffle counter
        self._shuffle_count = 0
        # Shuffle tiles on startup
        self.shuffle()

    # Expose tiles list to QML with change notification
    @pyqtProperty(list, notify=tilesChanged)
    def tiles(self):
        return self._tiles

    # Expose moves counter to QML with change notification
    @pyqtProperty(int, notify=movesChanged)
    def moves(self):
        return self._moves

    # Expose shuffle counter to QML (new)
    @pyqtProperty(int, notify=tilesChanged)
    def shuffleCount(self):
        return self._shuffle_count

    # Slot: Move a tile by index (called from QML)
    @pyqtSlot(int)
    def moveTile(self, index):
        # Find the index of the empty tile (0)
        zero_index = self._tiles.index(0)
        # Check if the move is valid (adjacent to empty)
        if self._canMove(index, zero_index):
            # Swap selected tile with empty tile
            self._tiles[zero_index], self._tiles[index] = self._tiles[index], self._tiles[zero_index]
            # Increment move counter
            self._moves += 1
            # Notify QML of changes
            self.tilesChanged.emit()
            self.movesChanged.emit()
            # Check if the game is won
            if self._checkWin():
                self.gameWon.emit()

    # Slot: Shuffle the tiles (called from QML)
    @pyqtSlot()
    def shuffle(self):
        while True:
            # Shuffle tiles randomly
            random.shuffle(self._tiles)
            # Ensure puzzle is solvable and not already solved
            if self._isSolvable() and not self._checkWin():
                break
        # Reset move counter
        self._moves = 0
        # Increment shuffle counter
        self._shuffle_count += 1
        # Notify QML of changes
        self.tilesChanged.emit()
        self.movesChanged.emit()
        # Check for easter egg conditions
        self._checkEasterEgg()

    # Check if easter egg conditions are met
    def _checkEasterEgg(self):
        if self._shuffle_count % 100 == 0 and self._shuffle_count > 0:
            messages = [
                "Вы очень упорный",
                "Еще немного и вы откроете портал в другой мир",
                "Вы явно любите перемешивать!",
                "Продолжайте, это уже вошло в привычку!",
                "Вы — мастер перемешивания!",
                "Вы на пути к рекорду!",
                "Скоро вас ждет сюрприз...",
                "Почти добрались до магического числа!",
                "Вы — легенда перемешивания!",
                "Вы достигли вершины мастерства!"
            ]
            idx = min(self._shuffle_count // 100 - 1, len(messages) - 1)
            self.easterEggSignal.emit(messages[idx])

    # Check if a tile can be moved (is adjacent to empty)
    def _canMove(self, tile_index, zero_index):
        row_tile, col_tile = divmod(tile_index, 4)
        row_zero, col_zero = divmod(zero_index, 4)
        # Tile is adjacent to empty if in same row/col and distance is 1
        return (abs(row_tile - row_zero) == 1 and col_tile == col_zero) or \
            (abs(col_tile - col_zero) == 1 and row_tile == row_zero)

    # Check if the tiles are in the correct order (game is won)
    def _checkWin(self):
        return self._tiles == list(range(1, 16)) + [0]

    # Check if the current configuration is solvable
    def _isSolvable(self):
        inv_count = 0
        # List of tiles without the empty one
        tiles = [t for t in self._tiles if t != 0]
        # Count inversions (pairs of tiles in wrong order)
        for i in range(len(tiles)):
            for j in range(i + 1, len(tiles)):
                if tiles[i] > tiles[j]:
                    inv_count += 1
        # Get the row of the empty tile from the bottom
        zero_row_from_bottom = 4 - (self._tiles.index(0) // 4)
        # Solvability rules for 15 puzzle
        if zero_row_from_bottom % 2 == 0:
            return inv_count % 2 == 1
        else:
            return inv_count % 2 == 0

if __name__ == "__main__":
    # Create Qt GUI application
    app = QGuiApplication(sys.argv)
    # Set window icon (optional, requires 15.png)
    app.setWindowIcon(QIcon("15.png"))
    # Windows-specific app ID for taskbar icon (optional)
    if sys.platform.startswith("win"):
        import ctypes
        myappid = 'GameOfFifteen'
        ctypes.windll.shell32.SetCurrentProcessExplicitAppUserModelID(myappid)
    # Create QML engine
    engine = QQmlApplicationEngine()
    # Create game model instance
    game_model = GameModel()
    # Expose model to QML as "gameModel"
    engine.rootContext().setContextProperty("gameModel", game_model)
    # Load QML interface
    engine.load(QUrl("main.qml"))
    # Exit if QML loading failed
    if not engine.rootObjects():
        sys.exit(-1)
    # Get root QML object (main window)
    root = engine.rootObjects()[0]
    # Function to show win modal when game is won
    def on_game_won():
        modal_overlay = root.findChild(QObject, "modalOverlay")
        if modal_overlay:
            modal_overlay.setProperty("visible", True)
    # Connect win signal to modal show function
    game_model.gameWon.connect(on_game_won)
    # Start application event loop
    sys.exit(app.exec())
