from strutils import splitLines
import sets
import strscans
import tables

type Point = tuple
    x: int
    y: int

const DELTA_POINT = {
    'L': (-1, 0), 'R': (1, 0), 'U': (0, -1), 'D': (0, 1)
}.toTable

const NUM_KNOTS = 10

proc `+`(a: Point, b: Point): Point =
    return (a.x + b.x, a.y + b.y)

proc `+=`(a: var Point, b: Point) =
    a = a + b

proc `-`(a: Point, b: Point): Point =
    return (a.x - b.x, a.y - b.y)

proc sign(v: int): int =
    if v > 0:
        return 1
    elif v < 0:
        return -1
    return 0

proc unit(p: Point): Point =
    return (sign(p.x), sign(p.y))

proc is_touching(head: Point, tail: Point): bool =
    return abs(head.x - tail.x) < 2 and abs(head.y - tail.y) < 2

proc day9p1*(input: string): string =
    var
        head: Point
        tail: Point
        positions: HashSet[Point]

    head = (0, 0)
    tail = (0, 0)
    positions.incl(tail)
    for line in input.splitLines():
        let (success, dir, dist) = line.scanTuple("$c $i")
        if success:
            let dd = DELTA_POINT[dir]
            var dt = dist
            while dt != 0:
                head += dd
                if not head.is_touching(tail):
                    let dp = head - tail
                    tail += unit(dp)
                    positions.incl(tail)
                dt -= sign(dt)
    return $positions.len()

proc day9p2*(input: string): string =
    var
        knots: array[NUM_KNOTS, Point]
        positions: HashSet[Point]

    for i in 0..<NUM_KNOTS:
        knots[i] = (0, 0)
    positions.incl(knots[NUM_KNOTS - 1])

    for line in input.splitLines():
        let (success, dir, dist) = line.scanTuple("$c $i")
        if success:
            let dd = DELTA_POINT[dir]
            var dt = dist
            while dt != 0:
                knots[0] += dd
                for i in countup(0, NUM_KNOTS - 2):
                    if not knots[i].is_touching(knots[i + 1]):
                        let dp = knots[i] - knots[i + 1]
                        knots[i + 1] += unit(dp)
                dt -= sign(dt)
                positions.incl(knots[NUM_KNOTS - 1])
    return $positions.len()
