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

struct SearchInfo {
    var principle_variations:[Int:ScoredMove] = [:]
    var killerOne:[Int:Move] = [:]
    var killerTwo:[Int:Move] = [:]
    var history:[Piece:[Int:Int]] = [:]
    var nodes = 0
    var fail_high = 0.0
    var fail_high_first = 0.0
    var max_depth = 6
}

func get_principle_line(board:Board, depth:Int) -> [ScoredMove] {
    var boardCopy = board
    var line = [ScoredMove]()
    for _ in 1...depth {
        if let pv = search.principle_variations[boardCopy.hashValue] {
            line.append(pv)
            doMove(&boardCopy, move: pv.move)
        }
    }
    return line
}

func Search(var board:Board) -> ScoredMove {

    var bestMove:ScoredMove = ScoredMove(score: Int.min + 1, move: Move())
    
    board.SearchPly = 0
    
    for depth in 1...search.max_depth {
        -AlphaBeta(board, depth: depth, alpha: Int.min + 1, beta: Int.max)
        //Check Time - can we go deeper?
        let pvMoves = get_principle_line(board, depth: depth);
        bestMove = pvMoves[0]
        
        print("Depth:\(depth) score:\(bestMove.score) move:\(bestMove.move)")
        for (index, pvMove) in pvMoves.enumerate() {
            print("\(index): \(pvMove.move.from) \(pvMove.move.to)")
        }
        print("Nodes searched: \(search.nodes)")
        print("Ordering: \(search.fail_high_first) / \(search.fail_high): \(search.fail_high_first/search.fail_high)")
        print("-------------------------------------------")
    }
    
    return bestMove
}

func Quiescence(var board:Board, var alpha:Int, beta:Int) -> Int {
    search.nodes++
    
    if board.SearchPly >= search.max_depth {
        return Evaluate(board)
    }
    
    var score:Int = Evaluate(board)
    
    
    if score >= beta {
        return beta
    }
    
    if score > alpha {
        alpha = score
    }

    let moves = generateCaptureMoves(board)
    let sortedMoves = moves.sort({ $0.score > $1.score })
    score = Int.min
    var legalMoveCount = 0
    var bestMove = ScoredMove(score: 0, move: Move())
    let oldAlpha = alpha
    
    
    for move in sortedMoves {
        let undo = doMove(&board, move: move)
        
        if !board.isLegal() {
            undoMove(&board, undo: undo)
            continue
        }
        
        legalMoveCount++
        
        let score = -Quiescence(board, alpha: -beta, beta: -alpha)
        undoMove(&board, undo: undo)
        
        if (score > alpha) {
            if (score >= beta) {
                if legalMoveCount == 1 { search.fail_high_first++ }
                search.fail_high++
                return beta;
            }
            alpha = score
            bestMove = ScoredMove(score: score, move: move)
        }
    }
    
    if alpha != oldAlpha {
        search.principle_variations[board.hashValue] = bestMove
    }
    
    return alpha
}

func AlphaBeta(var board:Board, depth:Int, var alpha:Int, beta:Int) -> Int {

    if depth == 0 {
       return Quiescence(board, alpha: alpha, beta: beta)
    }
    
    var moves = generateMoves(board)
    
    //Search the Principle Variation first by assigning high score
    if let pvMove = search.principle_variations[board.hashValue] {
        for (i, move) in moves.enumerate() {
            if move == pvMove.move {
                moves[i].score = 2000000
            }
        }
    }
    
    //Sort moves by move ordering heuristic score
    let sortedMoves = moves.sort({ $0.score > $1.score })
    
    var legalMoveCount = 0
    var bestMove = ScoredMove(score: 0, move: Move())
    let oldAlpha = alpha
    
    for move in sortedMoves {
  
        let undo = doMove(&board, move: move)
        
        if !board.isLegal() {
            undoMove(&board, undo: undo)
            continue
        }
        
        legalMoveCount++

        let score = -AlphaBeta(board, depth: depth - 1, alpha: -beta, beta: -alpha)
        
        undoMove(&board, undo: undo)
        if (score > alpha) {
            if (score >= beta) {
                if legalMoveCount == 1 { search.fail_high_first++ }
                search.fail_high++
                
                if !isCapture(board, move: move) {
                    search.killerTwo[board.SearchPly] = search.killerOne[board.SearchPly]
                    search.killerOne[board.SearchPly] = move
                }
                return beta;
            }
      
            if !isCapture(board, move: move) {
                if (search.history[board[move.from.rawValue]] != nil) {
                    search.history[board[move.from.rawValue]]![move.to.rawValue]? += depth
                } else {
                    search.history[board[move.from.rawValue]] = [move.to.rawValue: depth]
                }
            }
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
        search.principle_variations[board.hashValue] = bestMove
    }
    return alpha
    
}
