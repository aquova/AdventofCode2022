from osproc import execProcess
import os, strformat

echo(execProcess("nim js aoc.nim"))

for dir in walkDirs("day*"):
    # This assumes the pattern of dayX/dayX.nim
    echo(execProcess(&"nim js {dir}/{dir}.nim"))
