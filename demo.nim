import terminal, tables, sugar, fov, sets

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
    "###################.#######################",
    "#.........................................#",
    "#.........................................#",
    "#.........................................#",
    "#..................#......................#",
    "#.........................................#",
    "#.........................................#",
    "#.........................................#",
    "###########################################",
  ]
  dirTable = {
    'l': (x:  1, y:  0), 'h': (x: -1, y:  0),
    'j': (x:  0, y:  1), 'k': (x:  0, y: -1),
    'y': (x: -1, y: -1), 'b': (x: -1, y:  1),
    'u': (x:  1, y: -1), 'n': (x:  1, y:  1),
  }.toTable
  tileColors = {
    '#': fgDefault,
    '.': fgGreen,
    '~': fgBlue,
    '=': fgYellow,
  }.toTable
var
  key: char
  p = (x:4, y:3)
  memory = initHashSet[Coord]()
  sight = newFov(10, (c: Coord) => map[c.y][c.x] == '#')
while key != 'q':
  eraseScreen()
  setCursorPos(0, 0)
  let views = sight.calculate(p)
  for c in memory - views:
    setCursorPos(c.x, c.y)
    stdout.styledWrite(fgWhite, $map[c.y][c.x])
  for c in views:
    setCursorPos(c.x, c.y)
    let t = map[c.y][c.x]
    stdout.styledWrite(tileColors[t], styleBright, $t)
  memory.incl(views)
  setCursorPos(p.x, p.y)
  stdout.write('@')
  setCursorPos(p.x, p.y)
  key = getch()
  if not dirTable.hasKey(key):
    continue
  let t = p + dirTable[key]
  if map[t.y][t.x] == '.':
    p = t
