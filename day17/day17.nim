const NUM_PIECES_P1 = 2022
const NUM_PIECES_P2 = 1_000_000_000_000
const CYCLE_HEIGHT = 30 # Arbitrary number of rows to check for a cycle
const PIECE_HEIGHT = 4

type Board = seq[uint8]
type Piece = array[PIECE_HEIGHT, uint8]
type CyclePair = tuple
    cnt, idx, layer: int

const HORZ_PIECE = [
    0b00000000'u8,
    0b00000000'u8,
    0b00000000'u8,
    0b00011110'u8,
]
const PLUS_PIECE = [
    0b00000000'u8,
    0b00001000'u8,
    0b00011100'u8,
    0b00001000'u8,
]
const L_PIECE = [
    0b00000000'u8,
    0b00000100'u8,
    0b00000100'u8,
    0b00011100'u8,
]
const VERT_PIECE = [
    0b00010000'u8,
    0b00010000'u8,
    0b00010000'u8,
    0b00010000'u8,
]
const SQUARE_PIECE = [
    0b00000000'u8,
    0b00000000'u8,
    0b00011000'u8,
    0b00011000'u8,
]

const PIECES = [HORZ_PIECE, PLUS_PIECE, L_PIECE, VERT_PIECE, SQUARE_PIECE]

proc `$`(b: Board): string =
    for i in countdown(b.len() - 1, 0):
        let layer = b[i]
        var mask = 0b0100_0000'u8
        while mask != 0:
            result.add(if (mask and layer) != 0: "#" else: ".")
            mask = mask shr 1
        result.add("\n")

proc can_shift(piece: Piece, shift_right: bool): bool =
    let mask = if shift_right: 0b0000_0001'u8 else: 0b0100_0000'u8
    for layer in piece:
        if (layer and mask) != 0:
            return false
    return true

proc can_shift(piece: Piece, board: Board, board_layer: int, shift_right: bool): bool =
    if not piece.can_shift(shift_right):
        return false

    for i, layer in piece.pairs():
        let board_idx = board_layer + PIECE_HEIGHT - i - 1
        if board_idx > board.len() - 1:
            continue

        let shifted = if shift_right:
            layer shr 1
        else:
            layer shl 1
        if (shifted and board[board_idx]) != 0:
            return false
    return true

proc shift(piece: Piece, shift_right: bool): Piece =
    for i, layer in piece.pairs():
        if shift_right:
            result[i] = layer shr 1
        else:
            result[i] = layer shl 1

proc can_drop(piece: Piece, board: Board, board_layer: int): bool =
    if board_layer == 0:
        return false

    for i, layer in piece.pairs():
        let board_idx = board_layer + PIECE_HEIGHT - i - 2
        if board_idx >= board.len():
            continue

        if (layer and board[board_idx]) != 0:
            return false
    return true

proc place(board: var Board, piece: Piece, board_layer: int) =
    for idx in 0..<PIECE_HEIGHT:
        let layer = piece[PIECE_HEIGHT - idx - 1]
        if idx + board_layer >= board.len():
            board.add(layer)
        else:
            board[idx + board_layer] = board[idx + board_layer] or layer

proc prune_empty(board: var Board) =
    while board.len() > 0:
        if board[^1] == 0:
            discard board.pop()
        else:
            return

proc insert_piece(board: var Board, cnt, idx: var int, input: string) =
    let piece_idx = cnt mod PIECES.len()
    var new_piece = PIECES[piece_idx]
    inc(cnt)
    var board_layer = board.len() + 3
    while true:
        let input_idx = idx mod input.len()
        let shift_right = input[input_idx] == '>'
        inc(idx)
        if new_piece.can_shift(board, board_layer, shift_right):
            new_piece = new_piece.shift(shift_right)

        if not new_piece.can_drop(board, board_layer):
            board.place(new_piece, board_layer)
            board.prune_empty()
            break
        else:
            dec(board_layer)

proc day17p1*(input: string): string =
    var
        cnt, idx = 0
        board: Board
    while cnt < NUM_PIECES_P1:
        board.insert_piece(cnt, idx, input)
    return $board.len()

proc day17p2*(input: string): string =
    var
        cnt, idx = 0
        board: Board
        cycle_track: seq[CyclePair]
        start_cycle, end_cycle: CyclePair
    # Code reusability? Never heard of it.
    block init:
        while true:
            let piece_idx = cnt mod PIECES.len()
            var new_piece = PIECES[piece_idx]
            inc(cnt)
            var board_layer = board.len() + 3
            while true:
                let input_idx = idx mod input.len()
                let shift_right = input[input_idx] == '>'
                inc(idx)
                if new_piece.can_shift(board, board_layer, shift_right):
                    new_piece = new_piece.shift(shift_right)

                if not new_piece.can_drop(board, board_layer):
                    board.place(new_piece, board_layer)
                    board.prune_empty()
                    # Check for cycle: can only have if we're on the same instruction, and the same piece as earlier
                    let newest_track = (cnt - 1, idx - 1, board_layer)
                    for item in cycle_track:
                        if piece_idx == item.cnt mod PIECES.len() and input_idx == item.idx mod input.len():
                            let height = min(CYCLE_HEIGHT, item.layer)
                            let bottom = board[(item.layer - height)..item.layer]
                            let top = board[(board_layer - height)..board_layer]
                            if top == bottom:
                                start_cycle = item
                                end_cycle = newest_track
                                break init
                    cycle_track.add(newest_track)
                    break
                else:
                    dec(board_layer)

    let cycle_len = end_cycle.cnt - start_cycle.cnt
    let cycle_height = end_cycle.layer - start_cycle.layer
    let num_cycles = (NUM_PIECES_P2 - start_cycle.cnt) div cycle_len
    let still_left = (NUM_PIECES_P2 - start_cycle.cnt) mod cycle_len
    let repeated_height = num_cycles * cycle_height + start_cycle.layer
    # Need to simluate `still_left` more pieces
    let start_height = end_cycle.layer
    for _ in countup(1, int(still_left)):
        board.insert_piece(cnt, idx, input)

    # If I'm being 100% honest, idk why I need to subtract 1 here
    return $(repeated_height + board.len() - start_height - 1)

