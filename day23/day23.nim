import sequtils
import strutils
import tables
import ../utils/point

const NUM_ROUNDS = 10

type Direction = enum
    North, South, East, West

const DIRECTIONS = [North, South, West, East]

const DP = {
    North: (0, -1), South: (0, 1), East: (1, 0), West: (-1, 0)
}.toTable

type Elf = object
    pos: Point[int]
    next: Point[int]

proc newElf(p: Point[int]): Elf =
    result.pos = p
    result.next = p

proc getPositions(elves: seq[Elf]): seq[Point[int]] =
    return elves.map(proc (e: Elf): Point[int] = e.pos)

proc findRect(elves: seq[Elf]): seq[int] =
    var top = elves[0].pos.y
    var bottom = elves[0].pos.y
    var left = elves[0].pos.x
    var right = elves[0].pos.x
    for elf in elves:
        top = min(top, elf.pos.y)
        bottom = max(bottom, elf.pos.y)
        left = min(left, elf.pos.x)
        right = max(right, elf.pos.x)
    return @[left, top, right, bottom]

proc findArea(elves: seq[Elf]): int =
    let rect = elves.findRect()
    return (rect[3] - rect[1] + 1) * (rect[2] - rect[0] + 1)

proc `$`(elves: seq[Elf]): string =
    let positions = elves.getPositions()
    let rect = elves.findRect()
    for y in countup(rect[1], rect[3]):
        for x in countup(rect[0], rect[2]):
            result.add(if (x, y) in positions: '#' else: '.')
        result.add("\n")

proc hasNeighbor(elf: Elf, elves: seq[Point[int]]): bool =
    var has_neighbor = false
    for dx in countup(-1, 1):
        for dy in countup(-1, 1):
            if dx != 0 or dy != 0:
                has_neighbor = has_neighbor or (elf.pos.x + dx, elf.pos.y + dy) in elves
    return has_neighbor

proc canMove(elf: Elf, dir: Direction, elves: seq[Point[int]]): bool =
    case dir:
        of North:
            return (elf.pos.x, elf.pos.y - 1) notin elves and (elf.pos.x - 1, elf.pos.y - 1) notin elves and (elf.pos.x + 1, elf.pos.y - 1) notin elves
        of South:
            return (elf.pos.x, elf.pos.y + 1) notin elves and (elf.pos.x - 1, elf.pos.y + 1) notin elves and (elf.pos.x + 1, elf.pos.y + 1) notin elves
        of East:
            return (elf.pos.x + 1, elf.pos.y) notin elves and (elf.pos.x + 1, elf.pos.y - 1) notin elves and (elf.pos.x + 1, elf.pos.y + 1) notin elves
        of West:
            return (elf.pos.x - 1, elf.pos.y) notin elves and (elf.pos.x - 1, elf.pos.y - 1) notin elves and (elf.pos.x - 1, elf.pos.y + 1) notin elves

proc moveElves(elves: var seq[Elf], dir_idx: int): bool =
    let positions = elves.getPositions()
    var movement = false
    for elf in elves.mitems():
        if not elf.hasNeighbor(positions):
            continue

        for i in countup(0, 3):
            let dir = DIRECTIONS[(dir_idx + i) mod DIRECTIONS.len()]
            if elf.canMove(dir, positions):
                elf.next = elf.pos + DP[dir]
                break
    for i in 0..<elves.len():
        var found = false
        for j in (i + 1)..<elves.len():
            if elves[i].next == elves[j].next:
                elves[j].next = elves[j].pos
                found = true
        if found:
            elves[i].next = elves[i].pos
    for elf in elves.mitems():
        if elf.pos != elf.next:
            elf.pos = elf.next
            movement = true
    return movement

proc parseInput(input: string): seq[Elf] =
    for y, line in input.splitLines().pairs():
        for x, c in line:
            if c == '#':
                result.add(newElf((x, y)))

proc day23p1*(input: string): string =
    var elves = parseInput(input)
    var dir_idx = 0
    for _ in countup(1, NUM_ROUNDS):
        discard elves.moveElves(dir_idx)
    let area = elves.findArea()
    return $(area - elves.len())

proc day23p2*(input: string): string =
    var elves = parseInput(input)
    var dir_idx = 0
    var cnt = 0
    while true:
        let moved = elves.moveElves(dir_idx)
        dir_idx = (dir_idx + 1) mod DIRECTIONS.len()
        inc(cnt)
        if not moved:
            break
    return $cnt
