A macro is used to generate an enum containing all its properties for a struct or class, and access or modify its value through myClass[.property]

```swift
@PropertySC
class Cat {
     let bleed: String? = nil
     var name: String = "Snow"
     let age: Int = 1
     var isIndoorCat: Bool? = true
}
```

**Produces**

```swift
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

```

**Usage:**
```swift
let cat = Cat()
cat[.name] = "Snowball"
print(cat[.name] as! String)
for property in Cat.Properties.allCases {
    print(cat[property])
}
```

**OUTPUT:**

```bash    
Snowball
nil
Optional("Snowball")
Optional(1)
Optional(true)
```
