import tables

import day1/day1
import day2/day2
import day3/day3
import day4/day4
import day5/day5
import day6/day6
import day7/day7

const FUNCTION_TABLE = {
  "day1p1": day1p1, "day1p2": day1p2,
  "day2p1": day2p1, "day2p2": day2p2,
  "day3p1": day3p1, "day3p2": day3p2,
  "day4p1": day4p1, "day4p2": day4p2,
  "day5p1": day5p1, "day5p2": day5p2,
  "day6p1": day6p1, "day6p2": day6p2,
  "day7p1": day7p1, "day7p2": day7p2,
}.toTable()

when defined(js):
  proc execute(fn: cstring, buffer: cstring): cstring {.exportc.} =
    try:
      return FUNCTION_TABLE[$fn]($buffer)
    except:
      return "Error!"
else:
  import os, strutils

  if paramCount() < 2:
    echo("./aoc dayXpY path/to/input.txt")
    quit(0)

  var f: File
  let function_name = paramStr(1)
  let input_name = paramStr(2)
  let success = f.open(input_name, FileMode.fmRead)
  if not success:
    echo("Unable to open " & input_name)
    quit(1)

  var input = f.readAll()
  input.stripLineEnd()

  echo(FUNCTION_TABLE[function_name](input))
