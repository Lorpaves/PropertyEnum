//
//  DeclSyntaxMembersWrapper.swift
//
//
//  Created by 刘洁 on 2023/10/8.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
struct DeclType {
    var type: TokenSyntax
    var isOptional: Bool
    var rawType: String {
        var rawType: String = type.text
        if isOptional { rawType = rawType + "?" }
        return rawType
    }
}
struct DeclSyntaxMembersWrapper {
    
    let members: MemberBlockItemListSyntax
    
    var enumTitle: String = "Properties"
    private var attribues: [VariableDeclSyntax] {
        members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }
    
    /// The name of each property
    private var ids: [TokenSyntax] {
        attribues.compactMap { $0.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier }
    }
    
    /// The name of each settable property
    private var settableIDs: [TokenSyntax] {
        attribues.compactMap { decl -> TokenSyntax? in
            guard let binding = decl.bindings.first else { return nil }
            if let accessors = binding.accessorBlock?.accessors.as(AccessorDeclListSyntax.self ),
               accessors.first(where: { $0.accessorSpecifier.tokenKind == .keyword(.set) }) == nil {
              
                return nil
            }
            else if decl.bindingSpecifier.tokenKind == .keyword(.var) {
                return binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
            }
            return nil
        }
    }
    
    /// The type of each settable property
    private var settableTypes: [DeclType] {
        attribues.compactMap { decl -> DeclType? in
            guard let binding = decl.bindings.first else { return nil }
            if let accessors = binding.accessorBlock?.accessors.as(AccessorDeclListSyntax.self),
               accessors.first(where: { $0.accessorSpecifier.tokenKind == .keyword(.set) }) == nil {
              
                return nil
            }
            else if decl.bindingSpecifier.tokenKind == .keyword(.var) {
                if let noneOptinalType = binding.typeAnnotation?.type.as(IdentifierTypeSyntax.self) {
                    return DeclType(type: noneOptinalType.name, isOptional: false)
                }
                else if let optionalType = binding.typeAnnotation?.type.as(OptionalTypeSyntax.self) {
                    if let typeLiteral = optionalType.wrappedType.as(IdentifierTypeSyntax.self)?.name {
                        return DeclType(type: typeLiteral, isOptional: true)
                    }
                }
            }
            return nil
        }
    }
    
    func propetiesEnumDecl() throws -> EnumDeclSyntax {
        try EnumDeclSyntax("enum \(raw: enumTitle): CaseIterable") {
            for id in ids {
                try EnumCaseDeclSyntax("case \(id)")
            }
        }
    }
    
    func subscriptGetSwitchExprSyntax() throws -> SwitchExprSyntax {
        try SwitchExprSyntax("switch property") {
            for id in ids {
                SwitchCaseSyntax(
                                """
                                
                                case .\(id): return self.\(id)
                                
                                """
                )
            }
            
        }
    }
    func subscriptSetSwitchExprSyntax() throws -> SwitchExprSyntax {
        
        return try SwitchExprSyntax("switch property") {
            for (id, type) in zip(settableIDs, settableTypes) {
                
                let guardDecl = try GuardStmtSyntax("guard let newValue = newValue as? \(raw: type.rawType), self.\(id) != newValue else") {
                    ReturnStmtSyntax()
                }
                SwitchCaseSyntax(
                    """
                    
                    case .\(id):
                        \(guardDecl)
                        self.\(id) = newValue
                    
                    """
                )
            }
            SwitchCaseSyntax(
                """
                
                default: break
                
                """
            )
        }
    }
    func subscriptDelcSyntax() throws -> SubscriptDeclSyntax {
        let getSwitchExprSyntax = try subscriptGetSwitchExprSyntax()
        let setSwitchExprSyntax = try subscriptSetSwitchExprSyntax()
        return try SubscriptDeclSyntax(
                    """
                    subscript(property: \(raw: enumTitle)) -> Any? {
                    
                        get {
                            \(getSwitchExprSyntax)
                        }
                    
                        set {
                            \(setSwitchExprSyntax)
                        }
                        
                    }
                    """
        )
    }
}
