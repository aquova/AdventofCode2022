import strscans
import strutils

const TIME_LIMIT_P1 = 24
const TIME_LIMIT_P2 = 32

type Material = enum
    Ore, Clay, Obsidian, Geode

type Blueprint = object
    ore_cost, clay_ore, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian, most_needed_ore: int

type Operation = object
    ore, clay, obsidian, geodes: int
    ore_robots, clay_robots, obsidian_robots, geode_robots: int

# Forward declare
proc tick(operation: Operation, bp: Blueprint, time, limit: int): int

proc newBlueprint(txt: string): Blueprint =
    let (success, _, ore, clay, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian) = txt.scanTuple("Blueprint $i: Each ore robot costs $i ore. Each clay robot costs $i ore. Each obsidian robot costs $i ore and $i clay. Each geode robot costs $i ore and $i obsidian.")
    if success:
        result.ore_cost = ore
        result.clay_ore = clay
        result.obsidian_ore = obsidian_ore
        result.obsidian_clay = obsidian_clay
        result.geode_ore = geode_ore
        result.geode_obsidian = geode_obsidian
        result.most_needed_ore = max(@[ore, clay, obsidian_ore, geode_ore])

proc newOperation(): Operation =
    result.ore = 0
    result.clay = 0
    result.obsidian = 0
    result.geodes = 0
    result.clay_robots = 0
    result.obsidian_robots = 0
    result.geode_robots = 0
    result.ore_robots = 1

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

proc shouldBuy(op: Operation, material: Material, bp: Blueprint): bool =
    case material:
        of Ore:
            return op.ore_robots < bp.most_needed_ore:
        of Clay:
            return op.clay_robots < bp.obsidian_clay:
        of Obsidian:
            return op.obsidian_robots < bp.geode_obsidian:
        of Geode:
            return true

proc buy(op: var Operation, material: Material, bp: Blueprint) =
    case material:
        of Ore:
            op.ore -= bp.ore_cost
        of Clay:
            op.ore -= bp.clay_ore
        of Obsidian:
            op.ore -= bp.obsidian_ore
            op.clay -= bp.obsidian_clay
        of Geode:
            op.ore -= bp.geode_ore
            op.obsidian -= bp.geode_obsidian

proc receive(op: var Operation, material: Material) =
    case material:
        of Ore:
            inc(op.ore_robots)
        of Clay:
            inc(op.clay_robots)
        of Obsidian:
            inc(op.obsidian_robots)
        of Geode:
            inc(op.geode_robots)

proc harvest(op: var Operation, time: var int) =
    op.ore += op.ore_robots
    op.clay += op.clay_robots
    op.obsidian += op.obsidian_robots
    op.geodes += op.geode_robots
    inc(time)

proc makePurchase(m: Material, operation: Operation, bp: Blueprint, time, limit: int): int =
    if time > limit:
        return operation.geodes

    var op = operation
    var curr_time = time
    while not op.canAfford(m, bp):
        op.harvest(curr_time)
        if curr_time > limit:
            return op.geodes

    if not op.shouldBuy(m, bp):
        return 0

    op.buy(m, bp)
    op.harvest(curr_time)
    op.receive(m)
    return tick(op, bp, curr_time, limit)

proc tick(operation: Operation, bp: Blueprint, time, limit: int): int =
    var best = 0
    for m in Material:
        let geodes = m.makePurchase(operation, bp, time, limit)
        best = max(geodes, best)
    return best

proc day19p1*(input: string): string =
    var blueprints: seq[Blueprint]
    for line in input.splitLines():
        blueprints.add(newBlueprint(line))

    var sum = 0
    for idx, bp in blueprints.pairs():
        let op = newOperation()
        let geodes = op.tick(bp, 1, TIME_LIMIT_P1)
        sum += geodes * (idx + 1)
    return $sum

proc day19p2*(input: string): string =
    var blueprints: seq[Blueprint]
    for line in input.splitLines():
        blueprints.add(newBlueprint(line))

    var product = 1
    for bp in blueprints[0..2]:
        let op = newOperation()
        let geodes = op.tick(bp, 1, TIME_LIMIT_P2)
        product *= geodes
    return $product

