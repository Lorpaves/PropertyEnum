//
//  VariableDeclSyntax + Extension.swift
//
//
//  Created by Lorpaves on 2023/10/10.
//

import Foundation
import SwiftSyntax

extension VariableDeclSyntax {
    var ignored: Bool {
        attributes
        .compactMap {
            $0.as(AttributeSyntax.self)?
                .attributeName
                .as(IdentifierTypeSyntax.self)?
                .name
                .tokenKind == .identifier("ignore")
        }
        .count > 0
    }
}
