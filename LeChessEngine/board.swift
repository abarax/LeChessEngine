//
//  board.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 5/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

typealias BitBoard = UInt64

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
}

enum Color {
    case Black
    case White
}

struct CastleState {
    var KingSide = true
    var QueenSide = true
}

enum Piece {
    case WhitePawn
    case WhiteRook
    case WhiteKnight
    case WhiteBishop
    case WhiteQueen
    case WhiteKing
    case BlackPawn
    case BlackRook
    case BlackKnight
    case BlackBishop
    case BlackQueen
    case BlackKing
    case None
}

enum Square:Int {
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
                case "r":
                    self.setPiece(Piece.BlackRook, square: Square(rawValue: sq)!)
                case "n":
                    self.setPiece(Piece.BlackKnight, square: Square(rawValue: sq)!)
                case "b":
                    self.setPiece(Piece.BlackBishop, square: Square(rawValue: sq)!)
                case "q":
                    self.setPiece(Piece.BlackQueen, square: Square(rawValue: sq)!)
                case "k":
                    self.setPiece(Piece.BlackKing, square: Square(rawValue: sq)!)
                case "p":
                    self.setPiece(Piece.BlackPawn, square: Square(rawValue: sq)!)
                case "R":
                    self.setPiece(Piece.WhiteRook, square: Square(rawValue: sq)!)
                case "N":
                    self.setPiece(Piece.WhiteKnight, square: Square(rawValue: sq)!)
                case "B":
                    self.setPiece(Piece.WhiteBishop, square: Square(rawValue: sq)!)
                case "Q":
                    self.setPiece(Piece.WhiteQueen, square: Square(rawValue: sq)!)
                case "K":
                    self.setPiece(Piece.WhiteKing, square: Square(rawValue: sq)!)
                case "P":
                    self.setPiece(Piece.WhitePawn, square: Square(rawValue: sq)!)
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
    
    var description:String {
        
        var squares = [Character](count: 64, repeatedValue: " ")
        var mask:BitBoard = 1
        
        for index in 0...63 {
            if (mask & White.Pawns != 0) {
                squares[index] = "P"
            } else if (mask & White.Bishops != 0) {
                squares[index] = "B"
            } else if (mask & White.Rooks != 0) {
                squares[index] = "R"
            } else if (mask & White.Queens != 0) {
                squares[index] = "Q"
            } else if (mask & White.King != 0) {
                squares[index] = "K"
            } else if (mask & White.Knights != 0) {
                squares[index] = "N"
            } else if (mask & Black.Pawns != 0) {
                squares[index] = "p"
            } else if (mask & Black.Rooks != 0) {
                squares[index] = "r"
            } else if (mask & Black.Knights != 0) {
                squares[index] = "n"
            } else if (mask & Black.Bishops != 0) {
                squares[index] = "b"
            } else if (mask & Black.Queens != 0) {
                squares[index] = "q"
            } else if (mask & Black.King != 0) {
                squares[index] = "k"
            }
            //Check next piece on bitboard
            mask = mask << 1
        }
        
        var str = ""
        str += "   ________________________________\r"
        str += "8 | \(squares[56]) | \(squares[57]) | \(squares[58]) | \(squares[59]) | \(squares[60]) | \(squares[61]) | \(squares[62]) | \(squares[63]) |\r"
        str += "   ________________________________\r"
        str += "7 | \(squares[48]) | \(squares[49]) | \(squares[50]) | \(squares[51]) | \(squares[52]) | \(squares[53]) | \(squares[54]) | \(squares[55]) |\r"
        str += "   ________________________________\r"
        str += "6 | \(squares[40]) | \(squares[41]) | \(squares[42]) | \(squares[43]) | \(squares[44]) | \(squares[45]) | \(squares[46]) | \(squares[47]) |\r"
        str += "   ________________________________\r"
        str += "5 | \(squares[32]) | \(squares[33]) | \(squares[34]) | \(squares[35]) | \(squares[36]) | \(squares[37]) | \(squares[38]) | \(squares[39]) |\r"
        str += "   ________________________________\r"
        str += "4 | \(squares[24]) | \(squares[25]) | \(squares[26]) | \(squares[27]) | \(squares[28]) | \(squares[29]) | \(squares[30]) | \(squares[31]) |\r"
        str += "   ________________________________\r"
        str += "3 | \(squares[16]) | \(squares[17]) | \(squares[18]) | \(squares[19]) | \(squares[20]) | \(squares[21]) | \(squares[22]) | \(squares[23]) |\r"
        str += "   ________________________________\r"
        str += "2 | \(squares[8]) | \(squares[9]) | \(squares[10]) | \(squares[11]) | \(squares[12]) | \(squares[13]) | \(squares[14]) | \(squares[15]) |\r"
        str += "   ________________________________\r"
        str += "1 | \(squares[0]) | \(squares[1]) | \(squares[2]) | \(squares[3]) | \(squares[4]) | \(squares[5]) | \(squares[6]) | \(squares[7]) |\r"
        str += "   ________________________________\r"
        str += "    a   b   c   d   e   f   g   h"
        
        return str
    }
}