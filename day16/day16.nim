from algorithm import reversed
import deques
import math
import sequtils
import strformat
import strscans
import strutils
import tables
import ../utils/misc

const STARTING = "AA"
const TIME_LIMIT_P1 = 30
const TIME_LIMIT_P2 = 26

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
    result = result.reversed()

proc genFullGraph(valves: ValveInfo): ValveGraph =
    let nodes = valves.keys().toSeq()
    for node in nodes:
        var current_table: Table[string, seq[string]]
        for other in nodes:
            if node == other:
                current_table[node] = @[node]
            else:
                let paths = bfs(node, other, valves)
                current_table[other] = paths
        result[node] = current_table

proc getTargets(valves: ValveInfo): seq[string] =
    for k, v in valves:
        if not v.isUseless():
            result.add(k)

proc checkPaths(start, stop: string, start_t: int, graph: ValveGraph, info: ValveInfo, targets: seq[string]): int =
    let remaining_t = start_t - graph[start][stop].len() - 1
    if remaining_t < 0:
        return 0

    let unopened = targets - @[stop]
    let our_steam = info[stop].calcTotalVent(remaining_t)
    var later_steam = 0
    for other in unopened:
        let path_steam = checkPaths(stop, other, remaining_t, graph, info, unopened)
        later_steam = max(later_steam, path_steam)
    return our_steam + later_steam

proc getSubsets(s: seq[string]): seq[seq[string]] =
    let num_subsets = 2 ^ s.len()
    for mask in 0..<num_subsets:
        var subset: seq[string]
        for i in 0..<s.len():
            if (mask and (1 shl i)) != 0:
                subset.add(s[i])
        if s - subset notin result:
            result.add(subset)

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
    let targets = valves.getTargets()
    var vented = 0
    for other in targets:
        let total = checkPaths(STARTING, other, TIME_LIMIT_P1, graph, valves, targets)
        vented = max(total, vented)
    return $vented

proc day16p2*(input: string): string =
    var valves = parseInput(input)
    let graph = valves.genFullGraph()
    let targets = valves.getTargets()
    let subsets = targets.getSubsets()
    echo(subsets.len())
    var best = 0
    var cnt = 0
    for subset in subsets:
        # Human & elephant should roughly do the same work. Skip instances where it's really unbalanced
        if subset.len() < int(0.3 * float(targets.len())) or subset.len() > int(0.7 * float(targets.len())):
            continue
        echo(&"Trying number: {cnt}")
        let elephant_targets = targets - subset
        var best_human, best_elephant = 0
        for other in subset:
            best_human = max(best_human, checkPaths(STARTING, other, TIME_LIMIT_P2, graph, valves, subset))
        for other in elephant_targets:
            best_elephant =max(best_elephant, checkPaths(STARTING, other, TIME_LIMIT_P2, graph, valves, elephant_targets))
        best = max(best_human + best_elephant, best)
        inc(cnt)
    return $best

