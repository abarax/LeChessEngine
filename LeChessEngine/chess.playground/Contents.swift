//: Playground - noun: a place where people can play

import Cocoa

let num = 32424234

num ^ 0

let delta: UInt64 = 9307608754918809270
let result: Int64 = Int64(bitPattern: delta)

let r:Int = Int(result)


print(String(0x0101010101010101, radix:2 ))
               
print(String(0b11001100110011001100110011001100110011001100110011001100110011, radix: 16))


var i:UInt64 = 1024
i = i - ((i >> 1) & 0x5555555555555555)
i = (i & 0x3333333333333333) + ((i >> 2) & 0x3333333333333333)

i = ((i + (i >> UInt64(4))) & 0x0F0F0F0F0F0F0F0F) * 0x0101010101010101


i = (((i + (i >> UInt64(4))) & 0x0F0F0F0F0F0F0F0F) * 0x0101010101010101) >> UInt64(24)

var out = Int(
    Int64(
        bitPattern: i
        
    )
)



