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

//print(board)

//board.clear()

//board.loadFenBoardState("r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1")

print(board)

var moves = generateMoves(.Black, position: board)


