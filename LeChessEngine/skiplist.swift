//
//  skiplist.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 16/02/2016.
//  Copyright © 2016 JasperVine. All rights reserved.
//

import Foundation

class SkipListEntry<T:Comparable>
{
    var next:[SkipListEntry<T>?]
    var value:T?
    
    init(value:T?, level:Int)
    {
        self.value = value
        self.next = [SkipListEntry<T>?](count: level, repeatedValue: nil)
    }
}

struct SkipList<T:Comparable> {
    typealias Node = SkipListEntry<T>
    var head:Node = Node(value: nil, level: 33)
    var size:Int = 0
    var levels:Int = 1
    
    init () {
        head = Node(value: nil, level: 33)
        size = 0
        levels = 1
    }
    
    mutating func append(value:T) {
        
        var level:Int = 0
        var randomNum = random()
        
        while randomNum & 1 == 1 {
            randomNum >>= 1
            level++
            if (level == self.levels) {
                self.levels++
                break
            }
        }
        
        // Insert this node into the skip list
        let newNode = Node(value: value, level: level + 1)
        var cur = self.head
        for i in (0...(levels - 1)).reverse()
        {
            while cur.next[i] != nil
            {
                if (cur.next[i]!.value > value) { break }
                cur = cur.next[i]!
            }
            
            if (i <= level) {
                newNode.next[i] = cur.next[i]
                cur.next[i] = newNode
            }
        }
        self.size++
    }
    
    func contains(value:T) -> Bool {
        var cur = self.head
        for i in  (0...(self.levels - 1)).reverse() {
            while cur.next[i] != nil {
                if cur.next[i]!.value > value { break }
                if cur.next[i]!.value == value { return true }
                cur = cur.next[i]!
            }
        }
        return false;
    }
    
    mutating func remove(value:T) -> Bool {
        var cur = self.head
        
        var found = false
        for i in  (0...(self.levels - 1)).reverse() {
            while cur.next[i] != nil {
                if cur.next[i]!.value == value
                {
                    found = true
                    cur.next[i] = cur.next[i]!.next[i]!
                    self.size--
                    break
                }
                if cur.next[i]!.value > value { break }
                cur = cur.next[i]!
            }
        }
        
        return found
    }
    
    mutating func appendContentsOf(list: SkipList<T>) -> SkipList<T> {
        for entry in list {
            self.append(entry)
        }
        return self
    }
    
    
}

extension SkipList : CustomStringConvertible {
    
    var description:String {
        var retVal = "["
        for entry in self {
            retVal += " \(entry), "
        }
        retVal += "]"
        return retVal
    }
}

extension SkipList : SequenceType {
    
    func generate() -> SkipListGenerator<T> {
        return SkipListGenerator<T>(head: self.head)
    }
}

class SkipListGenerator<T: Comparable>: GeneratorType {
    // Hold the collection to be iterated through
    typealias Node = SkipListEntry<T>
    private var current:Node?
    
    // Initialize the generator, passing a reference
    // to the car array
    init(head:Node) {
        self.current = head
    }
    
    // Implement the next method, to return nil if
    // there are no more cars, or the next Car.
    // Note that we have specified the return type
    // as an optional "car": Car?.
    func next() -> T? {
        
        if let c = self.current, let nxt = c.next[0] {
            self.current = nxt
        } else {
            self.current = nil
        }
        if let ret = self.current {
            return ret.value
        } else {
            return nil
        }
    }
}