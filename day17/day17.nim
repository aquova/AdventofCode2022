const NUM_PIECES = 2022
const PIECE_HEIGHT = 4

type Board = seq[uint8]
type Piece = array[PIECE_HEIGHT, uint8]

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
    if not piece.can_shift(shift_right):
        return piece
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

proc day17p1*(input: string): string =
    var
        cnt, idx = 0
        board: Board
    while cnt < NUM_PIECES:
        var new_piece = PIECES[cnt mod PIECES.len()]
        inc(cnt)
        var board_layer = board.len() + 3
        while true:
            let shift_right = input[idx] == '>'
            idx = (idx + 1) mod input.len()
            if new_piece.can_shift(board, board_layer, shift_right):
                new_piece = new_piece.shift(shift_right)

            if not new_piece.can_drop(board, board_layer):
                board.place(new_piece, board_layer)
                board.prune_empty()
                break
            else:
                dec(board_layer)
    return $board.len()

proc day17p2*(input: string): string =
    discard
