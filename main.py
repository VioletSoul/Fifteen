import sys
import random
from PyQt6.QtCore import QObject, pyqtSignal, pyqtProperty, pyqtSlot, QUrl
from PyQt6.QtGui import QGuiApplication, QIcon
from PyQt6.QtQml import QQmlApplicationEngine

# Game model class, inherits from QObject for QML integration
class GameModel(QObject):
    # Signal emitted when the tiles list changes
    tilesChanged = pyqtSignal()
    # Signal emitted when the game is won
    gameWon = pyqtSignal()
    # Signal emitted when the move counter changes
    movesChanged = pyqtSignal()

    def __init__(self):
        super().__init__()
        # Initialize tiles in correct order: 1..15 and empty tile (0)
        self._tiles = list(range(1, 16)) + [0]
        # Initialize move counter
        self._moves = 0
        # Shuffle the tiles on startup
        self.shuffle()

    # Property exposed to QML for the tiles list, with change notification
    @pyqtProperty(list, notify=tilesChanged)
    def tiles(self):
        return self._tiles

    # Property for the move counter, exposed to QML
    @pyqtProperty(int, notify=movesChanged)
    def moves(self):
        return self._moves

    # Slot to move a tile by index
    @pyqtSlot(int)
    def moveTile(self, index):
        # Find the index of the empty tile (0)
        zero_index = self._tiles.index(0)
        # Check if the move is valid (tile is adjacent to empty)
        if self._canMove(index, zero_index):
            # Swap the selected tile with the empty tile
            self._tiles[zero_index], self._tiles[index] = self._tiles[index], self._tiles[zero_index]
            # Increment the move counter
            self._moves += 1
            # Notify QML of changes
            self.tilesChanged.emit()
            self.movesChanged.emit()
            # Check if the game is won
            if self._checkWin():
                self.gameWon.emit()

    # Slot to shuffle the tiles
    @pyqtSlot()
    def shuffle(self):
        while True:
            # Shuffle the tiles randomly
            random.shuffle(self._tiles)
            # Check if the puzzle is solvable and not already solved
            if self._isSolvable() and not self._checkWin():
                break
        # Reset the move counter
        self._moves = 0
        # Notify QML of changes
        self.tilesChanged.emit()
        self.movesChanged.emit()

    # Helper method: check if a tile can be moved (is adjacent to empty)
    def _canMove(self, tile_index, zero_index):
        # Get tile and empty cell coordinates (row, column)
        row_tile, col_tile = divmod(tile_index, 4)
        row_zero, col_zero = divmod(zero_index, 4)
        # Move is valid if tile is left, right, above, or below the empty cell
        return (abs(row_tile - row_zero) == 1 and col_tile == col_zero) or \
            (abs(col_tile - col_zero) == 1 and row_tile == row_zero)

    # Check if the tiles are in the correct order (1..15 and empty at the end)
    def _checkWin(self):
        return self._tiles == list(range(1, 16)) + [0]

    # Check if the current tile configuration is solvable
    def _isSolvable(self):
        inv_count = 0
        # List of tiles without the empty one
        tiles = [t for t in self._tiles if t != 0]
        # Count inversions: pairs of tiles in wrong order
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
    # Set window icon
    app.setWindowIcon(QIcon("15.png"))

    # Windows-specific app ID (for taskbar icon)
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
