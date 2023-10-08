//
//  PropertyEnumError.swift
//
//
//  Created by 刘洁 on 2023/10/8.
//

import SwiftSyntax

enum SlopeSubsetError: CustomStringConvertible, Error {
    case onlyApplicableToStructOrClass
    case onlyApplicableToProtocol
    var description: String {
        switch self {
        case .onlyApplicableToStructOrClass:
            return "@EnumSubset can only be applied to a struct or a class."
        case .onlyApplicableToProtocol:
            return "@EnumSubset can only be applied to a protocol."
        }
    }
}
