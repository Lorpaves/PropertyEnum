// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A macro is used to generate an enum containing all its properties
/// for a struct or class, and access or modify its value through myClass[.property]
///
///     @PropertySC
///     class Cat {
///         let bleed: String? = nil
///         var name: String = "Snow"
///         let age: Int = 1
///         var isIndoorCat: Bool? = true
///     }
///
/// produces
///
///     class Cat {
///         let bleed: String? = nil
///         var name: String = "Snow"
///         let age: Int = 1
///         var isIndoorCat: Bool? = true
///
///         enum Properties: CaseIterable {
///             case bleed
///             case name
///             case age
///             case isIndoorCat
///         }
///
///         subscript(property: Properties) -> Any? {
///
///             get {
///                 switch property {
///                 case .bleed:
///                     return self.bleed
///                 case .name:
///                     return self.name
///                 case .age:
///                     return self.age
///                 case .isIndoorCat:
///                     return self.isIndoorCat
///                 }
///             }
///
///             set {
///                 switch property {
///                 case .name:
///                     guard let newValue = newValue as? String, self.name != newValue else {
///                         return
///                     }
///                     self.name = newValue
///                 case .isIndoorCat:
///                     guard let newValue = newValue as? Bool?, self.isIndoorCat != newValue else {
///                         return
///                     }
///                     self.isIndoorCat = newValue
///                 default:
///                     break
///                 }
///             }
///
///         }
///     }
/// 
/// Usage:
///
///     let cat = Cat()
///     cat[.name] = "Snowball"
///     print(cat[.name] as! String)
///     for property in Cat.Properties.allCases {
///         print(cat[property])
///     }
///
///     OUTPUT:
///     --
///     Snowball
///     nil
///     Optional("Snowball")
///     Optional(1)
///     Optional(true)
///     --
@attached(member, names: arbitrary)
public macro PropertySC() = #externalMacro(module: "PropertyEnumMacros", type: "PropertySubscriptMacro")

@attached(member)
public macro ignore() = #externalMacro(module: "PropertyEnumMacros", type: "PropertyIgnoreMaacro")

/// Same as @PropertySC, but using the extension and generating a
/// top-level Properties enum.
///
///     @PropertyP
///     protocol Pet {
///         var name: String { get set }
///         var bleed: String? { get }
///     }
///
/// produces
///
///     protocol Pet {
///         var name: String { get set }
///         var bleed: String? { get }
///     }
///
///     enum PetProperties: CaseIterable {
///         case name
///         case bleed
///     }
///
///     extension Pet {
///         subscript(property: PetProperties) -> Any? {
///
///             get {
///                 switch property {
///                 case .name:
///                     return self.name
///                 case .bleed:
///                     return self.bleed
///                 }
///             }
///
///             set {
///                 switch property {
///                 case .name:
///                     guard let newValue = newValue as?
///                         return
///                     }
///                     self.name = newValue
///                 default:
///                     break
///                 }
///             }
///
///         }
///
@attached(peer)
public macro PropertyP() = #externalMacro(module: "PropertyEnumMacros", type: "PropertySubscriptProtocolMacro")
