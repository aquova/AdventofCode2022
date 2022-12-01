from algorithm import sorted, SortOrder
from strutils import parseInt, splitLines

proc day1p1*(input: string): string =
    var max = 0
    var sum = 0
    for line in input.splitLines():
        if line == "":
            if sum > max:
                max = sum
            sum = 0
        else:
            sum += parseInt(line)
    return $max

proc day1p2*(input: string): string =
    var sum = 0
    var sums: seq[int]
    for line in input.splitLines():
        if line == "":
            sums.add(sum)
            sum = 0
        else:
            sum += parseInt(line)
    sums = sums.sorted(system.cmp[int], SortOrder.Descending)
    return $(sums[0] + sums[1] + sums[2])

