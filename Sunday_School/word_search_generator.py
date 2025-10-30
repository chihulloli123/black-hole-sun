import random
import string

# ======================
# CONFIGURATION SECTION
# ======================
WORDS = [
    "Faith", "Love", "Strength", "Hope", "Prayer", "Paul",
    "Silas", "Timothy", "God", "Church", "Saints", "Strong", "Firm",
    "Believe", "Jesus", "Grow", "Heart", "Grace", "Peace", "Endure"
]
GRID_SIZE = 15
ALLOW_BACKWARDS = False  # set True for harder puzzles

# ======================
# CORE LOGIC
# ======================
def create_empty_grid(size):
    return [[' ' for _ in range(size)] for _ in range(size)]

def can_place(grid, word, x, y, dx, dy):
    for i, char in enumerate(word):
        nx, ny = x + i * dx, y + i * dy
        if not (0 <= nx < GRID_SIZE and 0 <= ny < GRID_SIZE):
            return False
        if grid[ny][nx] not in (' ', char):
            return False
    return True

def place_word(grid, word):
    directions = [(1,0), (0,1), (1,1), (1,-1)]
    if ALLOW_BACKWARDS:
        directions += [(-1,0), (0,-1), (-1,-1), (-1,1)]
    for _ in range(100):
        dx, dy = random.choice(directions)
        x = random.randint(0, GRID_SIZE-1)
        y = random.randint(0, GRID_SIZE-1)
        if can_place(grid, word, x, y, dx, dy):
            for i, char in enumerate(word):
                grid[y + i * dy][x + i * dx] = char
            return True
    return False

def fill_empty(grid):
    for y in range(GRID_SIZE):
        for x in range(GRID_SIZE):
            if grid[y][x] == ' ':
                grid[y][x] = random.choice(string.ascii_uppercase)

def make_word_search():
    grid = create_empty_grid(GRID_SIZE)
    for word in WORDS:
        success = place_word(grid, word.upper())
        if not success:
            print(f"⚠️ Could not place: {word}")
    fill_empty(grid)
    for row in grid:
        print(' '.join(row))
    print("\nFind these words:")
    print(', '.join(WORDS))

if __name__ == "__main__":
    make_word_search()
