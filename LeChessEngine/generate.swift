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

func popBit(inout board:BitBoard) -> Int {
    let bitIndex:Int = msb(board)
    let bit:BitBoard = setBit(bitIndex-1)
    board = (board & ~bit)
    return bitIndex-1
}

func generateMoves(color:Color, position:Board) {
    generatePawnMoves(color, position: position)
    generateRookMoves(color, position: position)
    generateKnightMoves(color: color, position: position)
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
            index = popBit(&moveOneForward)
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!))
        }
        
        //Move forward two squares
        var moveTwoForward:BitBoard = ((((position.White.Pawns << 8) & position.OpenSquares) << 8) & position.OpenSquares) & RANK_4
        while moveTwoForward != 0 {
            index = popBit(&moveTwoForward)
            pawnMoves.append(Move(from: Square(rawValue: index - 16)!, to: Square(rawValue: index)!))
        }
        
        //Capture right
        var captureRight:BitBoard = (((position.White.Pawns << 7) & position.AllBlackPieces) & ~RANK_8) & ~FILE_A
        while captureRight != 0 {
            index = popBit(&captureRight)
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!))
        }
        
        //Capture left
        var captureLeft:BitBoard = (((position.White.Pawns << 9) & position.AllBlackPieces) & ~RANK_8) & ~FILE_H
        while captureLeft != 0 {
            index = popBit(&captureLeft)
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!))
        }
        
        //Enpassant
        if position.EnPassantSquare != Square.None {
            let enPassantBitBoard:BitBoard = setBit(position.EnPassantSquare.rawValue)
            
            //Left
            var enPassantLeft:BitBoard = (position.White.Pawns << 9) & enPassantBitBoard
            index = popBit(&enPassantLeft)
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!))
            
            //Right
            var enPassantRight:BitBoard = (position.White.Pawns << 7) & enPassantBitBoard
            index = popBit(&enPassantRight)
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!))
        }
        
        //Promotion
        
        var promoteOneForward:BitBoard = ((position.White.Pawns << 8) & position.OpenSquares) & RANK_8
        while promoteOneForward != 0 {
            index = popBit(&promoteOneForward)
            
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen))
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop))
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight))
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook))
        }
        
        var promoteCaptureRight:BitBoard = (((position.White.Pawns << 7) & position.AllBlackPieces) & RANK_8) & ~FILE_A
        while promoteCaptureRight != 0 {
            index = popBit(&promoteCaptureRight)
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen))
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop))
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight))
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook))
        }
        
        var promoteCaptureLeft:BitBoard = (((position.White.Pawns << 9) & position.AllBlackPieces) & RANK_8) & ~FILE_H
        while promoteCaptureLeft != 0 {
            index = popBit(&promoteCaptureLeft)
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen))
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop))
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight))
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook))
        }
        
    case .Black:
        //Move forward one square
        var moveOneForward:BitBoard = ((position.Black.Pawns >> 8) & position.OpenSquares) & ~RANK_1
        while moveOneForward != 0 {
            index = popBit(&moveOneForward)
            pawnMoves.append(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!))
        }
        
        //Move forward two squares
        var moveTwoForward:BitBoard = ((((position.Black.Pawns >> 8) & position.OpenSquares) >> 8) & position.OpenSquares) & RANK_5
        while moveTwoForward != 0 {
            index = popBit(&moveTwoForward)
            pawnMoves.append(Move(from: Square(rawValue: index + 16)!, to: Square(rawValue: index)!))
        }
        
        //Capture right
        var captureRight:BitBoard = (((position.Black.Pawns >> 7) & position.AllWhitePieces) & ~RANK_1) & ~FILE_H
        while captureRight != 0 {
            index = popBit(&captureRight)
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!))
        }
        
        //Capture left
        var captureLeft:BitBoard = (((position.Black.Pawns >> 9) & position.AllWhitePieces) & ~RANK_1) & ~FILE_A
        while captureLeft != 0 {
            index = popBit(&captureLeft)
            pawnMoves.append(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!))
        }
        
        //Enpassant
        if position.EnPassantSquare != Square.None {
            let enPassantBitBoard:BitBoard = setBit(position.EnPassantSquare.rawValue)
            
            //Left
            var enPassantLeft:BitBoard = (position.Black.Pawns >> 9) & enPassantBitBoard
            index = popBit(&enPassantLeft)
            pawnMoves.append(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!))
            
            //Right
            var enPassantRight:BitBoard = (position.Black.Pawns >> 7) & enPassantBitBoard
            index = popBit(&enPassantRight)
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!))
        }
        
        //Promotion
        
        var promoteOneForward:BitBoard = ((position.Black.Pawns >> 8) & position.OpenSquares) & RANK_1
        while promoteOneForward != 0 {
            index = popBit(&promoteOneForward)
            
            pawnMoves.append(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteQueen))
            pawnMoves.append(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteBishop))
            pawnMoves.append(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteKnight))
            pawnMoves.append(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteRook))
        }
        
        var promoteCaptureRight:BitBoard = (((position.Black.Pawns >> 7) & position.AllWhitePieces) & RANK_1) & ~FILE_H
        while promoteCaptureRight != 0 {
            index = popBit(&promoteCaptureRight)
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteQueen))
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteBishop))
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteKnight))
            pawnMoves.append(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteRook))
        }
        
        var promoteCaptureLeft:BitBoard = (((position.Black.Pawns >> 9) & position.AllWhitePieces) & RANK_1) & ~FILE_A
        while promoteCaptureLeft != 0 {
            index = popBit(&promoteCaptureLeft)
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
        rookIndex = popBit(&nextRook)
        var potentialRookMoves:BitBoard = generateSlidingHorizontalAndVertical(Square(rawValue: rookIndex)!, position: position)
            
        while potentialRookMoves != 0 {
            rookMoveIndex = popBit(&potentialRookMoves)
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
        bishopIndex = popBit(&nextBishop)
        var potentialBishopMoves:BitBoard = generateSlidingDiagonals(Square(rawValue: bishopIndex)!, position: position)
            
        while potentialBishopMoves != 0 {
            bishopMoveIndex = popBit(&potentialBishopMoves)
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
        queenIndex = popBit(&nextQueen)
        var potentialQueenMoves:BitBoard = generateSlidingHorizontalAndVertical(Square(rawValue: queenIndex)!, position: position)
        
        while potentialQueenMoves != 0 {
            queenMoveIndex = popBit(&potentialQueenMoves)
            queenMoves.append(Move(from: Square(rawValue: queenIndex)!, to: Square(rawValue: queenMoveIndex)!))
        }
        
        potentialQueenMoves = generateSlidingDiagonals(Square(rawValue: queenIndex)!, position: position)
        
        while potentialQueenMoves != 0 {
            queenMoveIndex = popBit(&potentialQueenMoves)
            queenMoves.append(Move(from: Square(rawValue: queenIndex)!, to: Square(rawValue: queenMoveIndex)!))
        }
    }
    return queenMoves
}

func generateKnightMoves(color color:Color, position:Board) -> [Move] {
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
        knightIndex = popBit(&nextKnight)
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
            knightMoveIndex = popBit(&potentialKnightMoves)
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
    kingIndex = popBit(&nextKing)
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
        kingMoveIndex = popBit(&potentialKingMoves)
        kingMoves.append(Move(from: Square(rawValue: kingIndex)!, to: Square(rawValue: kingMoveIndex)!))
    }
    return kingMoves

}