//
//  attack.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 12/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

func isSquareAttacked(square:Square, color:Color, position:Board) -> Bool {
    var unsafe:BitBoard = EmptyBoard
    
    let pieces = color == .White ? position.Black : position.White
    
    //Pawns
    switch(color) {
    case .White:
        unsafe |= pieces.Pawns >> 7 & ~FILE_A
        unsafe |= pieces.Pawns >> 9 & ~FILE_H
    case .Black:
        unsafe |= pieces.Pawns << 7 & ~FILE_H
        unsafe |= pieces.Pawns << 9 & ~FILE_A
    }
    
    //Rooks and Queens
    var nextRookOrQueen:BitBoard = pieces.Rooks | pieces.Queens
    var rookIndex:Int
    while nextRookOrQueen != 0 {
        (rookIndex, nextRookOrQueen) = popBit(nextRookOrQueen)
        unsafe |= generateSlidingHorizontalAndVertical(Square(rawValue: rookIndex)!, position: position)
    }
    
    //Knights
    var nextKnight:BitBoard = pieces.Knights
    var knightIndex:Int
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
        
        unsafe |= potentialKnightMoves & mask
    }
    
    //Bishops and Queens
    
    var nextBishopOrQueen:BitBoard = pieces.Bishops | pieces.Queens
    var bishopOrQueenIndex:Int
    while nextBishopOrQueen != 0 {
        (bishopOrQueenIndex, nextBishopOrQueen) = popBit(nextBishopOrQueen)
        unsafe |= generateSlidingDiagonals(Square(rawValue: bishopOrQueenIndex)!, position: position)
    }
    
    //King
    
    var nextKing:BitBoard = pieces.King
    var kingIndex:Int
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
    
    unsafe |= potentialKingMoves & mask

    
    return true
}