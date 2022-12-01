from osproc import execProcess
import os, strformat

echo(execProcess("nim js -d:release aoc.nim"))

for dir in walkDirs("day*"):
    # This assumes the pattern of dayX/dayX.nim
    echo(execProcess(&"nim js -d:release {dir}/{dir}.nim"))
