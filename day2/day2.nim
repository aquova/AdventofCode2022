from strutils import splitLines
import strscans
import tables

const SCORE_TABLE = {
    'A': 1, 'B': 2, 'C': 3,
    'X': 1, 'Y': 2, 'Z': 3
}.toTable()

const PART2_TABLE = {
    'X': 0, 'Y': 3, 'Z': 6
}.toTable()

proc win_pts(ours: char, theirs: char): int =
    if ours == 'X':
        if theirs == 'A':
            return 3
        elif theirs == 'B':
            return 0
        else:
            return 6
    elif ours == 'Y':
        if theirs == 'A':
            return 6
        elif theirs == 'B':
            return 3
        else:
            return 0
    else:
        if theirs == 'A':
            return 0
        elif theirs == 'B':
            return 6
        else:
            return 3

proc forced_pts(ours: char, theirs: char): int =
    if ours == 'Y':
        return SCORE_TABLE[theirs]
    elif ours == 'X':
        if theirs == 'A':
            return SCORE_TABLE['C']
        elif theirs == 'B':
            return SCORE_TABLE['A']
        else:
            return SCORE_TABLE['B']
    elif ours == 'Z':
        if theirs == 'A':
            return SCORE_TABLE['B']
        elif theirs == 'B':
            return SCORE_TABLE['C']
        else:
            return SCORE_TABLE['A']

proc day2p1*(input: string): string =
    var score = 0
    for line in input.splitLines():
        let (success, opponent, ours) = line.scanTuple("$c $c")
        if success:
            let our_pts = SCORE_TABLE[ours]
            let won_pts = win_pts(ours, opponent)
            score += our_pts + won_pts
    return $score

proc day2p2*(input: string): string =
    var score = 0
    for line in input.splitLines():
        let (success, opponent, ours) = line.scanTuple("$c $c")
        if success:
            let our_pts = forced_pts(ours, opponent)
            let won_pts = PART2_TABLE[ours]
            score += our_pts + won_pts
    return $score
