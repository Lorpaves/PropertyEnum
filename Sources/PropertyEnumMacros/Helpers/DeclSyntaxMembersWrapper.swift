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
    
    /// The type of each settable property
    private var settableTypes: [DeclLiteralSyntax] {
        attribues.compactMap { decl -> DeclLiteralSyntax? in
            guard let binding = decl.bindings.first else { return nil }
            
            if let accessors = binding.accessorBlock?.accessors.as(AccessorDeclListSyntax.self),
               accessors.first(where: { $0.accessorSpecifier.tokenKind == .keyword(.set) }) == nil {
              
                return nil
            }
            else if decl.bindingSpecifier.tokenKind == .keyword(.var) {
                guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,  let type = getCustomTypeLiteral(annotation: binding.typeAnnotation!) else { return nil }
               
                return DeclLiteralSyntax(type: type, name: name)
               
            }
            return nil
        }
    }
     func getCustomTypeLiteral(annotation: some SyntaxProtocol) -> TokenSyntax? {
         guard let annotation = annotation.as(TypeAnnotationSyntax.self) else { return nil }
         let typeSyntax = annotation.type
         switch typeSyntax.kind {
         case .arrayType:
             if let identifierTypeSyntax = typeSyntax.as(ArrayTypeSyntax.self) { return TokenSyntax("\(raw: identifierTypeSyntax.description)") }
         case .tupleType:
             if let identifierTypeSyntax = typeSyntax.as(TupleTypeSyntax.self) { return TokenSyntax("\(raw: identifierTypeSyntax.description)") }
         case .memberType:
             if let identifierTypeSyntax = typeSyntax.as(MemberTypeSyntax.self) { return TokenSyntax("\(raw: identifierTypeSyntax.description)") }
         case .optionalType:
             if let identifierTypeSyntax = typeSyntax.as(OptionalTypeSyntax.self) { return TokenSyntax("\(raw: identifierTypeSyntax.description)") }
         case .dictionaryType:
             if let identifierTypeSyntax = typeSyntax.as(DictionaryTypeSyntax.self) { return TokenSyntax("\(raw: identifierTypeSyntax.description)") }
         case .identifierType:
             if let identifierTypeSyntax = typeSyntax.as(IdentifierTypeSyntax.self) { return TokenSyntax("\(raw: identifierTypeSyntax.description)") }
         default: return nil
         }


return nil
         
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
        let needDefaultBreak = settableTypes.count != self.ids.count
        return try SwitchExprSyntax("switch property") {
            for type in  settableTypes {
                
                let guardDecl = try GuardStmtSyntax("guard let newValue = newValue as? \(type.type), self.\(type.name) != newValue else") {
                    ReturnStmtSyntax()
                }
                SwitchCaseSyntax(
                    """
                    
                    case .\(type.name):
                        \(guardDecl)
                        self.\(type.name) = newValue
                    
                    """
                )
            }
            if needDefaultBreak {
                SwitchCaseSyntax(
                    """
                    
                    default: break
                    
                    """
                )
            }
            
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
