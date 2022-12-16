import deques
import sequtils
import strscans
import strutils
import tables
import ../utils/misc

const STARTING = "AA"
const TIME_LIMIT = 30

type Valve = ref object
    flow_rate: int
    tunnels: seq[string]

type ValveInfo = Table[string, Valve]
type ValveGraph = Table[string, Table[string, seq[string]]]

proc newValve(rate: int, tunnels: seq[string]): Valve =
    result = new(Valve)
    result.flow_rate = rate
    result.tunnels = tunnels

proc calcTotalVent(v: Valve, remaining_t: int): int =
    return v.flow_rate * remaining_t

proc isUseless(v: Valve): bool =
    return v.flow_rate == 0

proc getNeighbors(v: Valve): seq[string] =
    return v.tunnels

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
    result = result.rev()

proc genFullGraph(valves: ValveInfo): ValveGraph =
    let nodes = valves.keys().toSeq()
    for node in nodes:
        var current_table: Table[string, seq[string]]
        for other in nodes:
            if node == other or valves[other].isUseless():
                continue
            let paths = bfs(node, other, valves)
            current_table[other] = paths
        result[node] = current_table

proc checkPaths(start, stop: string, start_t: int, graph: ValveGraph, info: ValveInfo, opened: seq[string]): int =
    let remaining_t = start_t - graph[start][stop].len() - 1
    if remaining_t < 0:
        return 0
    let our_steam = info[stop].calcTotalVent(remaining_t)
    let new_opened = opened & @[stop]
    var later_steam = 0
    for other in graph[stop].keys():
        if other notin opened:
            let path_steam = checkPaths(stop, other, remaining_t, graph, info, new_opened)
            later_steam = max(later_steam, path_steam)
    return our_steam + later_steam

proc parseInput(input: string): ValveInfo =
    for line in input.splitLines():
        let (success, name, rate, neighbors) = line.scanTuple("Valve $w has flow rate=$i; tunnels lead to valves $*$.")
        if success:
            let neighbor_list = neighbors.split(", ")
            result[name] = newValve(rate, neighbor_list)
        else:
            let (_, name, rate, neighbor) = line.scanTuple("Valve $w has flow rate=$i; tunnel leads to valve $*$.")
            result[name] = newValve(rate, @[neighbor])

proc day16p1*(input: string): string =
    var valves = parseInput(input)
    let graph = valves.genFullGraph()
    var vented = 0
    for other in graph[STARTING].keys():
        let total = checkPaths(STARTING, other, TIME_LIMIT, graph, valves, @[])
        vented = max(total, vented)
    return $vented

proc day16p2*(input: string): string =
    discard
