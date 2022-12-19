import strscans
import strutils

const TIME_LIMIT = 24

type Material = enum
    Ore, Clay, Obsidian, Geode

type Blueprint = ref object
    ore, clay, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian: int

type Operation = ref object
    ore, clay, obsidian, geodes: int
    ore_robots, clay_robots, obsidian_robots, geode_robots: int

proc newBlueprint(txt: string): Blueprint =
    let (success, _, ore, clay, obsidian_ore, obsidian_clay, geode_ore, geode_obsidian) = txt.scanTuple("Blueprint $i: Each ore robot costs $i ore. Each clay robot costs $i ore. Each obsidian robot costs $i ore and $i clay. Each geode robot costs $i ore and $i obsidian.")
    if success:
        var bp = new(Blueprint)
        bp.ore = ore
        bp.clay = clay
        bp.obsidian_ore = obsidian_ore
        bp.obsidian_clay = obsidian_clay
        bp.geode_ore = geode_ore
        bp.geode_obsidian = geode_obsidian
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
            return op.ore >= bp.ore
        of Clay:
            return op.clay >= bp.clay
        of Obsidian:
            return op.ore >= bp.obsidian_ore and op.clay >= bp.obsidian_clay
        of Geode:
            return op.ore >= bp.geode_ore and op.obsidian >= bp.geode_obsidian

proc shouldBuy(op: Operation, material: Material, bp: Blueprint): bool =
    return false

proc tick(op: var Operation, bp: Blueprint) =
    # Need to build new robots before gathering
    op.ore += op.ore_robots
    op.clay += op.clay_robots
    op.obsidian += op.obsidian_robots
    op.geodes += op.geode_robots

proc numGeodes(op: Operation): int = return op.geodes

proc day19p1*(input: string): string =
    var blueprints: seq[Blueprint]
    for line in input.splitLines():
        blueprints.add(newBlueprint(line))

    var best = 0
    for bp in blueprints:
        var op = newOperation()
        for _ in countup(1, TIME_LIMIT):
            op.tick(bp)
        best = max(op.numGeodes(), best)
    return $best

proc day19p2*(input: string): string =
    discard
