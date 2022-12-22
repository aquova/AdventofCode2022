import strutils
import tables
import ../utils/point

const CHUNK_SIZE = 50

type Chunks = Table[Point[int], seq[string]]

type Direction = enum
    East, South, West, North

type Player = object
    chunk: Point[int]
    pos: Point[int]
    dir: Direction

type Instructions = object
    distances: seq[int]
    turns: seq[bool]

type FaceData = tuple
    destination: Point[int]
    dir: Direction

const DP = {
    North: (0, -1), South: (0, 1), East: (1, 0), West: (-1, 0)
}.toTable

const CUBE_TBL: Table[Point[int], Table[Direction, FaceData]] = {
    (1, 0): {
        North: ((0, 3), East), South: ((1, 1), South), East: ((2, 0), East), West: ((0, 2), East)
    }.toTable,
    (1, 1): {
        North: ((1, 0), North), South: ((1, 2), South), East: ((2, 0), North), West: ((0, 2), South)
    }.toTable,
    (1, 2): {
        North: ((1, 1), North), South: ((0, 3), West), East: ((2, 0), West), West: ((0, 2), West)
    }.toTable,
    (0, 2): {
        North: ((1, 1), East), South: ((0, 3), South), East: ((1, 2), East), West: ((1, 0), East)
    }.toTable,
    (0, 3): {
        North: ((0, 2), North), South: ((2, 0), South), East: ((1, 2), North), West: ((1, 0), South)
    }.toTable,
    (2, 0): {
        North: ((0, 3), North), South: ((1, 1), West), East: ((1, 2), West), West: ((1, 0), West)
    }.toTable
}.toTable

proc `%`(a, b: int): int =
    var m = a mod b
    if m < 0:
        m += b
    return m

proc `[]`(chunk: seq[string], p: Point[int]): char =
    return chunk[p.y][p.x]

proc getDim(chunks: Chunks): Point[int] =
    var largest: Point[int]
    for k in chunks.keys:
        largest.x = max(largest.x, k.x + 1)
        largest.y = max(largest.y, k.y + 1)
    return largest

proc newPlayer(chunks: Chunks): Player =
    var starting: Point[int] = (0, 0)
    while true:
        if starting in chunks:
            break
        inc(starting.x)
    result.chunk = starting
    result.pos = (0, 0)
    result.dir = Direction.East

proc turn(dir: Direction, clockwise: bool): Direction =
    result = case dir:
        of North:
            if clockwise: East else: West
        of South:
            if clockwise: West else: East
        of West:
            if clockwise: North else: South
        of East:
            if clockwise: South else: North

proc move(p: var Player, chunks: Chunks, dist: int) =
    let map_size = chunks.getDim()
    let dp = DP[p.dir]
    for _ in countup(1, dist):
        var next_pos = p.pos + dp
        var next_chunk = p.chunk
        if next_pos.x < 0:
            next_pos.x = CHUNK_SIZE - 1
            while true:
                next_chunk.x = (next_chunk.x - 1) % map_size.x
                if next_chunk in chunks:
                    break
        elif next_pos.x == CHUNK_SIZE:
            next_pos.x = 0
            while true:
                next_chunk.x = (next_chunk.x + 1) % map_size.x
                if next_chunk in chunks:
                    break
        elif next_pos.y < 0:
            next_pos.y = CHUNK_SIZE - 1
            while true:
                next_chunk.y = (next_chunk.y - 1) % map_size.y
                if next_chunk in chunks:
                    break
        elif next_pos.y == CHUNK_SIZE:
            next_pos.y = 0
            while true:
                next_chunk.y = (next_chunk.y + 1) % map_size.y
                if next_chunk in chunks:
                    break

        if chunks[next_chunk][next_pos] == '.':
            p.chunk = next_chunk
            p.pos = next_pos
        else:
            break

proc rot(p: Point[int], dd: int): Point[int] =
    case dd:
        of -1, 3: # CW
            return ((CHUNK_SIZE - p.y - 1) % CHUNK_SIZE, p.x % CHUNK_SIZE)
        of 0:
            return (p.x % CHUNK_SIZE, p.y % CHUNK_SIZE)
        of 1, -3: # CCW
            return (p.y % CHUNK_SIZE, (CHUNK_SIZE - p.x - 1) % CHUNK_SIZE)
        of 2, -2: # 180
            return ((CHUNK_SIZE - p.x - 1) % CHUNK_SIZE, (CHUNK_SIZE - p.y - 1) % CHUNK_SIZE)
        else:
            assert(false, $dd)

# Sadly, just hardcode it.
proc moveCube(p: var Player, chunks: Chunks, dist: int) =
    for _ in countup(1, dist):
        # echo(p)
        let dp = DP[p.dir]
        var next_pos = p.pos + dp
        var next_chunk = p.chunk
        var next_dir = p.dir
        if next_pos.x < 0 or next_pos.x == CHUNK_SIZE or next_pos.y < 0 or next_pos.y == CHUNK_SIZE:
            let data = CUBE_TBL[p.chunk][p.dir]
            next_chunk = data.destination
            next_dir = data.dir
            next_pos = next_pos.rot(ord(p.dir) - ord(next_dir))

        if chunks[next_chunk][next_pos] == '.':
            p.chunk = next_chunk
            p.pos = next_pos
            p.dir = next_dir
        else:
            # echo("Hit")
            break

proc parseChunks(input: string): Chunks =
    let lines = input.splitLines()
    var max_width = 0
    for line in lines:
        max_width = max(line.len(), max_width)

    for chunk_x in countup(0, max_width - 1, CHUNK_SIZE):
        for chunk_y in countup(0, lines.len() - 1, CHUNK_SIZE):
            let chunk_pt: Point[int] = (chunk_x div CHUNK_SIZE, chunk_y div CHUNK_SIZE)
            if chunk_x >= lines[chunk_y].len():
                continue
            if lines[chunk_y][chunk_x] == ' ':
                continue
            var chunk: seq[string]
            for dy in countup(0, CHUNK_SIZE - 1):
                let sub = lines[chunk_y + dy].substr(chunk_x, chunk_x + CHUNK_SIZE - 1)
                chunk.add(sub)
            result[chunk_pt] = chunk

proc parseInstructions(input: string): Instructions =
    var dist: seq[int]
    var turns: seq[bool]

    var tmp: string
    for c in input:
        if c.isDigit():
            tmp.add(c)
        else:
            dist.add(parseInt(tmp))
            tmp = ""
            turns.add(c == 'R')
    if tmp != "":
        dist.add(parseInt(tmp))

    result.distances = dist
    result.turns = turns

proc day22p1*(input: string): string =
    let sections = input.split("\n\n")
    let chunks = sections[0].parseChunks()
    let instructions = sections[1].parseInstructions()
    var player = newPlayer(chunks)
    var idx = 0
    while true:
        var done = true
        if idx < instructions.distances.len():
            player.move(chunks, instructions.distances[idx])
            done = false
        if idx < instructions.turns.len():
            player.dir = player.dir.turn(instructions.turns[idx])
            done = false
        inc(idx)
        if done:
            break
    let row = player.chunk.y * CHUNK_SIZE + player.pos.y + 1
    let col = player.chunk.x * CHUNK_SIZE + player.pos.x + 1
    return $(row * 1000 + 4 * col + ord(player.dir))

proc day22p2*(input: string): string =
    let sections = input.split("\n\n")
    let chunks = sections[0].parseChunks()
    let instructions = sections[1].parseInstructions()
    var player = newPlayer(chunks)
    var idx = 0
    while true:
        var done = true
        if idx < instructions.distances.len():
            player.moveCube(chunks, instructions.distances[idx])
            done = false
        if idx < instructions.turns.len():
            player.dir = player.dir.turn(instructions.turns[idx])
            done = false
        inc(idx)
        if done:
            break
    let row = player.chunk.y * CHUNK_SIZE + player.pos.y + 1
    let col = player.chunk.x * CHUNK_SIZE + player.pos.x + 1
    return $(row * 1000 + 4 * col + ord(player.dir))

