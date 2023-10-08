import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(PropertyEnumMacros)
import PropertyEnumMacros

let testMacros: [String: Macro.Type] = [
    "PropertySC": PropertySubscriptMacro.self,
    "PropertyP": PropertySubscriptProtocolMacro.self
]
#endif

final class PropertyEnumTests: XCTestCase {
    func test1() {
        assertMacroExpansion(
"""
@PropertySC
class Cat {
     let bleed: String? = nil
     var name: String = "Snow"
     let age: Int = 1
     var isIndoorCat: Bool? = true
}
""",
expandedSource: """

class Cat {
     let bleed: String? = nil
     var name: String = "Snow"
     let age: Int = 1
     var isIndoorCat: Bool? = true

    enum Properties: CaseIterable {
        case bleed
        case name
        case age
        case isIndoorCat
    }

    subscript(property: Properties) -> Any? {

        get {
            switch property {
            case .bleed:
                return self.bleed
            case .name:
                return self.name
            case .age:
                return self.age
            case .isIndoorCat:
                return self.isIndoorCat
            }
        }

        set {
            switch property {
            case .name:
                guard let newValue = newValue as? String, self.name != newValue else {
                    return
                }
                self.name = newValue
            case .isIndoorCat:
                guard let newValue = newValue as? Bool?, self.isIndoorCat != newValue else {
                    return
                }
                self.isIndoorCat = newValue
            default:
                break
            }
        }

    }
}
""",
macros: testMacros
        )
    }
    func test2() {
        assertMacroExpansion(
"""
@PropertyP
protocol Pet {
    var name: String { get set }
    var bleed: String? { get }
}
""",
expandedSource: """
protocol Pet {
    var name: String { get set }
    var bleed: String? { get }
}

enum PetProperties: CaseIterable {
    case name
    case bleed
}

extension Pet {
    subscript(property: PetProperties) -> Any? {

        get {
            switch property {
            case .name:
                return self.name
            case .bleed:
                return self.bleed
            }
        }

        set {
            switch property {
            case .name:
                guard let newValue = newValue as? String, self.name != newValue else {
                    return
                }
                self.name = newValue
            default:
                break
            }
        }

    }
}
""",
macros: testMacros
        )
    }
}
