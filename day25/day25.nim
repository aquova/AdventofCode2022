import strutils
import tables
from unicode import reversed

const SNAFU_ENCODE = {
    0: '=', 1: '-', 2: '0', 3: '1', 4: '2'
}.toTable

const SNAFU_DECODE = {
    '2': 2, '1': 1, '0': 0, '-': -1, '=': -2
}.toTable

proc int2snafu(input: int): string =
    var n = input
    var output: string
    while n > 0:
        let remainder = (n + 2) mod 5
        output.add(SNAFU_ENCODE[remainder])
        n = (n + 2) div 5
    return output.reversed()

proc snafu2int(input: string): int =
    var multiplier = 1
    var snafu = input.reversed()
    for c in snafu:
        result += multiplier * SNAFU_DECODE[c]
        multiplier *= 5

proc day25p1*(input: string): string =
    var sum = 0
    for line in input.splitLines():
        sum += snafu2int(line)
    return int2snafu(sum)

proc day25p2*(input: string): string =
    discard
