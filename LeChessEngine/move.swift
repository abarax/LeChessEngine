//
//  move.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 15/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

func doMove(var position:Board, move:Move) {
    var piece:Piece
    if move.promotion != Piece.None {
        piece = move.promotion
    } else {
        piece = position[move.from.rawValue]
    }
    
    //Remove piece from 'from' square
    position.setPiece(Piece.None, square: move.from)
    //Set piece on 'to' square
    position.setPiece(piece, square: move.to)
    
    switch(piece) {
        case .WhitePawn:
            //Set EnPassant Square
            if move.from.Rank == 2 && move.to.Rank == 4 {
                position.EnPassantSquare = Square(rawValue: move.from.rawValue + 8)!
            }
        case .WhiteRook:
            if move.from == Square.A1 {
                position.White.CanCastle.QueenSide = false
            } else if move.from == Square.H1 {
                position.White.CanCastle.KingSide = false
            }
        case .WhiteKing:
            position.White.CanCastle.QueenSide = false
            position.White.CanCastle.KingSide = false
        case .BlackPawn:
            //Set EnPassant Square
            if move.from.Rank == 7 && move.to.Rank == 5 {
                position.EnPassantSquare = Square(rawValue: move.from.rawValue - 8)!
            }
        case .BlackRook:
            if move.from == Square.A8 {
                position.Black.CanCastle.QueenSide = false
            } else if move.from == Square.H8 {
                position.Black.CanCastle.KingSide = false
            }
        case .BlackKing:
            position.Black.CanCastle.QueenSide = false
            position.Black.CanCastle.KingSide = false
        default:
            return
    }
}

func undoMove() {
    
}