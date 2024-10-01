//
//  moves.Queen
//  LeChessEngine
//
//  Created by Leigh Appel on 5/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

typealias Moves = SkipList<Move>


struct Move: Comparable {
    var from:Square = Square.None
    var to:Square = Square.None
    var promotion:Piece = Piece.None
    var score:Int = Int.min
    
    init() {
        
    }
    
    init (from:Square, to:Square) {
        self.from = from
        self.to = to
    }
    
    init (from:Square, to:Square, score:Int) {
        self.from = from
        self.to = to
        self.score = score
    }
    
    init (from:Square, to:Square, promotion:Piece) {
        self.from = from
        self.to = to
        self.promotion = promotion
    }
    
}

func <(lhs: Move, rhs: Move) -> Bool {
    return lhs.score < rhs.score
}

func <=(lhs: Move, rhs: Move) -> Bool {
    return lhs.score <= rhs.score
}

func >=(lhs: Move, rhs: Move) -> Bool {
    return lhs.score >= rhs.score
}

func >(lhs: Move, rhs: Move) -> Bool {
    return lhs.score > rhs.score
}

func ==(lhs: Move, rhs: Move) -> Bool {
    return lhs.from == rhs.from &&
        lhs.to == rhs.to &&
        lhs.promotion == rhs.promotion &&
        lhs.score == rhs.score
}


func msb(var board:BitBoard) -> Int {
    var r = 0
    
    while (board != 0)
    {
        board >>= 1
        r++
    }
    return r
}

func countBits (var board:BitBoard) -> Int
{
    var r = 0
    
    while (board != 0)
    {
        if board & 1 == 1 {
            r++
        }
        board >>= 1
        
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

func generateCaptureMoves(board:Board) -> [Move] {
    var moves:[Move] = []
    switch(board.Turn) {
    case .White: moves.appendContentsOf(generateMoves(.White, position: board, capturesOnly:true))
    case .Black: moves.appendContentsOf(generateMoves(.Black, position: board, capturesOnly:true))
    }
    
    return moves
}

func generateMoves(board:Board) -> [Move] {
    var moves:[Move] = []
    switch(board.Turn) {
        case .White: moves.appendContentsOf(generateMoves(.White, position: board))
        case .Black: moves.appendContentsOf(generateMoves(.Black, position: board))
    }
    
    return moves
}

func generateMoves(color:Color, position:Board, capturesOnly:Bool = false) -> [Move] {
    var moves:[Move] = []
    moves.appendContentsOf(generatePawnMoves(color, position: position, capturesOnly:capturesOnly))
    moves.appendContentsOf(generateRookMoves(color, position: position, capturesOnly:capturesOnly))
    moves.appendContentsOf(generateKnightMoves(color: color, position: position, capturesOnly:capturesOnly))
    moves.appendContentsOf(generateBishopMoves(color, position: position, capturesOnly:capturesOnly))
    moves.appendContentsOf(generateQueenMoves(color, position: position, capturesOnly:capturesOnly))
    moves.appendContentsOf(generateKingMoves(color, position: position, capturesOnly:capturesOnly))
    return moves
}

func generatePawnMoves(color:Color, position:Board, capturesOnly:Bool = false) -> [Move] {
    var pawnMoves:[Move] = []
    var index:Int
    
    switch(color) {
    case .White :
        
        if !capturesOnly {
        //Move forward one square
        var moveOneForward:BitBoard = ((position.White.Pawns << 8) & position.UnoccupiedSquares) & ~RANK_8
        while moveOneForward != 0 {
            index = popBit(&moveOneForward)
            addQuietMove(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
        }
        
        //Move forward two squares
        var moveTwoForward:BitBoard = ((((position.White.Pawns << 8) & position.UnoccupiedSquares) << 8) & position.UnoccupiedSquares) & RANK_4
        while moveTwoForward != 0 {
            index = popBit(&moveTwoForward)
            addQuietMove(Move(from: Square(rawValue: index - 16)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
        }
        }
        
        //Capture right
        var captureRight:BitBoard = (((position.White.Pawns << 9) & position.AllBlackPieces) & ~RANK_8) & ~FILE_A
        while captureRight != 0 {
            index = popBit(&captureRight)
            addCaptureMove(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
        }
        
        //Capture left
        var captureLeft:BitBoard = (((position.White.Pawns << 7) & position.AllBlackPieces) & ~RANK_8) & ~FILE_H
        while captureLeft != 0 {
            index = popBit(&captureLeft)
            addCaptureMove(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
        }
        
        //Enpassant
        if position.EnPassantSquare != Square.None {
            let enPassantBitBoard:BitBoard = setBit(position.EnPassantSquare.rawValue)
            
            //Left
            var enPassantLeft:BitBoard = ((position.White.Pawns << 9) & ~FILE_A) & enPassantBitBoard
            if enPassantLeft != 0 {
                index = popBit(&enPassantLeft)
                addCaptureMove(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
            }
            
            //Right
            var enPassantRight:BitBoard = ((position.White.Pawns << 7) & ~FILE_H) & enPassantBitBoard
            if enPassantRight != 0 {
                index = popBit(&enPassantRight)
                addCaptureMove(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
            }
        }
        
        if !capturesOnly {
        //Promotion
        
        var promoteOneForward:BitBoard = ((position.White.Pawns << 8) & position.UnoccupiedSquares) & RANK_8
        while promoteOneForward != 0 {
            index = popBit(&promoteOneForward)
            
            addQuietMove(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteQueen), moves: &pawnMoves, position: position)
            addQuietMove(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteBishop), moves: &pawnMoves, position: position)
            addQuietMove(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteKnight), moves: &pawnMoves, position: position)
            addQuietMove(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.WhiteRook), moves: &pawnMoves, position: position)
        }
        }
        
        var promoteCaptureLeft:BitBoard = (((position.White.Pawns << 7) & position.AllBlackPieces) & RANK_8) & ~FILE_H
        while promoteCaptureLeft != 0 {
            index = popBit(&promoteCaptureLeft)
            addCaptureMove(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.WhiteQueen), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.WhiteBishop), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.WhiteKnight), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.WhiteRook), moves: &pawnMoves, position: position)
        }
        
        var promoteCaptureRight:BitBoard = (((position.White.Pawns << 9) & position.AllBlackPieces) & RANK_8) & ~FILE_A
        while promoteCaptureRight != 0 {
            index = popBit(&promoteCaptureRight)
            addCaptureMove(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteQueen), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteBishop), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteKnight), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.WhiteRook), moves: &pawnMoves, position: position)
        }
        
    case .Black:
        
        if !capturesOnly {
        //Move forward one square
        var moveOneForward:BitBoard = ((position.Black.Pawns >> 8) & position.UnoccupiedSquares) & ~RANK_1
        while moveOneForward != 0 {
            index = popBit(&moveOneForward)
            addQuietMove(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
        }
        
        //Move forward two squares
        var moveTwoForward:BitBoard = ((((position.Black.Pawns >> 8) & position.UnoccupiedSquares) >> 8) & position.UnoccupiedSquares) & RANK_5
        while moveTwoForward != 0 {
            index = popBit(&moveTwoForward)
            addQuietMove(Move(from: Square(rawValue: index + 16)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
        }
        }
        //Capture right
        var captureRight:BitBoard = (((position.Black.Pawns >> 9) & position.AllWhitePieces) & ~RANK_1) & ~FILE_H
        while captureRight != 0 {
            index = popBit(&captureRight)
            addCaptureMove(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
        }
        
        //Capture left
        var captureLeft:BitBoard = (((position.Black.Pawns >> 7) & position.AllWhitePieces) & ~RANK_1) & ~FILE_A
        while captureLeft != 0 {
            index = popBit(&captureLeft)
            addCaptureMove(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
        }
        
        //Enpassant
        if position.EnPassantSquare != Square.None {
            let enPassantBitBoard:BitBoard = setBit(position.EnPassantSquare.rawValue)
            
            //Left
            var enPassantLeft:BitBoard = ((position.Black.Pawns >> 9) & ~FILE_H) & enPassantBitBoard
            if enPassantLeft != 0 {
                index = popBit(&enPassantLeft)
                addCaptureMove(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
            }
            
            //Right
            var enPassantRight:BitBoard = ((position.Black.Pawns >> 7) & ~FILE_A) & enPassantBitBoard
            if enPassantRight != 0 {
                index = popBit(&enPassantRight)
                addCaptureMove(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!), moves: &pawnMoves, position: position)
            }
        }
        if !capturesOnly {
        //Promotion
        
        var promoteOneForward:BitBoard = ((position.Black.Pawns >> 8) & position.UnoccupiedSquares) & RANK_1
        while promoteOneForward != 0 {
            index = popBit(&promoteOneForward)
            
            addQuietMove(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen), moves: &pawnMoves, position: position)
            addQuietMove(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop), moves: &pawnMoves, position: position)
            addQuietMove(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight), moves: &pawnMoves, position: position)
            addQuietMove(Move(from: Square(rawValue: index + 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook), moves: &pawnMoves, position: position)
        }
        }
        
        var promoteCaptureRight:BitBoard = (((position.Black.Pawns >> 7) & position.AllWhitePieces) & RANK_1) & ~FILE_A
        while promoteCaptureRight != 0 {
            index = popBit(&promoteCaptureRight)
            addCaptureMove(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index + 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook), moves: &pawnMoves, position: position)
        }
        
        var promoteCaptureLeft:BitBoard = (((position.Black.Pawns >> 9) & position.AllWhitePieces) & RANK_1) & ~FILE_H
        while promoteCaptureLeft != 0 {
            index = popBit(&promoteCaptureLeft)
            addCaptureMove(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight), moves: &pawnMoves, position: position)
            addCaptureMove(Move(from: Square(rawValue: index + 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook), moves: &pawnMoves, position: position)
        }
        
    }
    
    return pawnMoves
}

func generateRookMoves(color:Color, position:Board, capturesOnly:Bool = false) -> [Move] {
    var rookMoves:[Move] = []
    
    var rookIndex:Int
    var rookMoveIndex:Int
    var rookBoard:BitBoard
    var friendlyPieces:BitBoard
    
    switch(color) {
    case .White:
        rookBoard = position.White.Rooks
        friendlyPieces = position.AllWhitePieces
    case .Black:
        rookBoard = position.Black.Rooks
        friendlyPieces = position.AllBlackPieces
    }
    var nextRook:BitBoard = rookBoard
    while nextRook != 0 {
        rookIndex = popBit(&nextRook)
        var potentialRookMoves:BitBoard = generateSlidingHorizontalAndVertical(Square(rawValue: rookIndex)!, position: position) & ~friendlyPieces
            
        while potentialRookMoves != 0 {
            rookMoveIndex = popBit(&potentialRookMoves)
            let move = Move(from: Square(rawValue: rookIndex)!, to: Square(rawValue: rookMoveIndex)!)
            if position[rookMoveIndex] != .None {
                addCaptureMove(move, moves: &rookMoves, position: position)
            } else if !capturesOnly {
                addQuietMove(move, moves: &rookMoves, position: position)
            }
        }
    }

    return rookMoves
}

func generateBishopMoves(color:Color, position:Board, capturesOnly:Bool = false) -> [Move] {
    var bishopMoves:[Move] = []
    var bishopIndex:Int
    var bishopMoveIndex:Int
    var bishopBoard:BitBoard
    var friendlyPieces:BitBoard
        
    switch(color) {
    case .White:
        bishopBoard = position.White.Bishops
        friendlyPieces = position.AllWhitePieces
    case .Black:
        bishopBoard = position.Black.Bishops
        friendlyPieces = position.AllBlackPieces
    }
    var nextBishop:BitBoard = bishopBoard
    while nextBishop != 0 {
        bishopIndex = popBit(&nextBishop)
        var potentialBishopMoves:BitBoard = generateSlidingDiagonals(Square(rawValue: bishopIndex)!, position: position) & ~friendlyPieces
            
        while potentialBishopMoves != 0 {
            bishopMoveIndex = popBit(&potentialBishopMoves)
            let move = Move(from: Square(rawValue: bishopIndex)!, to: Square(rawValue: bishopMoveIndex)!)
            if position[bishopMoveIndex] != .None {
                addCaptureMove(move, moves: &bishopMoves, position: position)
            } else if !capturesOnly {
                addQuietMove(move, moves: &bishopMoves, position: position)
            }
            
        }
    }
    return bishopMoves
}

func generateQueenMoves(color:Color, position:Board, capturesOnly:Bool = false) -> [Move] {
    var queenMoves:[Move] = []
    var queenIndex:Int
    var queenMoveIndex:Int
    var queenBoard:BitBoard
    var friendlyPieces:BitBoard
    
    switch(color) {
    case .White:
        queenBoard = position.White.Queens
        friendlyPieces = position.AllWhitePieces
    case .Black:
        queenBoard = position.Black.Queens
        friendlyPieces = position.AllBlackPieces
    }
    var nextQueen:BitBoard = queenBoard
    while nextQueen != 0 {
        queenIndex = popBit(&nextQueen)
        var potentialQueenMoves:BitBoard = generateSlidingHorizontalAndVertical(Square(rawValue: queenIndex)!, position: position) & ~friendlyPieces
        
        while potentialQueenMoves != 0 {
            queenMoveIndex = popBit(&potentialQueenMoves)
            let move = Move(from: Square(rawValue: queenIndex)!, to: Square(rawValue: queenMoveIndex)!)
            if position[queenMoveIndex] != .None {
                addCaptureMove(move, moves: &queenMoves, position: position)
            } else if !capturesOnly {
                addQuietMove(move, moves: &queenMoves, position: position)
            }
        }
        
        potentialQueenMoves = generateSlidingDiagonals(Square(rawValue: queenIndex)!, position: position) & ~friendlyPieces
        
        while potentialQueenMoves != 0 {
            queenMoveIndex = popBit(&potentialQueenMoves)
            let move = Move(from: Square(rawValue: queenIndex)!, to: Square(rawValue: queenMoveIndex)!)
            if position[queenMoveIndex] != .None {
                addCaptureMove(move, moves: &queenMoves, position: position)
            } else if !capturesOnly {
                addQuietMove(move, moves: &queenMoves, position: position)
            }
        }
    }
    return queenMoves
}

func generateKnightMoves(color color:Color, position:Board, capturesOnly:Bool = false) -> [Move] {
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
        switch(knightIndex % 8 + 1) {
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
            let move = Move(from: Square(rawValue: knightIndex)!, to: Square(rawValue: knightMoveIndex)!)
            if position[knightMoveIndex] != .None {
                addCaptureMove(move, moves: &knightMoves, position: position)
            } else if !capturesOnly {
                addQuietMove(move, moves: &knightMoves, position: position)
            }
        }
    }
    return knightMoves
}

func generateKingMoves(color:Color, position:Board, capturesOnly:Bool = false) -> [Move] {
    var kingMoves:[Move] = []
    var kingIndex:Int
    var kingMoveIndex:Int
    var kingBoard:BitBoard
    var friendlyBoard:BitBoard
    var enemyKing:BitBoard
    var unsafe:BitBoard
    
    switch(color) {
    case .White:
        kingBoard = position.White.King
        friendlyBoard = position.AllWhitePieces
        enemyKing = position.Black.King
        unsafe = generateUnsafeBoard(color: .White, position: position)
    case .Black:
        kingBoard = position.Black.King
        friendlyBoard = position.AllBlackPieces
        enemyKing = position.White.King
        unsafe = generateUnsafeBoard(color: .Black, position: position)
    }
    
    var nextKing:BitBoard = kingBoard
    kingIndex = popBit(&nextKing)
    var potentialKingMoves:BitBoard
    var mask:BitBoard
        
    //Calculate our mask to filter out illegal moves when we shift the King Span
    switch(kingIndex % 8 + 1) {
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
        
    potentialKingMoves = potentialKingMoves & mask & ~friendlyBoard & ~enemyKing & ~unsafe
        
    while potentialKingMoves != 0 {
        kingMoveIndex = popBit(&potentialKingMoves)
        let move = Move(from: Square(rawValue: kingIndex)!, to: Square(rawValue: kingMoveIndex)!)
        if position[kingMoveIndex] != .None {
            addCaptureMove(move, moves: &kingMoves, position: position)
        } else if !capturesOnly {
            addQuietMove(move, moves: &kingMoves, position: position)
        }
    }
    
     if !capturesOnly {
    //Castling
    if (unsafe & kingBoard == 0) {
        switch(color){
            case .White:
        
                if position.White.CanCastle.KingSide &&
                    unsafe & WHITE_KING_CASTLE_MASK == 0 &&
                    position.OccupiedSquares & WHITE_KING_BLOCKING_CASTLE_MASK == 0
                {
                    kingMoves.append(Move(from: Square.E1, to: Square.G1))
                }
        
                if position.White.CanCastle.QueenSide &&
                    unsafe & WHITE_QUEEN_CASTLE_MASK == 0 &&
                    position.OccupiedSquares & WHITE_QUEEN_BLOCKING_CASTLE_MASK == 0
                {
                    kingMoves.append(Move(from: Square.E1, to: Square.C1))
                }
            case .Black:
        
                if position.Black.CanCastle.KingSide &&
                    unsafe & BLACK_KING_CASTLE_MASK == 0 &&
                    position.OccupiedSquares & BLACK_KING_BLOCKING_CASTLE_MASK == 0
                {
                    kingMoves.append(Move(from: Square.E8, to: Square.G8))
                }
        
                if position.Black.CanCastle.QueenSide &&
                    unsafe & BLACK_QUEEN_CASTLE_MASK == 0 &&
                    position.OccupiedSquares & BLACK_QUEEN_BLOCKING_CASTLE_MASK == 0
                {
                    kingMoves.append(Move(from: Square.E8, to: Square.C8))
                }
        }
    }
    }
    
    
    return kingMoves

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
    let antiDiagonal = ((occupied & antiDiagMask) &- (2 &* piece)) ^ reverse(reverse(occupied & antiDiagMask) &- (2 &* reverse(piece)));
    
    return (diagonal & diagMask) | (antiDiagonal & antiDiagMask);
}


func addCaptureMove(var move:Move, inout moves:[Move], position:Board) {
    let victim = position[move.to.rawValue] == .None ? .WhitePawn : position[move.to.rawValue]
    let attacker = position[move.from.rawValue]
    let score = CAPTURE_SCORE[victim]![attacker]! + 1000000
    move.score = score
    moves.append(move)
}

func addQuietMove(var move:Move, inout moves:[Move], position:Board) {
    
    if search.killerOne[position.SearchPly] == move {
        move.score = 900000
    } else if search.killerTwo[position.SearchPly] == move {
        move.score = 800000
    } else {
        if let piece = search.history[position[move.from.rawValue]], let score = piece[move.to.rawValue] {
            move.score = score
        }
    }
    moves.append(move)
}