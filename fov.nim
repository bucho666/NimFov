import math, sets, sugar

type Coord* = tuple[x, y: int]

proc `+`(self, other: Coord): Coord {.inline.} =
  (x: self.x + other.x, y: self.y + other.y)

proc swap(self: Coord): Coord {.inline.} =
  (x: self.y, y: self.x)

type Octant = tuple[rotate: Coord, swap: bool]

proc apply(self: Octant, x, y: int): Coord =
  result = (x * self.rotate.x, y * self.rotate.y)
  if self.swap: result = result.swap

type Fov = ref object
  origin: Coord
  radiusSquare: int
  oct: Octant
  isBlock: (Coord) -> bool

proc newFov*(radius: int, isBlock: (Coord) -> bool): Fov =
  Fov(radiusSquare: radius ^ 2, isBlock: isBlock)

proc translateMapCoord(self: Fov, x, y: int): Coord {.inline.} =
  self.origin + self.oct.apply(x, y)

proc inRadius(self: Fov, x, y: int): bool =
  (x ^ 2) + (y ^ 2) < self.radiusSquare

proc scan(self: Fov, row, startSlope, endSlope: float): HashSet[Coord] =
  let
    endY = round(row * endSlope)
    x = row.int
  var
    y = round(row * startSlope)
    nextStartSlope = startSlope
    mapCoord = self.translateMapCoord(x, y.int)
    blocked = self.isBlock(mapCoord)
  if x ^ 2 >= self.radiusSquare: return
  while y >= endY:
    mapCoord = self.translateMapCoord(x, y.int)
    if self.inRadius(x, y.int):
      result.incl(mapCoord)
    if self.isBlock(mapCoord):
      if not blocked:
        result.incl(self.scan(row + 1.0, nextStartSlope, (y + 0.5) / (row - 0.5)))
      blocked = true
    elif blocked:
      nextStartSlope = (y + 0.5) / (row + 0.5)
      blocked = false
    y -= 1.0
  if not blocked:
    result.incl(self.scan(row + 1.0, nextStartSlope, endSlope))

let Octants = [
  (rotate: ( 1,  1), swap: false),
  (rotate: ( 1,  1), swap: true),
  (rotate: ( 1, -1), swap: false),
  (rotate: ( 1, -1), swap: true),
  (rotate: (-1,  1), swap: false),
  (rotate: (-1,  1), swap: true),
  (rotate: (-1, -1), swap: false),
  (rotate: (-1, -1), swap: true)
]

proc calculate*(self: Fov, origin: Coord): HashSet[Coord] =
  self.origin = origin
  result = toHashSet([self.origin])
  for oct in Octants:
    self.oct = oct
    result.incl(self.scan(1.0, 1.0, 0.0))
