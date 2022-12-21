import strscans
import strutils
import tables

const HUMAN_NAME = "humn"

type Monkey = object
    constant: int
    left, right: string
    operator: char

type MonkeyTable = Table[string, Monkey]

proc parseMonkeys(input: string): MonkeyTable =
    var monkeys: Table[string, Monkey]
    for line in input.splitLines():
        var m: Monkey
        let (is_const, name, val) = line.scanTuple("$w: $i")
        if is_const:
            m.constant = val
            monkeys[name] = m
        else:
            let (_, name, left, op, right) = line.scanTuple("$w: $w $c $w")
            m.left = left
            m.operator = op
            m.right = right
            monkeys[name] = m
    return monkeys

proc isConst(m: Monkey): bool =
    return m.left == ""

proc yell(yeller: string, monkeys: MonkeyTable): int =
    let info = monkeys[yeller]
    if info.isConst():
        return info.constant
    let left = yell(info.left, monkeys)
    let right = yell(info.right, monkeys)
    case info.operator:
        of '+':
            return left + right
        of '-':
            return left - right
        of '*':
            return left * right
        of '/':
            return left div right
        else:
            discard

proc containsHumn(name: string, monkeys: MonkeyTable): bool =
    if name == HUMAN_NAME:
        return true
    let node = monkeys[name]
    if node.isConst():
        return false
    return node.left.containsHumn(monkeys) or node.right.containsHumn(monkeys)

proc backtrack(name: string, monkeys: MonkeyTable, prev: int): int =
    if name == HUMAN_NAME:
        return prev
    let node = monkeys[name]
    let humn_right = node.right.containsHumn(monkeys)
    var target = 0
    case node.operator:
        of '+':
            if humn_right:
                target = prev - node.left.yell(monkeys)
            else:
                target = prev - node.right.yell(monkeys)
        of '-':
            if humn_right:
                target = node.left.yell(monkeys) - prev
            else:
                target = prev + node.right.yell(monkeys)
        of '*':
            if humn_right:
                target = prev div node.left.yell(monkeys)
            else:
                target = prev div node.right.yell(monkeys)
        of '/':
            if humn_right:
                target = node.left.yell(monkeys) div prev
            else:
                target = node.right.yell(monkeys) * prev
        else: discard
    if humn_right:
        return node.right.backtrack(monkeys, target)
    return node.left.backtrack(monkeys, target)

proc day21p1*(input: string): string =
    let monkeys = parseMonkeys(input)
    return $yell("root", monkeys)

proc day21p2*(input: string): string =
    let monkeys = parseMonkeys(input)
    let root = monkeys["root"]
    if root.right.containsHumn(monkeys):
        let target = root.left.yell(monkeys)
        return $root.right.backtrack(monkeys, target)
    let target = root.right.yell(monkeys)
    return $root.left.backtrack(monkeys, target)
