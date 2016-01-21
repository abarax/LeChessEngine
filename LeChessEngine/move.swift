//
//  move.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 15/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

struct Undo {
    let move:Move
    let piece:Piece
    let capture:Piece
    let castle:(white: CastleState, black: CastleState)
    let enpassant:Square
}

func doMove(inout board:Board, move:Move) -> Undo {
    let undo = Undo(
        move: move,
        piece: board[move.from.rawValue],
        capture: board[move.to.rawValue],
        castle: board.CanCastle,
        enpassant: board.EnPassantSquare)
    
    board.MoveCount++
    board.Turn = board.Turn == .White ? .Black : .White
    
    var piece:Piece
    if move.promotion != Piece.None {
        piece = move.promotion
    } else {
        piece = board[move.from.rawValue]
    }
    //Unset Enpassant square
    board.EnPassantSquare = Square.None
    
    //Remove piece from 'from' square
    board.setPiece(Piece.None, square: move.from)
    //Set piece on 'to' square
    board.setPiece(piece, square: move.to)
    
    switch(piece) {
        case .WhitePawn:
            //Set EnPassant Square
            if move.from.Rank == 2 && move.to.Rank == 4 {
                board.EnPassantSquare = Square(rawValue: move.from.rawValue + 8)!
            }
            //Check if executing enpassant
            if move.to == undo.enpassant {
                board.setPiece(Piece.None, square: Square(rawValue: move.to.rawValue - 8)!)
            }
        
        case .WhiteRook:
            if move.from == Square.A1 {
                board.White.CanCastle.QueenSide = false
            } else if move.from == Square.H1 {
                board.White.CanCastle.KingSide = false
            }
        case .WhiteKing:
            board.White.CanCastle.QueenSide = false
            board.White.CanCastle.KingSide = false
            // Check if castling and execute
            if move.from == Square.E1 {
                if move.to == Square.G1 {
                    board.setPiece(Piece.WhiteRook, square: Square.F1)
                    board.setPiece(Piece.None, square: Square.H1)
                } else if move.to == Square.C1 {
                    board.setPiece(Piece.WhiteRook, square: Square.D1)
                    board.setPiece(Piece.None, square: Square.A1)
                }
            }
        case .BlackPawn:
            //Set EnPassant Square
            if move.from.Rank == 7 && move.to.Rank == 5 {
                board.EnPassantSquare = Square(rawValue: move.from.rawValue - 8)!
            }
            //Check if executing enpassant
            if move.to == undo.enpassant {
                board.setPiece(Piece.None, square: Square(rawValue: move.to.rawValue + 8)!)
            }
        case .BlackRook:
            if move.from == Square.A8 {
                board.Black.CanCastle.QueenSide = false
            } else if move.from == Square.H8 {
                board.Black.CanCastle.KingSide = false
            }
        case .BlackKing:
            board.Black.CanCastle.QueenSide = false
            board.Black.CanCastle.KingSide = false
            // Check if castling and execute
            if move.from == Square.E8 {
                if move.to == Square.G8 {
                    board.setPiece(Piece.BlackRook, square: Square.F8)
                    board.setPiece(Piece.None, square: Square.H8)
                } else if move.to == Square.C8 {
                    board.setPiece(Piece.BlackRook, square: Square.D8)
                    board.setPiece(Piece.None, square: Square.A8)
                }
            }
        default: break
    }
    
    switch (undo.capture) {
    case .WhiteRook:
        if move.to == Square.A1 {
            board.White.CanCastle.QueenSide = false
        }
        if move.to == Square.H1 {
            board.White.CanCastle.KingSide = false
        }
    case .BlackRook:
        if move.to == Square.A8 {
            board.Black.CanCastle.QueenSide = false
        }
        if move.to == Square.H8 {
            board.Black.CanCastle.KingSide = false
        }
    default: break
    }
    return undo
}

func undoMove(inout board:Board, undo:Undo) {
    //Reset piece on 'from' square
    board.setPiece(undo.piece, square: undo.move.from)
    //Reset piece on 'to' square
    board.setPiece(undo.capture, square: undo.move.to)
    
    board.White.CanCastle = undo.castle.white
    board.Black.CanCastle = undo.castle.black
    board.EnPassantSquare = undo.enpassant
    board.MoveCount--
    board.Turn = board.Turn == .White ? .Black : .White
    
    switch(undo.piece) {
    case .WhitePawn:
        //Check if executing enpassant
        if undo.move.to == undo.enpassant {
            board.setPiece(Piece.BlackPawn, square: Square(rawValue: undo.move.to.rawValue - 8)!)
        }
    case .WhiteKing:
        if undo.move.from == Square.E1 {
            if undo.move.to == Square.G1 {
                board.setPiece(Piece.WhiteRook, square: Square.H1)
                board.setPiece(Piece.None, square: Square.F1)
            } else if undo.move.to == Square.C1 {
                board.setPiece(Piece.WhiteRook, square: Square.A1)
                board.setPiece(Piece.None, square: Square.D1)
            }
        }
    case .BlackPawn:
        //Check if executing enpassant
        if undo.move.to == undo.enpassant {
            board.setPiece(Piece.WhitePawn, square: Square(rawValue: undo.move.to.rawValue + 8)!)
        }
    case .BlackKing:
        if undo.move.from == Square.E8 {
            if undo.move.to == Square.G8 {
                board.setPiece(Piece.BlackRook, square: Square.H8)
                board.setPiece(Piece.None, square: Square.F8)
            } else if undo.move.to == Square.C8 {
                board.setPiece(Piece.BlackRook, square: Square.A8)
                board.setPiece(Piece.None, square: Square.D8)
            }
        }
    default: break
    }
    
}

func parseMove(move:String) -> Move {
    if move.length == 5 {
        return Move(
            from:Square(rankAndFile: move[0...2]),
            to: Square(rankAndFile: move[2...4]),
            promotion: Piece(rawValue: move[4])!)
    } else {
        return Move(
            from:Square(rankAndFile: move[0...2]),
            to: Square(rankAndFile: move[2...4]))
    }
}