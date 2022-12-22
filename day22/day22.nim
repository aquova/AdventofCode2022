import strutils
import tables
import ../utils/point

# Note: This needs to be 4 if you're doing a test input
# const CHUNK_SIZE = 50
const CHUNK_SIZE = 4

type Chunks = Table[Point[int], seq[string]]

type Direction = enum
    East, South, West, North

const DP = {
    North: (0, -1), South: (0, 1), East: (1, 0), West: (-1, 0)
}.toTable

type Player = object
    chunk: Point[int]
    pos: Point[int]
    dir: Direction

type Instructions = object
    distances: seq[int]
    turns: seq[bool]

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
        inc(starting.y)
    result.chunk = starting
    result.pos = (0, 0)
    result.dir = Direction.East

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

proc turn(p: var Player, clockwise: bool) =
    p.dir = case p.dir:
        of North:
            if clockwise: East else: West
        of South:
            if clockwise: West else: East
        of West:
            if clockwise: North else: South
        of East:
            if clockwise: South else: North

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
            player.turn(instructions.turns[idx])
            done = false
        inc(idx)
        if done:
            break
    let row = player.chunk.y * CHUNK_SIZE + player.pos.y + 1
    let col = player.chunk.x * CHUNK_SIZE + player.pos.x + 1
    return $(row * 1000 + 4 * col + ord(player.dir))

proc day22p2*(input: string): string =
    discard
