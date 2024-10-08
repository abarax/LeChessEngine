//
//  constants.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 13/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

let INFINITY = Int.max
let CHECKMATE = 100000

let RANK_1:BitBoard = 0x00000000000000ff
let RANK_2:BitBoard = 0x000000000000ff00
let RANK_3:BitBoard = 0x0000000000ff0000
let RANK_4:BitBoard = 0x00000000ff000000
let RANK_5:BitBoard = 0x000000ff00000000
let RANK_6:BitBoard = 0x0000ff0000000000
let RANK_7:BitBoard = 0x00ff000000000000
let RANK_8:BitBoard = 0xff00000000000000

let FILE_A:BitBoard = 0x0101010101010101
let FILE_B:BitBoard = 0x0202020202020202
let FILE_C:BitBoard = 0x0404040404040404
let FILE_D:BitBoard = 0x0808080808080808
let FILE_E:BitBoard = 0x1010101010101010
let FILE_F:BitBoard = 0x2020202020202020
let FILE_G:BitBoard = 0x4040404040404040
let FILE_H:BitBoard = 0x8080808080808080

let ALL_MASK = FILE_A | FILE_B | FILE_C | FILE_D | FILE_E | FILE_F | FILE_G | FILE_H

let FILES = [FILE_A, FILE_B, FILE_C, FILE_D, FILE_E, FILE_F, FILE_G, FILE_H]
let RANKS = [RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8]

let WHITE_QUEEN_CASTLE_MASK:BitBoard = 0b1100
let WHITE_KING_CASTLE_MASK:BitBoard  = 0b1100000
let WHITE_QUEEN_BLOCKING_CASTLE_MASK:BitBoard = 0b1110
let WHITE_KING_BLOCKING_CASTLE_MASK:BitBoard  = 0b1100000

let BLACK_QUEEN_CASTLE_MASK:BitBoard = 0xC00000000000000
let BLACK_KING_CASTLE_MASK :BitBoard = 0x6000000000000000
let BLACK_QUEEN_BLOCKING_CASTLE_MASK:BitBoard = 0xE00000000000000
let BLACK_KING_BLOCKING_CASTLE_MASK :BitBoard = 0x6000000000000000

//Knight Span on E5
let KNIGHT_SPAN:BitBoard = 0b0000000000101000010001000000000001000100001010000000000000000000

//King Span on E5
let KING_SPAN:BitBoard = 0b0000000000000000001110000010100000111000000000000000000000000000

// From top left to bottom right
let DiagonalMasks:[BitBoard] = [
    0x1, 0x102, 0x10204, 0x1020408, 0x102040810, 0x10204081020, 0x1020408102040,
    0x102040810204080, 0x204081020408000, 0x408102040800000, 0x810204080000000,
    0x1020408000000000, 0x2040800000000000, 0x4080000000000000, 0x8000000000000000
]

// From top right to bottom left
let AntiDiagonalMasks:[BitBoard] = [
    0x80, 0x8040, 0x804020, 0x80402010, 0x8040201008, 0x804020100804, 0x80402010080402,
    0x8040201008040201, 0x4020100804020100, 0x2010080402010000, 0x1008040201000000,
    0x804020100000000, 0x402010000000000, 0x201000000000000, 0x100000000000000
]

//PERFT Representation of a new game
let NewGame = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"


var CAPTURE_SCORE: [Piece:[Piece:Int]] = [:]
let PIECE_CAPTURE_SCORES:[Piece:Int] = [
    .WhitePawn:     100,
    .WhiteKnight:   200,
    .WhiteBishop:   300,
    .WhiteRook:     400,
    .WhiteQueen:    500,
    .WhiteKing:     600,
    .BlackPawn:     100,
    .BlackKnight:   200,
    .BlackBishop:   300,
    .BlackRook:     400,
    .BlackQueen:    500,
    .BlackKing:     600
]

//PIECE_CAPTURE_SCORES[victim]! + 6 - (PIECE_CAPTURE_SCORES[attacker]! / 100)

func initCaptureScores() {
    for attacker in Piece.allValues {
        for victim in Piece.allValues {
            if CAPTURE_SCORE[victim] != nil {
               CAPTURE_SCORE[victim]![attacker] = PIECE_CAPTURE_SCORES[victim]! + 6 - (PIECE_CAPTURE_SCORES[attacker]! / 100)
            } else {
                CAPTURE_SCORE[victim] = [ attacker: PIECE_CAPTURE_SCORES[victim]! + 6 - (PIECE_CAPTURE_SCORES[attacker]! / 100)]
            }
        }
    }
    print(PIECE_CAPTURE_SCORES)
}
