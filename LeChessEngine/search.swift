//
//  search.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 23/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

struct ScoredMove {
    let score:Int
    let move:Move
}

var principle_variations:[Int:ScoredMove] = [:]

func get_principle_line(board:Board, depth:Int) -> [ScoredMove] {
    var boardCopy = board
    var line = [ScoredMove]()
    for _ in 1...depth {
        if let pv = principle_variations[boardCopy.hashValue] {
            line.append(pv)
            doMove(&boardCopy, move: pv.move)
        }
       
        
    }
    
    return line
}

func Search(let board:Board) -> ScoredMove {

    var bestMove:ScoredMove = ScoredMove(score: Int.min + 1, move: Move())
    let SEARCH_DEPTH = 4
    
    for depth in 1...SEARCH_DEPTH {
        -AlphaBeta(board, depth: depth, alpha: Int.min + 1, beta: Int.max)
        //Check Time - can we go deeper?
        let pvMoves = get_principle_line(board, depth: depth);
        bestMove = pvMoves[0]
        
        print("Depth:\(depth) score:\(bestMove.score) move:\(bestMove.move)")
        for (index, pvMove) in pvMoves.enumerate() {
            print("\(index): \(pvMove.move.from) \(pvMove.move.to)")
        }
        print("-------------------------------------------")
    }
    
    return bestMove
}

func Quiescence(var board:Board, var alpha:Int, beta:Int) -> Int {
    return 0
}

func AlphaBeta(var board:Board, depth:Int, var alpha:Int, beta:Int) -> Int {

    if depth == 0 { return Evaluate(board) }
    
    let moves = generateMoves(board)
    
    var legalMoveCount = 0
    var bestMove = ScoredMove(score: 0, move: Move())
    let oldAlpha = alpha
    
    for move in moves {
        
        let undo = doMove(&board, move: move)
        
        if !board.isLegal() {
            undoMove(&board, undo: undo)
            continue
        }
        
        legalMoveCount++

        let score = -AlphaBeta(board, depth: depth - 1, alpha: -beta, beta: -alpha)
        
        undoMove(&board, undo: undo)
        
        if (score >= beta) { return beta }
        
        if (score > alpha) {
            alpha = score
            bestMove = ScoredMove(score: score, move: move)
        }
        
    }
    
    if legalMoveCount == 0 {
        if (board.isChecked()) {
            return -CHECKMATE
        } else {
            return 0
        }
    }
    
    if alpha != oldAlpha {
        principle_variations[board.hashValue] = bestMove
    }
    return alpha
    
}
