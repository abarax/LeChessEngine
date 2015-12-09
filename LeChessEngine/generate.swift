//
//  moves.swift
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
    return UInt64(1 << (index-1))
}

func popBit(board:BitBoard) -> (Int, BitBoard) {
    let bitIndex:Int = msb(board)
    let bit:BitBoard = setBit(bitIndex)
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
    pawnMoves.append(Move(from: Square.A1, to: Square.B2, promotion: Piece.BlackBishop))
    
    if color == Color.White {
        
        //Move forward one square
        var moveOneForward:BitBoard = ((position.White.Pawns << 8) & position.OpenSquares) & ~RANK_8
        print("One Forward")
        moveOneForward.printBoard()
        while moveOneForward != 0 {
            (index, moveOneForward) = popBit(moveOneForward)
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!))
        }
        
        //Move forward two squares
        var moveTwoForward:BitBoard = ((((position.White.Pawns << 8) & position.OpenSquares) << 8) & position.OpenSquares) & RANK_4
        print("Two Forward")
        moveTwoForward.printBoard()
        while moveTwoForward != 0 {
            (index, moveTwoForward) = popBit(moveTwoForward)
            pawnMoves.append(Move(from: Square(rawValue: index - 16)!, to: Square(rawValue: index)!))
        }
        
        //Capture right
        var captureRight:BitBoard = (((position.White.Pawns << 7) & position.AllBlackPieces) & ~RANK_8) & ~FILE_A
        print ("Capture Right")
        captureRight.printBoard()
        while captureRight != 0 {
            (index, captureRight) = popBit(captureRight)
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!))
        }
        
        //Capture left
        var captureLeft:BitBoard = (((position.White.Pawns << 9) & position.AllBlackPieces) & ~RANK_8) & ~FILE_H
        print ("Capture Left")
        captureLeft.printBoard()
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
        print("Promote One Forward")
        promoteOneForward.printBoard()
        while promoteOneForward != 0 {
            (index, promoteOneForward) = popBit(promoteOneForward)
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen))
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop))
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight))
            pawnMoves.append(Move(from: Square(rawValue: index - 8)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook))
        }
        
        var promoteCaptureRight:BitBoard = (((position.White.Pawns << 7) & position.AllBlackPieces) & RANK_8) & ~FILE_A
        print ("Promote Capture Right")
        promoteCaptureRight.printBoard()
        while promoteCaptureRight != 0 {
            (index, promoteCaptureRight) = popBit(promoteCaptureRight)
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen))
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop))
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight))
            pawnMoves.append(Move(from: Square(rawValue: index - 9)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook))
        }
        
        var promoteCaptureLeft:BitBoard = (((position.White.Pawns << 9) & position.AllBlackPieces) & RANK_8) & ~FILE_H
        print ("Promote Capture Left")
        promoteCaptureLeft.printBoard()
        while promoteCaptureLeft != 0 {
            (index, promoteCaptureLeft) = popBit(promoteCaptureLeft)
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackQueen))
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackBishop))
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackKnight))
            pawnMoves.append(Move(from: Square(rawValue: index - 7)!, to: Square(rawValue: index)!, promotion: Piece.BlackRook))
        }
        

    }
    else if color == Color.Black {
        //Move forward one square
        let moveOneForward:BitBoard = position.Black.Pawns << 8
        //Move forward two squares
        
        //Capture right
        
        //Capture left
        
        //Enpassant 
        
        //Promotion
        
    }
    
    
    
    return pawnMoves
}

func generateRookMoves(color:Color, position:Board) -> [Move] {
    var rookMoves:[Move] = []
   
    return rookMoves
}

func generateKnightMoves(color:Color, position:Board) -> [Move] {
    var knightMoves:[Move] = []
        return knightMoves
}

func generateBishopMoves(color:Color, position:Board) -> [Move] {
    var bishopMoves:[Move] = []
    
    return bishopMoves
}

func generateQueenMoves(color:Color, position:Board) -> [Move] {
    var queenMoves:[Move] = []
    
    return queenMoves
}

func generateKingMoves(color:Color, position:Board) -> [Move] {
    var kingMoves:[Move] = []

    return kingMoves
}