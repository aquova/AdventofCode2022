from algorithm import sort
import parseutils
import strutils
import strscans

const NUM_ROUNDS_P1 = 20
const NUM_ROUNDS_P2 = 10000

type Monkey = object
  id: int
  things: seq[int]
  squared: bool
  operator: char
  scalar: int
  test_div: int
  true_target: int
  false_target: int
  inspections: int

proc parseInts(input: seq[string]): seq[int] =
  for s in input:
    result.add(parseInt(s))

proc parseMonkey(input: string): Monkey =
  var monkey: Monkey
  let info = input.split("\n")

  let (_, id) = info[0].scanTuple("Monkey $i:")
  monkey.id = id

  let (_, things) = info[1].scanTuple("$sStarting items: $*$.")
  monkey.things = parseInts(things.split(", "))

  let squared = info[2].scanTuple("$sOperation: new = old * old")
  if not squared:
    let (_, op, scalar) = info[2].scanTuple("$sOperation: new = old $c $i")
    monkey.operator = op
    monkey.scalar = scalar
  monkey.squared = squared

  let (_, divisor) = info[3].scanTuple("$sTest: divisible by $i")
  monkey.test_div = divisor

  let (_, true_test) = info[4].scanTuple("$sIf true: throw to monkey $i")
  monkey.true_target = true_test

  let (_, false_test) = info[5].scanTuple("$sIf false: throw to monkey $i")
  monkey.false_target = false_test

  monkey.inspections = 0

  return monkey

proc inspectionCmp(a, b: Monkey): int =
  if a.inspections < b.inspections: 1
  else: -1

proc day11p1*(input: string): string =
  let blocks = input.split("\n\n")
  var monkeys: seq[Monkey]
  for b in blocks:
    monkeys.add(parseMonkey(b))

  for _ in countup(1, NUM_ROUNDS_P1):
    for idx in 0..<monkeys.len():
      while monkeys[idx].things.len() > 0:
        inc(monkeys[idx].inspections)
        var thing = monkeys[idx].things.pop()
        if monkeys[idx].squared:
          thing *= thing
        elif monkeys[idx].operator == '*':
          thing *= monkeys[idx].scalar
        else:
          thing += monkeys[idx].scalar

        thing = thing div 3

        if thing mod monkeys[idx].test_div == 0:
          monkeys[monkeys[idx].true_target].things.add(thing)
        else:
          monkeys[monkeys[idx].false_target].things.add(thing)

  sort(monkeys, inspectionCmp)
  return $(monkeys[0].inspections * monkeys[1].inspections)

proc day11p2*(input: string): string =
  let blocks = input.split("\n\n")
  var monkeys: seq[Monkey]
  for b in blocks:
    monkeys.add(parseMonkey(b))

  var lcm = 1
  for m in monkeys:
    lcm *= m.test_div

  for _ in countup(1, NUM_ROUNDS_P2):
    for idx in 0..<monkeys.len():
      while monkeys[idx].things.len() > 0:
        inc(monkeys[idx].inspections)
        var thing = monkeys[idx].things.pop()
        if monkeys[idx].squared:
          thing *= thing
        elif monkeys[idx].operator == '*':
          thing *= monkeys[idx].scalar
        else:
          thing += monkeys[idx].scalar

        thing = thing mod lcm

        if thing mod monkeys[idx].test_div == 0:
          monkeys[monkeys[idx].true_target].things.add(thing)
        else:
          monkeys[monkeys[idx].false_target].things.add(thing)

  sort(monkeys, inspectionCmp)
  return $(monkeys[0].inspections * monkeys[1].inspections)
