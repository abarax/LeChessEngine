//: Playground - noun: a place where people can play

import Cocoa


struct Move {
    var name:String = "asdf"
    var score:Int = 0
}

func add(m:Move,var list:[Move]) {
    list.append(m)
}

var moves:[Move] = [Move(name: "ewoij", score: 324), Move(name: "awkler", score: 1323)]

for (i, move) in moves.enumerate() {
    if move.name == "ewoij" {
        moves[i].score = 22222222
    }
}

add(Move(name: "test", score: 2), list: moves)

print(moves)



