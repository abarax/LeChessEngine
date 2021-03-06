//
//  main.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 3/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

var running = true
var board:Board = Board()
var undo:Undo?

print("------------------------")
print("Welcome to LeChessEngine")
print("------------------------\n")

while running {
    print("\n > ", terminator: "")
    if let response = readLine(stripNewline: true) {
        switch response {
            case "hello":
                print("Why, hello there")
            case "exit":
                print("Thanks for playing! Come again soon.")
                running = false
            case "new":
                board.loadFenBoardState(NewGame)
                print(board)
            case "load":
                board.loadFenBoardState("2rr3k/pp3pp1/1nnqbN1p/3pN3/2pP4/2P3Q1/PPB4P/R4RK1 w - - 0 1")
                print(board)
            case "print":
                print(board)
            case "undo":
                if let moveToUndo = undo {
                   undoMove(&board, undo: moveToUndo)
                    print(board)
                } else {
                    print("No move has been made yet")
                }
            case "search":
                let val = Search(board)
                print(val)
            case "test":
                var list = SkipList<Int>()
                
                list.add(7)
                list.add(12)
                list.add(3)
                list.add(7)
                list.add(123)
                list.add(4234)
                list.add(234)
                list.add(23423)
                print(list)
                print(list.size)
            case "":
                break
            default:
                //Default Case
                //Check format to see if its a move
                if response.rangeOfString("[a-h][1-8][a-h][1-8][q,k,b,r]?", options: .RegularExpressionSearch) != nil {
                    let move = parseMove(response)
                    let moves = generateMoves(board)
                    if moves.contains(
                        { $0.from == move.from &&
                          $0.to == move.to &&
                          $0.promotion == move.promotion }) {
                        undo = doMove(&board, move: move)
                        print(board)
                    } else { print("Illegal Move") }
                // The true default case
                } else {
                    print("Unrecognized command")
                }
        }
    }

}

//var board = Board()
//
//board.loadFenBoardState("k7/8/7P/8/8/8/6p1/K7 w - - 0 1")
//print(board)
//print(divide(board, depth: 1))


