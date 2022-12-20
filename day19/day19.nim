import strscans
import strutils

const TIME_LIMIT = 24

type Material = enum
    None, Ore, Clay, Obsidian, Geode

type Blueprint = ref object
    ore_cost, clay_ore, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian, most_needed_ore: int

type Operation = ref object
    ore, clay, obsidian, geodes: int
    ore_robots, clay_robots, obsidian_robots, geode_robots: int

proc newBlueprint(txt: string): Blueprint =
    let (success, _, ore, clay, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian) = txt.scanTuple("Blueprint $i: Each ore robot costs $i ore. Each clay robot costs $i ore. Each obsidian robot costs $i ore and $i clay. Each geode robot costs $i ore and $i obsidian.")
    if success:
        var bp = new(Blueprint)
        bp.ore_cost = ore
        bp.clay_ore = clay
        bp.obsidian_ore = obsidian_ore
        bp.obsidian_clay = obsidian_clay
        bp.geode_ore = geode_ore
        bp.geode_obsidian = geode_obsidian
        bp.most_needed_ore = max(@[ore, clay, obsidian_ore, geode_ore])
        return bp

proc newOperation(): Operation =
    var op = new(Operation)
    op.ore = 0
    op.clay = 0
    op.obsidian = 0
    op.geodes = 0
    op.clay_robots = 0
    op.obsidian_robots = 0
    op.geode_robots = 0
    op.ore_robots = 1
    return op

proc canAfford(op: Operation, material: Material, bp: Blueprint): bool =
    case material
        of Ore:
            return op.ore >= bp.ore_cost
        of Clay:
            return op.ore >= bp.clay_ore
        of Obsidian:
            return op.ore >= bp.obsidian_ore and op.clay >= bp.obsidian_clay
        of Geode:
            return op.ore >= bp.geode_ore and op.obsidian >= bp.geode_obsidian
        else:
            return true

proc shouldBuy(op: Operation, material: Material, bp: Blueprint): bool =
    case material:
        of Ore:
            return op.ore_robots >= bp.most_needed_ore:
        of Clay:
            return op.clay_robots >= bp.obsidian_clay:
        of Obsidian:
            return op.obsidian_robots >= bp.geode_obsidian:
        else:
            return true

proc buy(op: var Operation, material: Material, bp: Blueprint) =
    case material:
        of Ore:
            op.ore -= bp.ore_cost
            inc(op.ore_robots)
        of Clay:
            op.ore -= bp.clay_ore
            inc(op.clay_robots)
        of Obsidian:
            op.ore -= bp.obsidian_ore
            op.clay -= bp.obsidian_clay
            inc(op.obsidian_robots)
        of Geode:
            op.ore -= bp.geode_ore
            op.obsidian -= bp.geode_obsidian
            inc(op.geode_robots)
        else:
            discard

proc harvest(op: var Operation, time: var int) =
    op.ore += op.ore_robots
    op.clay += op.clay_robots
    op.obsidian += op.obsidian_robots
    op.geodes += op.geode_robots
    inc(time)

proc tick(operation: Operation, bp: Blueprint, last_material: Material, time: int): int =
    if time == TIME_LIMIT:
        return operation.geodes

    var best = 0
    for m in Material:
        if last_material == None and m != None and operation.canAfford(m, bp):
            continue

        var op = operation.deepCopy()
        var curr_time = time
        while not op.canAfford(m, bp):
            op.harvest(curr_time)
            if curr_time == TIME_LIMIT:
                best = max(op.geodes, best)
                continue

        if op.shouldBuy(m, bp):
            op.buy(m, bp)
        else:
            continue

        op.harvest(curr_time)
        let geodes = tick(op, bp, m, curr_time)
        best = max(geodes, best)
    return best

proc day19p1*(input: string): string =
    var blueprints: seq[Blueprint]
    for line in input.splitLines():
        blueprints.add(newBlueprint(line))

    var best = 0
    # for bp in blueprints:
    let bp = blueprints[0]
    let op = newOperation()
    let n = op.tick(bp, None, 1)
    best = max(n, best)
    return $best

proc day19p2*(input: string): string =
    discard
