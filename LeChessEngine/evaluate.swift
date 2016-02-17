//
//  evaluate.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 11/02/2016.
//  Copyright © 2016 JasperVine. All rights reserved.
//

import Foundation

let PawnTable = [
    0	,	0	,	0	,	0	,	0	,	0	,	0	,	0	,
    10	,	10	,	0	,	-10	,	-10	,	0	,	10	,	10	,
    5	,	0	,	0	,	5	,	5	,	0	,	0	,	5	,
    0	,	0	,	10	,	20	,	20	,	10	,	0	,	0	,
    5	,	5	,	5	,	10	,	10	,	5	,	5	,	5	,
    10	,	10	,	10	,	20	,	20	,	10	,	10	,	10	,
    20	,	20	,	20	,	30	,	30	,	20	,	20	,	20	,
    0	,	0	,	0	,	0	,	0	,	0	,	0	,	0
]

let KnightTable = [
    0	,	-10	,	0	,	0	,	0	,	0	,	-10	,	0	,
    0	,	0	,	0	,	5	,	5	,	0	,	0	,	0	,
    0	,	0	,	10	,	10	,	10	,	10	,	0	,	0	,
    0	,	0	,	10	,	20	,	20	,	10	,	5	,	0	,
    5	,	10	,	15	,	20	,	20	,	15	,	10	,	5	,
    5	,	10	,	10	,	20	,	20	,	10	,	10	,	5	,
    0	,	0	,	5	,	10	,	10	,	5	,	0	,	0	,
    0	,	0	,	0	,	0	,	0	,	0	,	0	,	0
]

let BishopTable = [
    0	,	0	,	-10	,	0	,	0	,	-10	,	0	,	0	,
    0	,	0	,	0	,	10	,	10	,	0	,	0	,	0	,
    0	,	0	,	10	,	15	,	15	,	10	,	0	,	0	,
    0	,	10	,	15	,	20	,	20	,	15	,	10	,	0	,
    0	,	10	,	15	,	20	,	20	,	15	,	10	,	0	,
    0	,	0	,	10	,	15	,	15	,	10	,	0	,	0	,
    0	,	0	,	0	,	10	,	10	,	0	,	0	,	0	,
    0	,	0	,	0	,	0	,	0	,	0	,	0	,	0
]

let RookTable = [
    0	,	0	,	5	,	10	,	10	,	5	,	0	,	0	,
    0	,	0	,	5	,	10	,	10	,	5	,	0	,	0	,
    0	,	0	,	5	,	10	,	10	,	5	,	0	,	0	,
    0	,	0	,	5	,	10	,	10	,	5	,	0	,	0	,
    0	,	0	,	5	,	10	,	10	,	5	,	0	,	0	,
    0	,	0	,	5	,	10	,	10	,	5	,	0	,	0	,
    25	,	25	,	25	,	25	,	25	,	25	,	25	,	25	,
    0	,	0	,	5	,	10	,	10	,	5	,	0	,	0
]

let Mirror64 = [
    56	,	57	,	58	,	59	,	60	,	61	,	62	,	63	,
    48	,	49	,	50	,	51	,	52	,	53	,	54	,	55	,
    40	,	41	,	42	,	43	,	44	,	45	,	46	,	47	,
    32	,	33	,	34	,	35	,	36	,	37	,	38	,	39	,
    24	,	25	,	26	,	27	,	28	,	29	,	30	,	31	,
    16	,	17	,	18	,	19	,	20	,	21	,	22	,	23	,
    8	,	9	,	10	,	11	,	12	,	13	,	14	,	15	,
    0	,	1	,	2	,	3	,	4	,	5	,	6	,	7
]

enum PieceValue:Int {
    case Pawn   = 100
    case Rook   = 550
    case Knight = 325
    case Bishop = 326
    case Queen  = 1000
    case King   = 50000
    case None   = 0
}

func Evaluate(board:Board) -> Int {
    
    // Material evaluation
    let Whitepawns = countBits(board.White.Pawns);
    let Whiteknights = countBits(board.White.Knights);
    let Whitebishops = countBits(board.White.Bishops);
    let Whiterooks = countBits(board.White.Rooks);
    let Whitequeens = countBits(board.White.Queens);
    let whiteMaterialScore = PieceValue.Pawn.rawValue * Whitepawns + PieceValue.Knight.rawValue * Whiteknights + PieceValue.Bishop.rawValue * Whitebishops + PieceValue.Rook.rawValue * Whiterooks + PieceValue.Queen.rawValue * Whitequeens
    
    
    let blackPawns = countBits(board.Black.Pawns)
    let blackKnights = countBits(board.Black.Knights)
    let blackBishops = countBits(board.Black.Bishops);
    let blackRooks = countBits(board.Black.Rooks);
    let blackQueens = countBits(board.Black.Queens);
    let blackMaterialScore = PieceValue.Pawn.rawValue * blackPawns + PieceValue.Knight.rawValue * blackKnights + PieceValue.Bishop.rawValue * blackBishops + PieceValue.Rook.rawValue * blackRooks + PieceValue.Queen.rawValue * blackQueens;
    
    var score = whiteMaterialScore - blackMaterialScore
    
    for i in 0...63 {
        let piece = board[i]
        switch piece {
        case .WhitePawn:
            score += PawnTable[i]
        case .WhiteRook:
            score += RookTable[i]
        case .WhiteKnight:
            score += KnightTable[i]
        case .WhiteBishop:
            score += BishopTable[i]
            
        case .BlackPawn:
            score += PawnTable[Mirror64[i]]
        case .BlackRook:
            score += RookTable[Mirror64[i]]
        case .BlackKnight:
            score += KnightTable[Mirror64[i]]
        case .BlackBishop:
            score += BishopTable[Mirror64[i]]
        default:
            score += 0
        }
    }
    
    
    return score
}
