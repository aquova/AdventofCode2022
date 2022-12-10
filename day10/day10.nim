from strutils import splitLines
import strscans

const WATCH_CYCLES = [20, 60, 100, 140, 180, 220]
const CRT_HEIGHT = 6
const CRT_WIDTH = 40

type CRT = array[CRT_HEIGHT * CRT_WIDTH, bool]

proc newCRT(): CRT =
    var crt: CRT
    for i in 0..<(CRT_HEIGHT * CRT_WIDTH):
        crt[i] = false
    return crt

proc drawPixel(crt: var CRT, x, cycle: int) =
    let pixel = (cycle - 1) mod (CRT_WIDTH * CRT_HEIGHT)
    let row_x = pixel mod CRT_WIDTH
    crt[pixel] = x in (row_x - 1)..(row_x + 1)

proc `$`(crt: CRT): string =
    result = ""
    for i in 0..<(CRT_HEIGHT * CRT_WIDTH):
        let c = if crt[i]:
                    '#'
                else:
                    '.'
        result.add(c)
        if (i + 1) mod CRT_WIDTH == 0:
            result.add('\n')

proc day10p1*(input: string): string =
    var
        x = 1
        cycle = 1
        strength = 0
    for line in input.splitLines():
        let (addx, v) = line.scanTuple("addx $i")
        if addx:
            inc(cycle)
            if cycle in WATCH_CYCLES:
                strength += cycle * x
            inc(cycle)
            x += v
            if cycle in WATCH_CYCLES:
                strength += cycle * x
        else: # Noop
            inc(cycle)
            if cycle in WATCH_CYCLES:
                strength += cycle * x
    return $strength

proc day10p2*(input: string): string =
    var
        x = 1
        cycle = 1
        crt = newCRT()

    for line in input.splitLines():
        let (addx, v) = line.scanTuple("addx $i")
        if addx:
            crt.drawPixel(x, cycle)
            inc(cycle)

            crt.drawPixel(x, cycle)
            inc(cycle)
            x += v
        else:
            crt.drawPixel(x, cycle)
            inc(cycle)
    return $crt
