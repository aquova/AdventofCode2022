import deques
import strscans
import strutils
import tables

const STARTING = "AA"
const TIME_LIMIT = 30

type Valve = ref object
    flow_rate: int
    tunnels: seq[string]
    turned: bool

type ValveInfo = Table[string, Valve]

proc newValve(rate: int, tunnels: seq[string]): Valve =
    result = new(Valve)
    result.flow_rate = rate
    result.tunnels = tunnels
    result.turned = false

proc calcTotalVent(v: Valve, remaining_t: int): int =
    if v.turned:
        return 0
    return v.flow_rate * remaining_t

proc isUseless(v: Valve): bool =
    return v.flow_rate == 0

proc getNeighbors(v: Valve): seq[string] =
    return v.tunnels

proc setTurned(v: var Valve) =
    v.turned = true

proc bfs(start: string, target: string, info: ValveInfo): seq[string] =
    var
        queue: Deque[string]
        parents: Table[string, string]

    queue.addLast(start)
    while queue.len() > 0:
        let pos = queue.popFirst()
        if pos == target:
            break

        let v = info[pos]
        for neighbor in v.getNeighbors():
            if not parents.contains(neighbor):
                queue.addLast(neighbor)
                parents[neighbor] = pos

    var backtrack = target
    while backtrack != start:
        result.add(backtrack)
        backtrack = parents[backtrack]

proc findBestNeighbor(v: string, info: ValveInfo, remaining_t: int): string =
    var graph_table: Table[string, seq[string]]
    for k in info.keys():
        graph_table[k] = bfs(v, k, info)

    var best = 0
    var best_node: string
    for k, v in info:
        if not v.isUseless():
            let num_moves = graph_table[k].len()
            let time_left = remaining_t - num_moves - 1
            if time_left > 0:
                let steam = v.calcTotalVent(time_left)
                if steam > best:
                    best = steam
                    best_node = k
    return best_node

proc day16p1*(input: string): string =
    var valves: ValveInfo
    for line in input.splitLines():
        let (success, name, rate, neighbors) = line.scanTuple("Valve $w has flow rate=$i; tunnels lead to valves $*$.")
        if success:
            let neighbor_list = neighbors.split(", ")
            valves[name] = newValve(rate, neighbor_list)
        else:
            let (_, name, rate, neighbor) = line.scanTuple("Valve $w has flow rate=$i; tunnel leads to valve $*$.")
            valves[name] = newValve(rate, @[neighbor])

    var pos = STARTING
    var time_remaining = TIME_LIMIT
    var vented = 0
    while time_remaining > 0:
        let best = pos.findBestNeighbor(valves, time_remaining)
        if best == "":
            break
        let path = bfs(pos, best, valves)
        time_remaining -= path.len() + 1
        valves[best].setTurned()
        vented += valves[best].calcTotalVent(time_remaining)

    return $vented

proc day16p2*(input: string): string =
    discard
