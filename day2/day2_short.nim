# An optimized version of the Day 2 puzzle

import strformat
import tables

const COMBOS = {
    "A X": [4, 3],
    "A Y": [8, 4],
    "A Z": [3, 8],
    "B X": [1, 1],
    "B Y": [5, 5],
    "B Z": [9, 9],
    "C X": [7, 2],
    "C Y": [2, 6],
    "C Z": [6, 7],
}.toTable()

proc day2() =
    var part1 = 0
    var part2 = 0
    for line in lines("input.txt"):
        let new_score = COMBOS[line]
        part1 += new_score[0]
        part2 += new_score[1]
    echo(&"Part 1: {part1}, Part 2: {part2}")

day2()
