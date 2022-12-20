import sequtils
import strutils
import ../utils/misc

const DECRYPT_KEY = 811589153
const NUM_MIX = 10

proc map_indices(vals, indices: seq[int]): seq[int] =
    for index in indices:
        result.add(vals[index])

proc mix(vals: seq[int], indices: var seq[int]) =
    let size = vals.len()
    for val_idx in 0..<size:
        var shift = vals[val_idx] mod (size - 1)
        var pos = indices.find(val_idx)
        while shift != 0:
            var next = pos + sign(shift)
            if next < 0:
                next = size - 1
            elif next == size:
                next = 0
            swap(indices[pos], indices[next])
            pos = next
            shift -= sign(shift)

proc day20p1*(input: string): string =
    let vals = input.splitLines().map(proc (x: string): int = parseInt(x))
    var indices = countup(0, vals.len() - 1).toSeq()
    mix(vals, indices)

    let merged = map_indices(vals, indices)
    let zero_index = merged.find(0)
    var sum = 0
    sum += merged[(zero_index + 1000) mod merged.len()]
    sum += merged[(zero_index + 2000) mod merged.len()]
    sum += merged[(zero_index + 3000) mod merged.len()]
    return $sum

proc day20p2*(input: string): string =
    let vals = input.splitLines().map(proc (x: string): int = parseInt(x) * DECRYPT_KEY)
    var indices = countup(0, vals.len() - 1).toSeq()
    for _ in countup(1, NUM_MIX):
        mix(vals, indices)

    let merged = map_indices(vals, indices)
    let zero_index = merged.find(0)
    var sum = 0
    sum += merged[(zero_index + 1000) mod merged.len()]
    sum += merged[(zero_index + 2000) mod merged.len()]
    sum += merged[(zero_index + 3000) mod merged.len()]
    return $sum

