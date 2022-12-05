from strutils import isDigit, splitLines
import deques
import strscans

type stacks = seq[Deque[char]]

proc parse_input(input: string, num_stacks: int): stacks =
  let lines = input.splitLines()
  for i in countup(0, num_stacks - 1):
    var column: Deque[char]
    let x = 4 * i + 1
    var y = 0
    while true:
      if lines[y].len() < x:
        inc(y)
        continue

      let c = lines[y][x]
      if c.isDigit():
        result.add(column)
        break
      elif c == ' ':
        inc(y)
      else:
        column.addFirst(c)
        inc(y)

proc day5p1*(input: string): string =
    var idx = 0
    let lines = input.splitLines()
    while lines[idx] != "":
      inc(idx)
    let num_stacks = int((lines[idx - 1].len() + 2) / 4)

    var crates = parse_input(input, num_stacks)

    while idx < lines.len():
      let (success, stack_num, src, dst) = lines[idx].scanTuple("move $i from $i to $i")
      if success:
        for _ in countup(0, stack_num - 1):
          let top = crates[src - 1].popLast()
          crates[dst - 1].addLast(top)
      inc(idx)

    for i in countup(0, crates.len() - 1):
      let c = crates[i].popLast()
      result.add(c)

proc day5p2*(input: string): string =
    var idx = 0
    let lines = input.splitLines()
    while lines[idx] != "":
      inc(idx)
    let num_stacks = int((lines[idx - 1].len() + 2) / 4)

    var crates = parse_input(input, num_stacks)

    while idx < lines.len():
      let (success, stack_num, src, dst) = lines[idx].scanTuple("move $i from $i to $i")
      if success:
        var pile: seq[char]
        for _ in countup(0, stack_num - 1):
          let top = crates[src - 1].popLast()
          pile.add(top)

        for i in countdown(pile.len() - 1, 0):
          crates[dst - 1].addLast(pile[i])
      inc(idx)

    for i in countup(0, crates.len() - 1):
      let c = crates[i].popLast()
      result.add(c)
