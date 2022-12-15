import strscans
import strutils
import ../utils/point
import ../utils/range

const TARGET_Y = 2_000_000
const P2_BOUND = 4_000_000

type Pair = object
    sensor: Point[int]
    beacon: Point[int]

proc newPair(sensor: Point[int], beacon: Point[int]): Pair =
    result.sensor = sensor
    result.beacon = beacon

proc isInside(p: Point[int], pair: Pair): bool =
    return p.manhattan_dist(pair.sensor) <= pair.beacon.manhattan_dist(pair.sensor)

proc inBounds(p: Point[int]): bool =
    return p.x >= 0 and p.y >= 0 and p.x <= P2_BOUND and p.y <= P2_BOUND

proc getEdges(pair: Pair): seq[Point[int]] =
    let center = pair.sensor
    let dst = center.manhattan_dist(pair.beacon)
    let top: Point[int] = (center.x, center.y - dst - 1)
    let bottom: Point[int] = (center.x, center.y + dst + 1)

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
        ranges: seq[Range[int]]
        row_beacons: seq[Point[int]]
    for line in input.splitLines():
        let (success, sx, sy, bx, by) = line.scanTuple("Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i")
        if success:
            pairs.add(newPair((sx, sy), (bx, by)))

    for pair in pairs:
        let center_x = pair.sensor.x
        let dst = pair.sensor.manhattan_dist(pair.beacon)
        let height = pair.sensor.manhattan_dist((center_x, TARGET_Y))
        let dx = dst - height
        if dx > 0:
            let new_range = newRange(center_x - dx, center_x + dx)
            ranges.add(new_range)
        if pair.beacon.y == TARGET_Y and pair.beacon notin row_beacons:
            row_beacons.add(pair.beacon)

    let merged = ranges.combine()
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

