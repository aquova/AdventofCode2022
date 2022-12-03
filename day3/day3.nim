from strutils import contains, splitLines
import sets

proc char_value(c: char): int =
    if c >= 'A' and c <= 'Z':
        return ord(c) - 38
    else:
        return ord(c) - 96

proc day3p1*(input: string): string =
    var sum = 0
    for line in input.splitLines():
        let midpt = int(line.len() / 2)
        let left = line.substr(0, midpt)
        let right = line.substr(midpt, line.len())
        for c in left:
            if right.contains(c):
                sum += char_value(c)
                break
    return $sum

proc day3p2*(input: string): string =
    var idx = 0
    var sum = 0
    let lines = input.splitLines()
    while idx < lines.len():
        let set_a = lines[idx].toHashSet()
        let set_b = lines[idx + 1].toHashSet()
        let set_c = lines[idx + 2].toHashSet()
        var intersection = set_a * set_b * set_c
        sum += char_value(intersection.pop()) # Assumes only one match
        idx += 3
    return $sum

