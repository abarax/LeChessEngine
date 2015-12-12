//
//  board.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 5/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

typealias BitBoard = UInt64

let EmptyBoard:BitBoard = 0

extension BitBoard {
    
    func printBoard() {
        var bitMask:BitBoard = UInt64(1) << 63
        
        for x in 1...8 {
            print(" \(9 - x)  ", terminator: "")
            for y in 0...7 {
                print(self & (bitMask >> (7 - UInt64(y))) > 0 ? " x " : " . ", terminator: "")
            }
            bitMask >>= UInt64(8)
            print("")
            print("")
        }
        print("")
        print("     a  b  c  d  e  f  g  h")
        print("")
    }
    
    func printBinary() {
        print(String(self, radix: 2))
    }
    
    
    func reverse() -> BitBoard {
        var i = self
        // HD, Figure 7-1
        i = (i & 0x5555555555555555) << 1 | (i >> 1) & 0x5555555555555555;
        i = (i & 0x3333333333333333) << 2 | (i >> 2) & 0x3333333333333333;
        i = (i & 0x0f0f0f0f0f0f0f0f) << 4 | (i >> 4) & 0x0f0f0f0f0f0f0f0f;
        i = (i & 0x00ff00ff00ff00ff) << 8 | (i >> 8) & 0x00ff00ff00ff00ff;
        i = (i << 48) | ((i & 0xffff0000) << 16) |
            ((i >> 16) & 0xffff0000) | (i >> 48);
        return i;
    }
    
}

func reverse(var i:BitBoard) -> BitBoard {
    // HD, Figure 7-1
    i = (i & 0x5555555555555555) << 1 | (i >> 1) & 0x5555555555555555;
    i = (i & 0x3333333333333333) << 2 | (i >> 2) & 0x3333333333333333;
    i = (i & 0x0f0f0f0f0f0f0f0f) << 4 | (i >> 4) & 0x0f0f0f0f0f0f0f0f;
    i = (i & 0x00ff00ff00ff00ff) << 8 | (i >> 8) & 0x00ff00ff00ff00ff;
    i = (i << 48) | ((i & 0xffff0000) << 16) |
        ((i >> 16) & 0xffff0000) | (i >> 48);
    return i;
}

enum Color {
    case Black
    case White
}

struct CastleState {
    var KingSide = true
    var QueenSide = true
}

enum Piece:Character {
    case WhitePawn   = "P"
    case WhiteRook   = "R"
    case WhiteKnight = "N"
    case WhiteBishop = "B"
    case WhiteQueen  = "Q"
    case WhiteKing   = "K"
    case BlackPawn   = "p"
    case BlackRook   = "r"
    case BlackKnight = "n"
    case BlackBishop = "b"
    case BlackQueen  = "q"
    case BlackKing   = "k"
    case None        = " "
}

enum Square:Int {
    // --------------------------------
    // Little Endian Rank File Mapping
    // --------------------------------
    //
    //  noWe         nort         noEa
    //          +7    +8    +9
    //              \  |  /
    //  west    -1 <-  0 -> +1    east
    //              /  |  \
    //          -9    -8    -7
    //  soWe         sout         soEa
    //
    // --------------------------------
    case A1, B1, C1, D1, E1, F1, G1, H1
    case A2, B2, C2, D2, E2, F2, G2, H2
    case A3, B3, C3, D3, E3, F3, G3, H3
    case A4, B4, C4, D4, E4, F4, G4, H4
    case A5, B5, C5, D5, E5, F5, G5, H5
    case A6, B6, C6, D6, E6, F6, G6, H6
    case A7, B7, C7, D7, E7, F7, G7, H7
    case A8, B8, C8, D8, E8, F8, G8, H8
    case None
    
    init(rankAndFile:String) {
        let files = "abcdefgh"
        let file = String(rankAndFile[0]).lowercaseString
        let rank = String(rankAndFile[1])
        
        self = Square(rawValue: ((Int(rank)! - 1) * 8) + files.indexOf(file))!
    }
    
    var File:Int {
        return self.rawValue % 64
    }
    
    var Rank:Int {
        return self.rawValue / 8
    }
}

struct PieceState {
    var Pawns:BitBoard = 0
    var Rooks:BitBoard = 0
    var Knights:BitBoard = 0
    var Bishops:BitBoard = 0
    var Queens:BitBoard = 0
    var King:BitBoard = 0
    var CanCastle:CastleState = CastleState()
}

struct Board : CustomStringConvertible {
    
    var Turn:Color = .White
    var White:PieceState = PieceState()
    var Black:PieceState = PieceState()
    var EnPassantSquare:Square = Square.None
    var PliesSinceLastPawnAdvanceOrCapture:Int = 0
    var MoveCount:Int = 0
    var LastMove:Move = Move(from: Square.None, to: Square.None)
    var AllWhitePieces:BitBoard {
        return White.King | White.Queens | White.Rooks | White.Bishops | White.Knights | White.Pawns
    }
    var AllBlackPieces:BitBoard {
        return Black.King | Black.Queens | Black.Rooks | Black.Bishops | Black.Knights | Black.Pawns
    }
    var OccupiedSquares:BitBoard {
        return AllWhitePieces | AllBlackPieces
    }
    var OpenSquares:BitBoard {
        return ~OccupiedSquares
    }
    
    mutating func clear() -> Board {
        self = Board()
        return self
    }
    
    mutating func setPiece(piece:Piece, square:Square) -> Board {
        
        //Shift by rank and file so our bit is set in correct position
        
        let pieceMask:BitBoard = (1 << UInt64(square.rawValue))
        
        switch piece {
        case .WhitePawn:
            White.Pawns |= pieceMask
        case .WhiteRook:
            White.Rooks |= pieceMask
        case .WhiteKnight:
            White.Knights |= pieceMask
        case .WhiteBishop:
            White.Bishops |= pieceMask
        case .WhiteQueen:
            White.Queens |= pieceMask
        case .WhiteKing:
            White.King |= pieceMask
        case .BlackPawn:
            Black.Pawns |= pieceMask
        case .BlackRook:
            Black.Rooks |= pieceMask
        case .BlackKnight:
            Black.Knights |= pieceMask
        case .BlackBishop:
            Black.Bishops |= pieceMask
        case .BlackQueen:
            Black.Queens |= pieceMask
        case .BlackKing:
            Black.King |= pieceMask
        default: break
        }
        
        return self
    }
    
    mutating func loadFenBoardState(fenState:String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1") -> Board {
        var ranks = fenState.componentsSeparatedByString("/")
        let lastSection = ranks.last!.componentsSeparatedByString(" ")
        var otherBoardDetails = lastSection[1...lastSection.count-1].generate()
        ranks[ranks.count-1] = lastSection.first!
        for (rankIndex, rank) in ranks.enumerate() {
            var space = 0
            for (charIndex, char) in rank.characters.enumerate() {
                //Calculate the square to place piece on
                let sq = (63 - ((rankIndex * 8) + (7 - charIndex))) + space
                switch(char) {
                case Piece.BlackRook.rawValue:
                    self.setPiece(.BlackRook, square: Square(rawValue: sq)!)
                case Piece.BlackKnight.rawValue:
                    self.setPiece(.BlackKnight, square: Square(rawValue: sq)!)
                case Piece.BlackBishop.rawValue:
                    self.setPiece(.BlackBishop, square: Square(rawValue: sq)!)
                case Piece.BlackQueen.rawValue:
                    self.setPiece(.BlackQueen, square: Square(rawValue: sq)!)
                case Piece.BlackKing.rawValue:
                    self.setPiece(.BlackKing, square: Square(rawValue: sq)!)
                case Piece.BlackPawn.rawValue:
                    self.setPiece(.BlackPawn, square: Square(rawValue: sq)!)
                case Piece.WhiteRook.rawValue:
                    self.setPiece(.WhiteRook, square: Square(rawValue: sq)!)
                case Piece.WhiteKnight.rawValue:
                    self.setPiece(.WhiteKnight, square: Square(rawValue: sq)!)
                case Piece.WhiteBishop.rawValue:
                    self.setPiece(.WhiteBishop, square: Square(rawValue: sq)!)
                case Piece.WhiteQueen.rawValue:
                    self.setPiece(.WhiteQueen, square: Square(rawValue: sq)!)
                case Piece.WhiteKing.rawValue:
                    self.setPiece(.WhiteKing, square: Square(rawValue: sq)!)
                case Piece.WhitePawn.rawValue:
                    self.setPiece(.WhitePawn, square: Square(rawValue: sq)!)
                case "1":
                    space += 0
                case "2":
                    space += 1
                case "3":
                    space += 2
                case "4":
                    space += 3
                case "5":
                    space += 4
                case "6":
                    space += 5
                case "7":
                    space += 6
                case "8":
                    space += 7
                default: break
                    
                }
            }
            
        }
        
        let turn = otherBoardDetails.next()!
        switch(turn) {
        case "w":
            self.Turn = .White
        case "b":
            self.Turn = .Black
        default: break
        }
        
        self.White.CanCastle = CastleState(KingSide: false, QueenSide: false)
        self.Black.CanCastle = CastleState(KingSide: false, QueenSide: false)
        
        let castle = otherBoardDetails.next()!
        switch(castle) {
        case "K":
            self.White.CanCastle.KingSide = true
        case "Q":
            self.White.CanCastle.QueenSide = true
        case "k":
            self.Black.CanCastle.KingSide = true
        case "q":
            self.Black.CanCastle.QueenSide = true
        default:
            break
        }
        
        let enPassant = otherBoardDetails.next()!
        if enPassant != "-" {
            self.EnPassantSquare = Square(rankAndFile: enPassant)
        }
        
        self.PliesSinceLastPawnAdvanceOrCapture = Int(otherBoardDetails.next()!)!
        
        self.MoveCount = Int(otherBoardDetails.next()!)!
        
        return self
    }
    
    subscript (square: Int) -> Piece {
        
        let mask:BitBoard = setBit(square)
        
        if (mask & White.Pawns != 0) {
            return .WhitePawn
        } else if (mask & White.Bishops != 0) {
            return .WhiteBishop
        } else if (mask & White.Rooks != 0) {
            return .WhiteRook
        } else if (mask & White.Queens != 0) {
            return .WhiteQueen
        } else if (mask & White.King != 0) {
            return .WhiteKing
        } else if (mask & White.Knights != 0) {
            return .WhiteKnight
        } else if (mask & Black.Pawns != 0) {
            return .BlackPawn
        } else if (mask & Black.Rooks != 0) {
            return .BlackRook
        } else if (mask & Black.Knights != 0) {
            return .BlackKnight
        } else if (mask & Black.Bishops != 0) {
            return .BlackBishop
        } else if (mask & Black.Queens != 0) {
            return .BlackQueen
        } else if (mask & Black.King != 0) {
            return .BlackKing
        } else {
            return .None
        }
    }
    
    var description:String {
        
        var str = ""
        str += "   ________________________________\r"
        for i in (1...8).reverse() {
            let row = (
                self[i * 8 - 8].rawValue,
                self[i * 8 - 7].rawValue,
                self[i * 8 - 6].rawValue,
                self[i * 8 - 5].rawValue,
                self[i * 8 - 4].rawValue,
                self[i * 8 - 3].rawValue,
                self[i * 8 - 2].rawValue,
                self[i * 8 - 1].rawValue
            )
            str += "\(i) | \(row.0) | \(row.1) | \(row.2) | \(row.3) | \(row.4) | \(row.5) | \(row.6) | \(row.7) |\r"
            
            str += "   ________________________________\r"
        }
        
        str += "    a   b   c   d   e   f   g   h"
        
        return str
    }
}