import sets
import strscans
import strutils
import ../utils/point

const SOURCE: Point[int] = (500, 0)

proc new_point(raw: string): Point[int] =
    let (success, x, y) = raw.scanTuple("$i,$i")
    if success:
        result = new_point(x, y)

proc draw_line(p1: Point, p2: Point): seq[Point] =
    if p1.x < p2.x:
        for x in countup(p1.x, p2.x):
            result.add(new_point(x, p1.y))
    elif p2.x < p1.x:
        for x in countup(p2.x, p1.x):
            result.add(new_point(x, p1.y))
    elif p1.y < p2.y:
        for y in countup(p1.y, p2.y):
            result.add(new_point(p1.x, y))
    else:
        for y in countup(p2.y, p1.y):
            result.add(new_point(p1.x, y))

proc parse_rock(input: string): HashSet[Point[int]] =
    for line in input.splitLines():
        let vectors = line.split(" -> ")
        for idx in 0..<(vectors.len() - 1):
            let p1 = new_point(vectors[idx])
            let p2 = new_point(vectors[idx + 1])
            let line = draw_line(p1, p2)
            var line_set = line.toHashSet()
            result.incl(line_set)

proc abyss_level(rocks: HashSet[Point[int]]): int =
    result = 0
    for rock in rocks:
        result = max(result, rock.y)

proc drop_sand(rock: var HashSet[Point[int]], abyss: int, floor: bool): bool =
    var sand = SOURCE
    while sand.y < abyss or floor:
        if floor and sand.y == abyss:
            rock.incl(sand)
            return true

        if (sand.x, sand.y + 1) notin rock:
            sand = (sand.x, sand.y + 1)
        elif (sand.x - 1, sand.y + 1) notin rock:
            sand = (sand.x - 1, sand.y + 1)
        elif (sand.x + 1, sand.y + 1) notin rock:
            sand = (sand.x + 1, sand.y + 1)
        elif floor and sand == SOURCE:
            return false
        else:
            rock.incl(sand)
            return true
    return false

proc day14p1*(input: string): string =
    var rocks = parse_rock(input)
    let abyss = abyss_level(rocks)
    var cnt = 0
    while true:
        let ret = drop_sand(rocks, abyss, false)
        if ret:
            inc(cnt)
        else:
            break
    return $cnt

proc day14p2*(input: string): string =
    var rocks = parse_rock(input)
    var floor = abyss_level(rocks)
    floor += 1
    var cnt = 1 # Off by one to include the source
    while true:
        let ret = drop_sand(rocks, floor, true)
        if ret:
            inc(cnt)
        else:
            break
    return $cnt
