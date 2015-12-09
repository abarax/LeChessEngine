//
//  main.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 3/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

var board = Board()

board.loadFenBoardState("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")

print(board)

board.clear()

print("r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1")
board.loadFenBoardState("r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1")

//print(board)

generateMoves(.White, position: board)
generateMoves(.Black, position: board)

let a:BitBoard = 0b10000000000000000000111100000000

a.printBoard()
var NewBoard = Board()
NewBoard.White.Pawns = a
NewBoard.Black.Pawns = 0b0001000000100000000000000000

print("TEST BOARD")
print(NewBoard)

generatePawnMoves(Color.White, position: NewBoard)






