//
//  DeclLiteralSyntax.swift
//  
//
//  Created by 刘洁 on 2023/10/9.
//

import SwiftSyntax
import Foundation

struct DeclLiteralSyntax {
    let type: TokenSyntax
    let name: TokenSyntax
    let isBinding: Bool
    
    var realType: TokenSyntax {
        if isBinding {
            do {
                let rawType = type.text
                let reg = try NSRegularExpression(pattern: #"Binding<(.+)>\??"#)
                let matches = reg.matches(in: rawType, range: NSMakeRange(0, rawType.count))
                for match in matches {
                    if match.numberOfRanges > 1 {
                        let machedRange = match.range(at: 1)
                        let machedType = (rawType as NSString).substring(with: machedRange)
                        return TokenSyntax("\(raw: machedType)")
                    }
                }
                
                
                
            } catch {
                
            }
            
        }
        return type
    }
}
