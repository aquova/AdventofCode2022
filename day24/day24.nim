from algorithm import reversed
import deques
import strutils
import tables
import ../utils/point

type Walls = seq[Point[int]]

type Direction = enum
    North, South, East, West

const DP: Table[Direction, Point[int]] = {
    North: (0, -1), South: (0, 1), East: (1, 0), West: (-1, 0)
}.toTable

type Blizzard = object
    pos: Point[int]
    dir: Direction

type Position = object
    pos: Point[int]
    time: int

iterator neighbors(p: Point[int], walls: Walls): Point[int] =
    for dir in Direction:
        let next = p + DP[dir]
        if next notin walls and next.x > 0 and next.y > 0:
            yield p + DP[dir]
    yield p

proc newPosition(p: Point[int], time: int): Position =
    result.pos = p
    result.time = time

proc newBlizzard(x, y: int, c: char): Blizzard =
    result.pos = (x, y)
    case c:
        of '^': result.dir = North
        of '>': result.dir = East
        of '<': result.dir = West
        of 'v': result.dir = South
        else: assert(false, $c)

proc newBlizzard(p: Point[int], d: Direction): Blizzard =
    result.pos = p
    result.dir = d

proc move(b: Blizzard, width, height: int): Blizzard =
    let dp = DP[b.dir]
    var next: Point[int] = (b.pos.x + dp.x, b.pos.y + dp.y)
    if next.x == 0:
        next.x = width - 2
    elif next.x == width - 1:
        next.x = 1

    if next.y == 0:
        next.y = height - 2
    elif next.y == height - 1:
        next.y = 1
    return newBlizzard(next, b.dir)

proc iterateBlizzards(blizzards: seq[Blizzard], width, height: int): seq[Blizzard] =
    for b in blizzards:
        result.add(b.move(width, height))

proc contains(blizzards: seq[Blizzard], p: Point[int]): bool =
    for b in blizzards:
        if b.pos == p:
            return true
    return false

proc `$`(blizzards: seq[Blizzard]): string =
    for y in countup(0, 36):
        for x in countup(0, 101):
            let p = (x, y)
            var found = false
            for b in blizzards:
                if p == b.pos:
                    found = true
                    let sym = case b.dir:
                        of North: '^'
                        of South: 'v'
                        of West: '<'
                        of East: '>'
                    result.add(sym)
                    break
            if not found:
                result.add('.')
        result.add("\n")

proc bfs(start: Point[int], target: Point[int], blizzards: seq[Blizzard], walls: Walls, width, height: int): seq[Point[int]] =
    var
        queue: Deque[Position]
        parents: Table[Position, Position]
        blizzard_timeline: seq[seq[Blizzard]]
        backtrack: Position

    blizzard_timeline.add(blizzards)
    # echo($blizzards)
    queue.addLast(newPosition(start, 0))
    while queue.len() > 0:
        let pos = queue.popFirst()
        if pos.pos == target:
            backtrack = pos
            break

        for n in pos.pos.neighbors(walls):
            let new_pos = newPosition(n, pos.time + 1)
            if new_pos.time == blizzard_timeline.len():
                let next_blizzard = blizzard_timeline[blizzard_timeline.len() - 1].iterateBlizzards(width, height)
                blizzard_timeline.add(next_blizzard)
                # echo($next_blizzard)
            if not parents.contains(new_pos) and not blizzard_timeline[new_pos.time].contains(new_pos.pos):
                queue.addLast(new_pos)
                parents[new_pos] = pos

    while backtrack.pos != start:
        result.add(backtrack.pos)
        backtrack = parents[backtrack]
    result = result.reversed()

proc day24p1*(input: string): string =
    let lines = input.splitLines()
    let height = lines.len()
    let width = lines[0].len()

    let start: Point[int] = (1, 0)
    let target: Point[int] = (width - 2, height - 1)
    # echo(target)
    let arrows = ['^', '<', '>', 'v']

    var
        walls: Walls
        blizzards: seq[Blizzard]
    for y, line in lines.pairs():
        for x, c in line:
            if c in arrows:
                blizzards.add(newBlizzard(x, y, c))
            elif c == '#':
                walls.add((x, y))
    let path = bfs(start, target, blizzards, walls, width, height)
    # echo(path)
    return $path.len()

proc day24p2*(input: string): string =
    discard
