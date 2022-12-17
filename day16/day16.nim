import deques
import strformat
import sequtils
import strscans
import strutils
import tables
import ../utils/misc

import threadpool
{.experimental.}

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
    result = result.rev()

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

proc checkPathsTwoPlayer(start_human, stop_human, start_elephant, stop_elephant: string, start_t: int, graph: ValveGraph, info: ValveInfo, targets: seq[string]): int =
    let human_path = graph[start_human][stop_human]
    let elephant_path = graph[start_elephant][stop_elephant]

    # Figure out how long until someone opens a valve
    let human_cycles = if start_human == stop_human: 1 else: human_path.len() + 1
    let elephant_cycles = if start_elephant == stop_elephant: 1 else: elephant_path.len() + 1
    let stopping_cycles = min(human_cycles, elephant_cycles)
    let remaining_t = start_t - stopping_cycles
    if remaining_t < 0:
        return 0

    let human_offset = human_cycles - stopping_cycles
    let elephant_offset = elephant_cycles - stopping_cycles
    let human_arrived = human_offset == 0
    let elephant_arrived = elephant_offset == 0

    # For whoever reached their goal, remove from targets, sum up steam total
    var new_opened: seq[string]
    var our_steam = 0
    if human_arrived:
        new_opened.add(stop_human)
        our_steam += info[stop_human].calcTotalVent(remaining_t)

    if elephant_arrived:
        new_opened.add(stop_elephant)
        our_steam += info[stop_elephant].calcTotalVent(remaining_t)

    # If everything has been opened, we're done
    let unopened = targets - new_opened
    if unopened.len() == 0:
        return our_steam

    # Send whoever arrived to new targets. If one was on their way, don't redirect them
    var later_steam = 0
    if human_arrived and elephant_arrived:
        for next_human in unopened:
            for next_elephant in unopened:
                if next_human != next_elephant:
                    let path_steam = checkPathsTwoPlayer(stop_human, next_human, stop_elephant, next_elephant, remaining_t, graph, info, unopened)
                    later_steam = max(path_steam, later_steam)
    elif elephant_arrived:
        let curr_human = human_path[^human_offset]
        for next_elephant in unopened:
            if next_elephant != stop_human or unopened.len() == 1:
                let path_steam = checkPathsTwoPlayer(curr_human, stop_human, stop_elephant, next_elephant, remaining_t, graph, info, unopened)
                later_steam = max(path_steam, later_steam)
    elif human_arrived:
        let curr_elephant = elephant_path[^elephant_offset]
        for next_human in unopened:
            if next_human != stop_elephant or unopened.len() == 1:
                let path_steam = checkPathsTwoPlayer(stop_human, next_human, curr_elephant, stop_elephant, remaining_t, graph, info, unopened)
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
    var vents = newSeq[int](targets.len() * targets.len())
    parallel:
        for i, next_human in targets.pairs():
            for j, next_elephant in targets.pairs():
                if next_human != next_elephant:
                    let total = spawn checkPathsTwoPlayer(STARTING, next_human, STARTING, next_elephant, TIME_LIMIT_P2, graph, valves, targets)
                    echo(i * targets.len() + j)
                    vents[i * targets.len() + j] = total
    return $max(vents)

when isMainModule:
    var f: File
    discard f.open("input.txt", FileMode.fmRead)
    var input = f.readAll()
    input.stripLineEnd()
    echo(day16p2(input))
