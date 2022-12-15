from algorithm import sorted
import strscans
import strutils

const TARGET_Y = 2_000_000
const P2_BOUND = 4_000_000

type Point = tuple
    x, y: int

type Pair = object
    sensor: Point
    beacon: Point

type Range = object
    left, right: int

proc newRange(left: int, right: int): Range =
    result.left = left
    result.right = right

proc contains(r:Range, v: int): bool =
    return r.left <= v and v <= r.right

proc overlaps(a: Range, b: Range): bool =
    return a.contains(b.left) or a.contains(b.right)

proc merge(a: Range, b: Range): Range =
    return newRange(min(a.left, b.left), max(a.right, b.right))

proc cmp(a: Range, b: Range): int =
    return system.cmp(a.left, b.left)

proc merge(ranges: seq[Range]): seq[Range] =
    let sorted = sorted(ranges, cmp)
    var current = sorted[0]
    var idx = 1
    while idx < sorted.len():
        let other = sorted[idx]
        if current.overlaps(other):
            current = current.merge(other)
        else:
            result.add(current)
            current = other
        inc(idx)
    result.add(current)

proc size(r: Range): int =
    return r.right - r.left + 1

proc newPair(sensor: Point, beacon: Point): Pair =
    result.sensor = sensor
    result.beacon = beacon

proc dist(a: Point, b: Point): int =
    return abs(a.x - b.x) + abs(a.y - b.y)

proc isInside(p: Point, pair: Pair): bool =
    return p.dist(pair.sensor) <= pair.beacon.dist(pair.sensor)

proc inBounds(p: Point): bool =
    return p.x >= 0 and p.y >= 0 and p.x <= P2_BOUND and p.y <= P2_BOUND

proc getEdges(pair: Pair): seq[Point] =
    let center = pair.sensor
    let dst = center.dist(pair.beacon)
    let top: Point = (center.x, center.y - dst - 1)
    let bottom: Point = (center.x, center.y + dst + 1)

    for d in countup(0, dst + 1):
        let tl = (top.x - d, top.y + d)
        if tl.inBounds():
            result.add(tl)
        let tr = (top.x + d, top.y + d)
        if tr.inBounds():
            result.add(tr)
        let bl = (bottom.x - d, bottom.y - d)
        if bl.inBounds():
            result.add(bl)
        let br = (bottom.x + d, bottom.y - d)
        if br.inBounds():
            result.add(br)

proc day15p1*(input: string): string =
    var
        pairs: seq[Pair]
        ranges: seq[Range]
        row_beacons: seq[Point]
    for line in input.splitLines():
        let (success, sx, sy, bx, by) = line.scanTuple("Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i")
        if success:
            pairs.add(newPair((sx, sy), (bx, by)))

    for pair in pairs:
        let center_x = pair.sensor.x
        let dst = pair.sensor.dist(pair.beacon)
        let height = pair.sensor.dist((center_x, TARGET_Y))
        let dx = dst - height
        if dx > 0:
            let new_range = newRange(center_x - dx, center_x + dx)
            ranges.add(new_range)
        if pair.beacon.y == TARGET_Y and pair.beacon notin row_beacons:
            row_beacons.add(pair.beacon)

    let merged = ranges.merge()
    var cnt = 0
    for r in merged:
        cnt += r.size()
        for b in row_beacons:
            if r.contains(b.y):
                dec(cnt)
    return $cnt

proc day15p2*(input: string): string =
    var pairs: seq[Pair]
    for line in input.splitLines():
        let (success, sx, sy, bx, by) = line.scanTuple("Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i")
        if success:
            pairs.add(newPair((sx, sy), (bx, by)))

    # The map is comprised of overlapping diamonds with a single gap somewhere
    # This gap must be located just outside (one cell away) from the slope of a diamond
    # Iterate through each sensor, iterate diagonally from one vertex to the next, and see if any is located within no other sensor diamond
    for pair in pairs:
        for p in pair.getEdges():
            var found = true
            for pair in pairs:
                if p.isInside(pair):
                    found = false
                    break
            if found:
                return $(P2_BOUND * p.x + p.y)

