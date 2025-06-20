# Fifteen

![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white)
![PyQt6](https://img.shields.io/badge/PyQt6-41CD52?style=flat&logo=qt&logoColor=white)
![QML](https://img.shields.io/badge/QML-41CD52?style=flat&logo=qt&logoColor=white)
![Cross-Platform](https://img.shields.io/badge/Cross--Platform-✓-blueviolet)
![License](https://img.shields.io/badge/License-MIT-blue)
![Modern UI](https://img.shields.io/badge/Modern%20UI-✓-orange)
[![Stars](https://img.shields.io/github/stars/VioletSoul/Fifteen.svg?style=social)](https://github.com/VioletSoul/Fifteen)
[![Last Commit](https://img.shields.io/github/last-commit/VioletSoul/Fifteen.svg)](https://github.com/VioletSoul/Fifteen/commits/main)

A classic "Game of Fifteen" (15 puzzle) implemented with PyQt6 and QML.

## Features

- **Modern UI:** Clean and visually appealing interface built with QML.
- **Correct Game Logic:** Proper shuffling, move validation, and win detection.
- **Move Counter:** Tracks the number of moves made in the current game.
- **Win Notification:** Modal dialog appears when you solve the puzzle.
- **Cross-platform:** Works on Windows, Linux, and macOS (with PyQt6 and QML support).

## Requirements

- Python 3.9+
- [PyQt6](https://pypi.org/project/PyQt6/)

## Installation

1. **Clone the repository:**
```
git clone https://github.com/VioletSoul/Fifteen.git
cd Fifteen
```
2. **Install dependencies:**
```
pip install PyQt6
```

## Usage

1. **Run the game:**
```
python main.py
```
2. **How to play:**
- Click on a tile adjacent to the empty space to move it.
- Click "Shuffle" to start a new game.
- Arrange the tiles in order from 1 to 15 with the empty space at the end.
- The move counter below the Shuffle button shows your current number of moves.

## File Structure

- `main.py` — Main game logic and Qt application setup (run this file to start the game).
- `main.qml` — QML UI definition and layout.
- `15.png` — Application window icon.
- `README.md` — This file.

## Screenshot

![Game Screenshot](Screenshot.png)

## License

MIT

---

**Enjoy playing the Game of Fifteen!**

[GitHub Repository](https://github.com/VioletSoul/Fifteen)
