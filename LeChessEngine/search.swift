//
//  search.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 23/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

func AlphaBeta(var board:Board, depth:Int, var alpha:Int, beta:Int) -> Int {
    
    if !board.isLegal() { return 0 }
        
    if depth == 0 { return evaluate(board) }
    
    let moves = generateMoves(board)
    
    for move in moves {
        
        let undo = doMove(&board, move: move)
        
        let val = -AlphaBeta(board, depth: depth - 1, alpha: -beta, beta: -alpha)
        
        undoMove(&board, undo: undo)
        
        if (val >= beta) { return beta }
        
        if (val > alpha) { alpha = val }
        
    }
    
    return alpha
    
}


func evaluate(board:Board) -> Int {
    
    // Pure Material evaluation for now
    let Whitepawns = msb(board.White.Pawns);
    let Whiteknights = msb(board.White.Knights);
    let Whitebishops = msb(board.White.Bishops);
    let Whiterooks = msb(board.White.Rooks);
    let Whitequeens = msb(board.White.Queens);
    let Whitetotalmat = 3 * Whiteknights + 3 * Whitebishops + 5 * Whiterooks + 10 * Whitequeens;
    let Whitetotal = Whitepawns + Whiteknights + Whitebishops + Whiterooks + Whitequeens;
    let blackpawns = msb(board.Black.Pawns);
    let blackknights = msb(board.Black.Knights);
    let blackbishops = msb(board.Black.Bishops);
    let blackrooks = msb(board.Black.Rooks);
    let blackqueens = msb(board.Black.Queens);
    let blacktotalmat = 3 * blackknights + 3 * blackbishops + 5 * blackrooks + 10 * blackqueens;
    let blacktotal = blackpawns + blackknights + blackbishops + blackrooks + blackqueens;
    
    return (Whitetotalmat + Whitetotal) - (blacktotalmat + blacktotal)
}