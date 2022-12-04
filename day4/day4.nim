from strutils import splitLines
import strscans

proc day4p1*(input: string): string =
    var cnt = 0
    for line in input.splitLines():
        let (success, a1, a2, b1, b2) = line.scanTuple("$i-$i,$i-$i")
        if success:
            if (a1 <= b1 and b2 <= a2) or (b1 <= a1 and a2 <= b2):
                inc(cnt)
    return $cnt

proc day4p2*(input: string): string =
    var cnt = 0
    for line in input.splitLines():
        let (success, a1, a2, b1, b2) = line.scanTuple("$i-$i,$i-$i")
        if success:
            if a1 in (b1..b2) or b1 in (a1..a2) or a2 in (b1..b2) or b2 in (a1..a2):
                inc(cnt)
    return $cnt
