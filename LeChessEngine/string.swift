//
//  string.swift
//  LeChessEngine
//
//  Created by Leigh Appel on 5/12/2015.
//  Copyright © 2015 JasperVine. All rights reserved.
//

import Foundation

extension String
{
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func contains(s: String) -> Bool
    {
        return (self.rangeOfString(s) != nil) ? true : false
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    subscript (i: Int) -> Character
        {
        get {
            let index = startIndex.advancedBy(i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String
        {
        get {
            let start = startIndex.advancedBy(r.startIndex)
            let end = startIndex.advancedBy(r.endIndex - 1)
            
            return self[Range(start: start, end: end)]
        }
    }
    
    func subString(index: Int, length: Int) -> String
    {
        let start = startIndex.advancedBy(index)
        let end = start.advancedBy(length)
        return self.substringWithRange(Range<String.Index>(start: start, end: end))
    }
    
    func indexOf(target: String) -> Int
    {
        let range = self.rangeOfString(target)
        if let range = range {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    func indexOf(target: String, start: Int) -> Int
    {
        let startRange = startIndex.advancedBy(start)
        
        let range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(start: startRange, end: self.endIndex))
        
        if let range = range {
            return self.startIndex.distanceTo(range.startIndex)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(target: String) -> Int
    {
        var index = -1
        var stepIndex = self.indexOf(target)
        while stepIndex > -1
        {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target, start: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    
    func matches(pattern : String)->Bool{
        
        let regex = try? NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators)
        
        if (regex != nil){
            let matchCount = regex!.numberOfMatchesInString(self, options: NSMatchingOptions(), range: NSMakeRange(0, self.length))
            
            return matchCount > 0
        }
        return false
    }
    
}