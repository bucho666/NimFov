import math, sugar

type
  Coord* = tuple[x, y: int]
  FCoord = tuple[x, y: float]

proc abs(self: Coord): Coord {.inline.} =
  (x: self.x.abs, y:self.y.abs)

proc fcoord(self: Coord): FCoord {.inline.} =
  (x: self.x.toFloat, y: self.y.toFloat)

proc `+`(self, other: FCoord): FCoord {.inline.} =
  (x: self.x + other.x, y: self.y + other.y)

proc `-`(self, other: FCoord): FCoord {.inline.} =
  (x: self.x - other.x, y: self.y - other.y)

proc `*`(self, other: FCoord): FCoord {.inline.} =
  (x: self.x * other.x, y: self.y * other.y)

proc abs(self: FCoord): FCoord {.inline.} =
  (x: self.x.abs, y:self.y.abs)

proc coord(self: FCoord): Coord {.inline.} =
  (x: self.x.round.int, y: self.y.round.int)

proc swap(self: FCoord): FCoord {.inline.} =
  (x: self.y, y: self.x)

type
  Octant = tuple[rotate: FCoord, swap: bool]

proc apply(self: Octant, c: FCoord): FCoord =
  result = c * self.rotate
  if self.swap:
    result = result.swap

type
  Vector = object
    fcoord*, dir: FCoord

proc coord(self: Vector): Coord {.inline.} =
  self.fcoord.coord

proc step(self: Vector): Vector {.inline.} =
  Vector(fcoord: self.fcoord + self.dir, dir: self.dir)

type
  Fov = ref object
    origin: FCoord
    radius: int
    radiusSquare: int
    isBlock: (Coord) -> bool

proc newFov*(origin: Coord, radius: int, isBlock:(Coord) -> bool): Fov =
  Fov(origin: origin.fcoord, radius: radius, radiusSquare: radius ^ 2, isBlock: isBlock)

proc isInside(self: Fov, v: Vector): bool {.inline.} =
  let diff = (self.origin - v.fcoord).coord.abs
  diff.x ^ 2 + diff.y ^ 2 < self.radiusSquare

proc slope(self: Fov, fcoord: FCoord): float {.inline.} =
  let diff = (self.origin.abs - fcoord.abs).abs
  min(diff.x, diff.y) / max(diff.x, diff.y)

let Octants = [
  (rotate: ( 1.0,  1.0), swap: false),
  (rotate: ( 1.0,  1.0), swap: true),
  (rotate: ( 1.0, -1.0), swap: false),
  (rotate: ( 1.0, -1.0), swap: true),
  (rotate: (-1.0,  1.0), swap: false),
  (rotate: (-1.0,  1.0), swap: true),
  (rotate: (-1.0, -1.0), swap: false),
  (rotate: (-1.0, -1.0), swap: true)
]

proc scan(self: Fov, left, right: Vector, oct: Octant): seq[Coord]

proc scanNext(self: Fov, tail, prev: FCoord, oct: Octant): seq[Coord] {.inline.} =
  self.scan(
    Vector(fcoord: tail, dir: oct.apply((1.0, self.slope(tail)))).step,
    Vector(fcoord: prev, dir: oct.apply((1.0, self.slope(prev)))).step,
    oct)

proc scan(self: Fov, left, right: Vector, oct: Octant): seq[Coord] =
  var
    head = Vector(fcoord: left.fcoord, dir: oct.apply((0.0, 1.0)))
    tail = head.fcoord
    prev = head.fcoord
    prevIsOpen = false
  let diff = (right.fcoord.abs - left.fcoord.abs).abs.coord
  for _ in 0 .. max(diff.x, diff.y):
    if self.isInside(head):
      result.add(head.coord)
    if self.isBlock(head.coord):
      if prevIsOpen:
        result &= self.scanNext(tail, prev, oct)
      prevIsOpen = false
    else:
      if not prevIsOpen:
        tail = head.fcoord
      prevIsOpen = true
    prev = head.fcoord
    head = head.step
  if prevIsOpen:
    result &= self.scanNext(tail, prev, oct)

proc coords*(self: Fov): seq[Coord] =
  result = @[self.origin.coord]
  for oct in Octants:
    let
      left = Vector(fcoord: self.origin, dir: oct.apply((1.0, 0.0)))
      right = Vector(fcoord: self.origin, dir: oct.apply((1.0, 1.0)))
    result &= self.scan(left.step, right.step, oct)

iterator items*(self: Fov): Coord {.inline.} =
  for c in self.coords:
    yield c
