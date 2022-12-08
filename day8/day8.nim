from strutils import splitLines

proc is_hidden(map: seq[string], x, y, width, height: int): bool =
    let tree = map[y][x]
    var hidden = false
    for dx in countdown(x - 1, 0):
        if map[y][dx] >= tree:
            hidden = true
            break
    if not hidden:
        return false

    hidden = false
    for dx in countup(x + 1, width - 1):
        if map[y][dx] >= tree:
            hidden = true
            break
    if not hidden:
        return false

    hidden = false
    for dy in countdown(y - 1, 0):
        if map[dy][x] >= tree:
            hidden = true
            break
    if not hidden:
        return false

    hidden = false
    for dy in countup(y + 1, height - 1):
        if map[dy][x] >= tree:
            hidden = true
            break
    return hidden

proc scenic_score(map: seq[string], x, y, width, height: int): int =
    let tree = map[y][x]
    result = 1

    var score = 0
    for dx in countdown(x - 1, 0):
        inc(score)
        if map[y][dx] >= tree:
            break
    result *= score

    score = 0
    for dx in countup(x + 1, width - 1):
        inc(score)
        if map[y][dx] >= tree:
            break
    result *= score

    score = 0
    for dy in countdown(y - 1, 0):
        inc(score)
        if map[dy][x] >= tree:
            break
    result *= score

    score = 0
    for dy in countup(y + 1, height - 1):
        inc(score)
        if map[dy][x] >= tree:
            break
    result *= score

proc day8p1*(input: string): string =
    let lines = input.splitLines()
    let height = lines.len()
    let width = lines[0].len()
    var cnt = 0
    for y in countup(1, height - 2):
        for x in countup(1, width - 2):
            if is_hidden(lines, x, y, width, height):
                inc(cnt)
    return $(width * height - cnt)

proc day8p2*(input: string): string =
    let lines = input.splitLines()
    let height = lines.len()
    let width = lines[0].len()
    var best = 0
    for y in countup(1, height - 2):
        for x in countup(1, width - 2):
            let score = scenic_score(lines, x, y, width, height)
            best = max(score, best)
    return $best
