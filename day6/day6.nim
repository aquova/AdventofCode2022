proc search(input: string, buffer_size: int): int =
    var idx = 0
    while idx < input.len() - buffer_size:
        var found = true
        block check:
            for i in countup(0, buffer_size - 1):
                for j in countup(i + 1, buffer_size - 1):
                    if input[idx + i] == input[idx + j]:
                        found = false
                        inc(idx)
                        break check
        if found:
            return idx + buffer_size

proc day6p1*(input: string): string =
    return $search(input, 4)

proc day6p2*(input: string): string =
    return $search(input, 14)

when isMainModule:
    import os
    echo(day6p1(paramStr(1)))
