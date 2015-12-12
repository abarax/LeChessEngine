//
//  moves.Queen
//  LeChessEngine
//
//  Created by Leigh Appel on 5/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

struct Move {
    var from:Square = Square.None
    var to:Square = Square.None
    var promotion:Piece = Piece.None
    
    init (from:Square, to:Square) {
        self.from = from
        self.to = to
    }
    
    init (from:Square, to:Square, promotion:Piece) {
        self.from = from
        self.to = to
        self.promotion = promotion
    }
}

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

//Knight SKnight on E5
let KNIGHT_SPAN:BitBoard = 0b0000000000101000010001000000000001000100001010000000000000000000

//King SKnight on E5
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

func msb(var board:BitBoard) -> Int {
    var r = 0; // r will be lg(v)
    
    while (board != 0)
    {
        board >>= 1
        r++
    }
    return r
}

func setBit(let index:Int) -> BitBoard {
    return 1 << UInt64(index)
}

func popBit(board:BitBoard) -> (Int, BitBoard) {
    let bitIndex:Int = msb(board)
    let bit:BitBoard = setBit(bitIndex-1)
    let newBoard:BitBoard = (board & ~bit)
    return (bitIndex-1, newBoard)
}

func generateMoves(color:Color, position:Board) {
    generatePawnMoves(color, position: position)
    generateRookMoves(color, position: position)
    generateKnightMoves(color, position: position)
    generateBishopMoves(color, position: position)
    generateQueenMoves(color, position: position)
    generateKingMoves(color, position: position)
}

func generatePawnMoves(color:Color, position:Board) -> [Move] {
    var pawnMoves:[Move] = []
    var index:Int
    
    switch(color) {
    case .White :
        
        //Move forward one square
        var moveOneForward:BitBoard = ((position.White.Pawns << 8) & position.OpenSquares) & ~RANK_8
        while moveOneForward != 0 {
            (index, moveOneForward) = popBit(moveOneForward)
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!))
        }
        
        //Move forward two squares
        var moveTwoForward:BitBoard = ((((position.White.Pawns << 8) & position.OpenSquares) << 8) & position.OpenSquares) & RANK_4
        while moveTwoForward != 0 {
            (index, moveTwoForward) = popBit(moveTwoForward)
            pawnMoves.append(Move(from: Square(rawValue: index - 16)!, to: Square(rawValue: index)!))
        }
        
        //Capture right
        var captureRight:BitBoard = (((position.White.Pawns << 7) & position.AllBlackPieces) & ~RANK_8) & ~FILE_A
        while captureRight != 0 {
            (index, captureRight) = popBit(captureRight)
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!))
        }
        
        //Capture left
        var captureLeft:BitBoard = (((position.White.Pawns << 9) & position.AllBlackPieces) & ~RANK_8) & ~FILE_H
        while captureLeft != 0 {
            (index, captureLeft) = popBit(captureLeft)
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!))
        }
        
        //Enpassant
        if position.EnPassantSquare != Square.None {
            let enPassantBitBoard:BitBoard = setBit(position.EnPassantSquare.rawValue)
            
            //Left
            let enPassantLeft:BitBoard = (position.White.Pawns << 9) & enPassantBitBoard
            (index, _) = popBit(enPassantLeft)
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!))
            
            //Right
            let enPassantRight:BitBoard = (position.White.Pawns << 7) & enPassantBitBoard
            (index, _) = popBit(enPassantRight)
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!))
        }
        
        //Promotion
        
        var promoteOneForward:BitBoard = ((position.White.Pawns << 8) & position.OpenSquares) & RANK_8
        while promoteOneForward != 0 {
            (index, promoteOneForward) = popBit(promoteOneForward)
            
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen))
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop))
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight))
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook))
        }
        
        var promoteCaptureRight:BitBoard = (((position.White.Pawns << 7) & position.AllBlackPieces) & RANK_8) & ~FILE_A
        while promoteCaptureRight != 0 {
            (index, promoteCaptureRight) = popBit(promoteCaptureRight)
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen))
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop))
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight))
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook))
        }
        
        var promoteCaptureLeft:BitBoard = (((position.White.Pawns << 9) & position.AllBlackPieces) & RANK_8) & ~FILE_H
        while promoteCaptureLeft != 0 {
            (index, promoteCaptureLeft) = popBit(promoteCaptureLeft)
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen))
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop))
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight))
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook))
        }
        
    case .Black:
        //Move forward one square
        var moveOneForward:BitBoard = ((position.Black.Pawns >> 8) & position.OpenSquares) & ~RANK_1
        while moveOneForward != 0 {
            (index, moveOneForward) = popBit(moveOneForward)
            pawnMoves.append(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!))
        }
        
        //Move forward two squares
        var moveTwoForward:BitBoard = ((((position.Black.Pawns >> 8) & position.OpenSquares) >> 8) & position.OpenSquares) & RANK_5
        while moveTwoForward != 0 {
            (index, moveTwoForward) = popBit(moveTwoForward)
            pawnMoves.append(Move(from: Square(rawValue: index + 16)!, to: Square(rawValue: index)!))
        }
        
        //Capture right
        var captureRight:BitBoard = (((position.Black.Pawns >> 7) & position.AllWhitePieces) & ~RANK_1) & ~FILE_H
        while captureRight != 0 {
            (index, captureRight) = popBit(captureRight)
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!))
        }
        
        //Capture left
        var captureLeft:BitBoard = (((position.Black.Pawns >> 9) & position.AllWhitePieces) & ~RANK_1) & ~FILE_A
        while captureLeft != 0 {
            (index, captureLeft) = popBit(captureLeft)
            pawnMoves.append(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!))
        }
        
        //Enpassant
        if position.EnPassantSquare != Square.None {
            let enPassantBitBoard:BitBoard = setBit(position.EnPassantSquare.rawValue)
            
            //Left
            let enPassantLeft:BitBoard = (position.Black.Pawns >> 9) & enPassantBitBoard
            (index, _) = popBit(enPassantLeft)
            pawnMoves.append(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!))
            
            //Right
            let enPassantRight:BitBoard = (position.Black.Pawns >> 7) & enPassantBitBoard
            (index, _) = popBit(enPassantRight)
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!))
        }
        
        //Promotion
        
        var promoteOneForward:BitBoard = ((position.Black.Pawns >> 8) & position.OpenSquares) & RANK_1
        while promoteOneForward != 0 {
            (index, promoteOneForward) = popBit(promoteOneForward)
            
            pawnMoves.append(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteQueen))
            pawnMoves.append(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteBishop))
            pawnMoves.append(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteKnight))
            pawnMoves.append(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteRook))
        }
        
        var promoteCaptureRight:BitBoard = (((position.Black.Pawns >> 7) & position.AllWhitePieces) & RANK_1) & ~FILE_H
        while promoteCaptureRight != 0 {
            (index, promoteCaptureRight) = popBit(promoteCaptureRight)
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteQueen))
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteBishop))
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteKnight))
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteRook))
        }
        
        var promoteCaptureLeft:BitBoard = (((position.Black.Pawns >> 9) & position.AllWhitePieces) & RANK_1) & ~FILE_A
        while promoteCaptureLeft != 0 {
            (index, promoteCaptureLeft) = popBit(promoteCaptureLeft)
            pawnMoves.append(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!, promotion: Piece.WhiteQueen))
            pawnMoves.append(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!, promotion: Piece.WhiteBishop))
            pawnMoves.append(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!, promotion: Piece.WhiteKnight))
            pawnMoves.append(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!, promotion: Piece.WhiteRook))
        }
        
    }
    
    return pawnMoves
}

func generateSlidingHorizontalAndVertical(square:Square, position:Board) -> BitBoard{
    let piece:BitBoard = setBit(square.rawValue)
    let fileMask:BitBoard = FILES[square.rawValue % 8]
    let rankMask:BitBoard = RANKS[square.rawValue / 8]
    let occupied:BitBoard = position.OccupiedSquares
    
    let horizontal = ((occupied ^ (occupied &- 2 &* piece)) ^ reverse(reverse(occupied) ^ (reverse(occupied) &- 2 &* reverse(piece)))) & rankMask
    let vertical =  (((occupied & fileMask) &- (2 &* piece)) ^ reverse(reverse(occupied & fileMask) &- (2 &* reverse(piece)))) & fileMask

    return horizontal | vertical
}

func generateSlidingDiagonals(square:Square, position:Board) -> BitBoard{
    let piece:BitBoard = setBit(square.rawValue)
    let occupied:BitBoard = position.OccupiedSquares
    let diagMask = DiagonalMasks[(square.rawValue / 8) + (square.rawValue % 8)]
    let antiDiagMask = AntiDiagonalMasks[(square.rawValue / 8) + 7 - (square.rawValue % 8)]
    
    let diagonal = ((occupied & diagMask) &- (2 &* piece)) ^ reverse(reverse(occupied & diagMask) &- (2 &* reverse(piece)));
    let antiDiagonal = ((occupied & antiDiagMask) &- (2 * piece)) ^ reverse(reverse(occupied & antiDiagMask) &- (2 &* reverse(piece)));
    
    return (diagonal & diagMask) | (antiDiagonal & antiDiagMask);
}


func generateRookMoves(color:Color, position:Board) -> [Move] {
    var rookMoves:[Move] = []
    
    var rookIndex:Int
    var rookMoveIndex:Int
    var rookBoard:BitBoard
    
    switch(color) {
    case .White:
        rookBoard = position.White.Rooks
    case .Black:
        rookBoard = position.Black.Rooks
    }
    var nextRook:BitBoard = rookBoard
    while nextRook != 0 {
        (rookIndex, nextRook) = popBit(nextRook)
        var potentialRookMoves:BitBoard = generateSlidingHorizontalAndVertical(Square(rawValue: rookIndex)!, position: position)
            
        while potentialRookMoves != 0 {
            (rookMoveIndex, potentialRookMoves) = popBit(potentialRookMoves)
            rookMoves.append(Move(from: Square(rawValue: rookIndex)!, to: Square(rawValue: rookMoveIndex)!))
        }
    }

    return rookMoves
}

func generateBishopMoves(color:Color, position:Board) -> [Move] {
    var bishopMoves:[Move] = []
    var bishopIndex:Int
    var bishopMoveIndex:Int
    var bishopBoard:BitBoard
        
    switch(color) {
    case .White:
        bishopBoard = position.White.Bishops
    case .Black:
        bishopBoard = position.Black.Bishops
    }
    var nextBishop:BitBoard = bishopBoard
    while nextBishop != 0 {
        (bishopIndex, nextBishop) = popBit(nextBishop)
        var potentialBishopMoves:BitBoard = generateSlidingDiagonals(Square(rawValue: bishopIndex)!, position: position)
            
        while potentialBishopMoves != 0 {
            (bishopMoveIndex, potentialBishopMoves) = popBit(potentialBishopMoves)
            bishopMoves.append(Move(from: Square(rawValue: bishopIndex)!, to: Square(rawValue: bishopMoveIndex)!))
        }
    }
    return bishopMoves
}

func generateQueenMoves(color:Color, position:Board) -> [Move] {
    var queenMoves:[Move] = []
    var queenIndex:Int
    var queenMoveIndex:Int
    var queenBoard:BitBoard
    
    switch(color) {
    case .White:
        queenBoard = position.White.Queens
    case .Black:
        queenBoard = position.Black.Queens
    }
    var nextQueen:BitBoard = queenBoard
    while nextQueen != 0 {
        (queenIndex, nextQueen) = popBit(nextQueen)
        var potentialQueenMoves:BitBoard = generateSlidingHorizontalAndVertical(Square(rawValue: queenIndex)!, position: position)
        
        while potentialQueenMoves != 0 {
            (queenMoveIndex, potentialQueenMoves) = popBit(potentialQueenMoves)
            queenMoves.append(Move(from: Square(rawValue: queenIndex)!, to: Square(rawValue: queenMoveIndex)!))
        }
        
        potentialQueenMoves = generateSlidingDiagonals(Square(rawValue: queenIndex)!, position: position)
        
        while potentialQueenMoves != 0 {
            (queenMoveIndex, potentialQueenMoves) = popBit(potentialQueenMoves)
            queenMoves.append(Move(from: Square(rawValue: queenIndex)!, to: Square(rawValue: queenMoveIndex)!))
        }
    }
    return queenMoves
}

func generateKnightMoves(color:Color, position:Board) -> [Move] {
    var knightMoves:[Move] = []
    var knightIndex:Int
    var knightMoveIndex:Int
    var knightBoard:BitBoard
    var friendlyBoard:BitBoard
    var enemyKing:BitBoard
    
    switch(color) {
    case .White:
        knightBoard = position.White.Knights
        friendlyBoard = position.AllWhitePieces
        enemyKing = position.Black.King
    case .Black:
        knightBoard = position.Black.Knights
        friendlyBoard = position.AllBlackPieces
        enemyKing = position.White.King
    }
    
    var nextKnight:BitBoard = knightBoard
    while nextKnight != 0 {
        (knightIndex, nextKnight) = popBit(nextKnight)
        var potentialKnightMoves:BitBoard
        var mask:BitBoard
        
        //Calculate our mask to filter out illegal moves when we shift the Knight Span
        switch(knightIndex % 8) {
            case 1...2: mask = ~(FILE_G | FILE_H)
            case 7...8: mask = ~(FILE_A | FILE_B)
            default: mask = ALL_MASK
        }
        
        //Move the Knight Spawn to the correct square
        if knightIndex > Square.E5.rawValue {
            potentialKnightMoves = KNIGHT_SPAN << BitBoard(knightIndex - Square.E5.rawValue)
        } else {
            potentialKnightMoves = KNIGHT_SPAN >> BitBoard(Square.E5.rawValue - knightIndex)
        }
        
        potentialKnightMoves = potentialKnightMoves & mask & ~friendlyBoard & ~enemyKing
        
        while potentialKnightMoves != 0 {
            (knightMoveIndex, potentialKnightMoves) = popBit(potentialKnightMoves)
            knightMoves.append(Move(from: Square(rawValue: knightIndex)!, to: Square(rawValue: knightMoveIndex)!))
        }
    }
    return knightMoves
}

func generateKingMoves(color:Color, position:Board) -> [Move] {
    var kingMoves:[Move] = []
    var kingIndex:Int
    var kingMoveIndex:Int
    var kingBoard:BitBoard
    var friendlyBoard:BitBoard
    var enemyKing:BitBoard
    
    switch(color) {
    case .White:
        kingBoard = position.White.King
        friendlyBoard = position.AllWhitePieces
        enemyKing = position.Black.King
    case .Black:
        kingBoard = position.Black.King
        friendlyBoard = position.AllBlackPieces
        enemyKing = position.White.King
    }
    
    var nextKing:BitBoard = kingBoard
    (kingIndex, nextKing) = popBit(nextKing)
    var potentialKingMoves:BitBoard
    var mask:BitBoard
        
    //Calculate our mask to filter out illegal moves when we shift the King Span
    switch(kingIndex % 8) {
        case 1: mask = ~FILE_H
        case 8: mask = ~FILE_A
        default: mask = ALL_MASK
    }
        
    //Move the King Span to the correct square
    if kingIndex > Square.E5.rawValue {
        potentialKingMoves = KING_SPAN << BitBoard(kingIndex - Square.E5.rawValue)
    } else {
        potentialKingMoves = KING_SPAN >> BitBoard(Square.E5.rawValue - kingIndex)
    }
        
    potentialKingMoves = potentialKingMoves & mask & ~friendlyBoard & ~enemyKing
        
    while potentialKingMoves != 0 {
        (kingMoveIndex, potentialKingMoves) = popBit(potentialKingMoves)
        kingMoves.append(Move(from: Square(rawValue: kingIndex)!, to: Square(rawValue: kingMoveIndex)!))
    }
    return kingMoves

}