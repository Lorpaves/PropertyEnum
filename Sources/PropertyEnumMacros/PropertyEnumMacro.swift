import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct PropertySubscriptMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        
        var members: MemberBlockItemListSyntax? = nil
        
        if let structDecl = declaration.as(StructDeclSyntax.self)  {
            members = structDecl.memberBlock.members
        }
        else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            members = classDecl.memberBlock.members
        }
        
        guard let members = members else { throw SlopeSubsetError.onlyApplicableToStructOrClass }
        
        let memberWrapper = DeclSyntaxMembersWrapper(members: members)
        
        let propertiesEnumDecl = try memberWrapper.propetiesEnumDecl()
        
        let subscriptDeclSyntax = try memberWrapper.subscriptDelcSyntax()
        
        return [DeclSyntax(propertiesEnumDecl), DeclSyntax(subscriptDeclSyntax)]
        
    }
}
public struct PropertySubscriptProtocolMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let protocolDecl = declaration.as(ProtocolDeclSyntax.self) else { throw SlopeSubsetError.onlyApplicableToProtocol }
        let members = protocolDecl.memberBlock.members
        
        let name = protocolDecl.name
       
        let memberWrapper = DeclSyntaxMembersWrapper(members: members, enumTitle: "\(name.text)Properties")
        
        let propertiesEnumDeclSyntax = try memberWrapper.propetiesEnumDecl()
        let subscriptDeclSyntax = try memberWrapper.subscriptDelcSyntax()
        let extensionDeclSyntax = try ExtensionDeclSyntax("extension \(raw: name.text)") {
            subscriptDeclSyntax
        }
        
        return [DeclSyntax(propertiesEnumDeclSyntax), DeclSyntax(extensionDeclSyntax)]
    }
}

public struct PropertyIgnoreMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
//        guard declaration.as(Iden)
        return []
    }
}
@main
struct PropertyEnumPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PropertySubscriptMacro.self,
        PropertySubscriptProtocolMacro.self,
        PropertyIgnoreMacro.self
    ]
}
