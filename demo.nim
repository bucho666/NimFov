import terminal, tables, sugar, fov

proc `+`(self, other: Coord): Coord {.inline.} =
  (x: self.x + other.x, y: self.y + other.y)

let
  map = [
    "###########################################",
    "#.........################.........########",
    "#.......................##.###.###.########",
    "#.........#####.#.#.#.#.##.###.###.....####",
    "#.........#####.........##.###.#######.####",
    "####.##########.#.#.#.#.........~~~~~.....#",
    "####.##########.........######..~~~~~..##.#",
    "####.##############.##########.........##.#",
    "####................##############=######.#",
    "###################.......................#",
    "###########################################",
  ]
  dirTable = {
    'l': (x:  1, y:  0), 'h': (x: -1, y:  0),
    'j': (x:  0, y:  1), 'k': (x:  0, y: -1),
    'y': (x: -1, y: -1), 'm': (x: -1, y:  1),
    'u': (x:  1, y: -1), 'n': (x:  1, y:  1),
  }.toTable
var
  key: char
  p = (x:4, y:3)
resetAttributes()
let isOut = (c: Coord) => c.x >= map[0].len or c.y >= map.len or c.x < 0 or c.y < 0
while key != 'q':
  eraseScreen()
  setCursorPos(0, 0)
  for c in newFov(p, 10, (c: Coord) => isOut(c) or map[c.y][c.x] == '#'):
    if isOut(c):
      continue
    setCursorPos(c.x, c.y)
    stdout.write(map[c.y][c.x])
  setCursorPos(p.x, p.y)
  stdout.write('@')
  setCursorPos(p.x, p.y)
  key = getch()
  if not dirTable.hasKey(key):
    continue
  let t = p + dirTable[key]
  if map[t.y][t.x] == '.':
    p = t
