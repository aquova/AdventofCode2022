from strutils import splitLines
import deques
import tables
import ../utils/point

type Grid = seq[seq[int]]

proc `[]`(map: Grid, p: Point): int =
    return map[p.y][p.x]

proc canClimb(a: Point, b: Point, map: Grid, going_up: bool): bool =
    if b.x < 0 or b.x > map[0].len() - 1:
        return false
    if b.y < 0 or b.y > map.len() - 1:
        return false

    if going_up:
        return (map[b] - map[a]) < 2
    else:
        return (map[a] - map[b]) < 2

proc parseMap(input: string, start: var Point, dst: var Point): Grid =
    let rows = input.splitLines()
    for y in 0..<rows.len():
        var row: seq[int]
        for x in 0..<rows[y].len():
            let height = rows[y][x]
            case height
                of 'S':
                    start = (x, y)
                    row.add(0)
                of 'E':
                    dst = (x, y)
                    row.add(ord('z') - ord('a'))
                else:
                    row.add(ord(height) - ord('a'))
        result.add(row)

proc bfs(map: Grid, start: Point, targets: seq[Point], going_up: bool): seq[Point] =
    var
        queue: Deque[Point]
        parents: Table[Point, Point]
        found_target: Point

    queue.addLast(start)
    while queue.len() > 0:
        let pos = queue.popFirst()
        if pos in targets:
            found_target = pos
            break

        for neighbor in pos.neighbors():
            if not parents.contains(neighbor) and pos.canClimb(neighbor, map, going_up):
                queue.addLast(neighbor)
                parents[neighbor] = pos

    var backtrack = found_target
    while backtrack != start:
        result.add(backtrack)
        backtrack = parents[backtrack]

proc day12p1*(input: string): string =
    var
        start, target: Point[int]
    let map = parseMap(input, start, target)
    let path = bfs(map, start, @[target], true)
    return $path.len()

proc day12p2*(input: string): string =
    var
        start, target: Point[int]
        targets: seq[Point[int]]
    let map = parseMap(input, start, target)

    for y in 0..<map.len():
        for x in 0..<map[y].len():
            if map[y][x] == 0:
                targets.add((x, y))

    let path = bfs(map, target, targets, false)
    return $path.len()
