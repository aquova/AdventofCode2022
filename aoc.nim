import tables

import day1/day1
import day2/day2

const FUNCTION_TABLE = {
  "day1p1": day1p1, "day1p2": day1p2,
  "day2p1": day2p1, "day2p2": day2p2,
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
