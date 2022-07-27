// Copyright (c) 2020-present, Rover Labs, Inc. All rights reserved.
// You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
// copy, modify, and distribute this software in source code or binary form for use
// in connection with the web services and APIs provided by Rover.
//
// This copyright notice shall be included in all copies or substantial portions of
// the software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CoreGraphics
import SwiftUI

public enum Font: Hashable {

    public enum Emphasis: String, Hashable, Decodable {
        case bold
        case italic
    }

    /// A system font with a given semantic style that responds to the Dynamic Type system on iOS and the equivalent on Android.
    case dynamic(textStyle: SwiftUI.Font.TextStyle, emphases: Set<Font.Emphasis>)
    
    /// A system font with a fixed size and weight.
    case fixed(size: CGFloat, weight: SwiftUI.Font.Weight)
    
    /// A font which uses the `CustomFont` value from a `DocumentFont` matching the `fontFamily` and `textStyle`.
    case document(fontFamily: FontFamily, textStyle: SwiftUI.Font.TextStyle)
    
    /// A custom font which uses the supplied `FontName` and given `size`.
    case custom(fontName: FontName, size: CGFloat)
}

// MARK: Codable

extension Font: Decodable {
    private enum CodingKeys: String, CodingKey {
        case caseName = "__caseName"
        case textStyle
        case emphases
        case size
        case weight
        case fontFamily
        case fontName
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let caseName = try container.decode(String.self, forKey: .caseName)
        switch caseName {
        case "dynamic":
            let textStyle = try container.decode(SwiftUI.Font.TextStyle.self, forKey: .textStyle)
            let emphases = try container.decode(Set<Font.Emphasis>.self, forKey: .emphases)
            self = .dynamic(textStyle: textStyle, emphases: emphases)
        case "fixed":
            let size = try container.decode(CGFloat.self, forKey: .size)
            let weight = try container.decode(SwiftUI.Font.Weight.self, forKey: .weight)
            self = .fixed(size: size, weight: weight)
        case "document":
            let fontFamily = try container.decode(FontFamily.self, forKey: .fontFamily)
            let textStyle = try container.decode(SwiftUI.Font.TextStyle.self, forKey: .textStyle)
            self = .document(fontFamily: fontFamily, textStyle: textStyle)
        case "custom":
            let fontName = try container.decode(FontName.self, forKey: .fontName)
            let size = try container.decode(CGFloat.self, forKey: .size)
            self = .custom(fontName: fontName, size: size)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .caseName,
                in: container,
                debugDescription: "Invalid value: \(caseName)"
            )
        }
    }
}

// MARK: FontFamily

public typealias FontFamily = String

extension FontFamily {
    public static var all: [FontFamily] {
        CTFontManagerCopyAvailableFontFamilyNames() as? [String] ?? []
    }
    
    public var names: [FontName] {
        let fontFamilyDescriptor = CTFontDescriptorCreateWithAttributes(
            [kCTFontFamilyNameAttribute: self as CFString] as CFDictionary
        )
        
        let fontCollection = CTFontCollectionCreateWithFontDescriptors(
            [fontFamilyDescriptor] as CFArray, nil
        )
        
        let fontDescriptors = CTFontCollectionCreateMatchingFontDescriptors(fontCollection) as? [CTFontDescriptor] ?? []
        
        return fontDescriptors.compactMap {
            CTFontDescriptorCopyAttribute($0, kCTFontNameAttribute) as? String
        }
    }
}

// MARK: FontName

public typealias FontName = String

extension FontName {
    public var weight: SwiftUI.Font.Weight {
        guard let traits = CTFontCopyTraits(font) as? [String: Any],
              let weightTrait = traits[kCTFontWeightTrait as String] as? NSNumber,
              let weightValue = CGFloat(exactly: weightTrait) else {
            assertionFailure("Failed to calculate weight of font with name: \(self)")
            return .regular
        }
        
        // font weight_map from https://chromium.googlesource.com/chromium/src/+/master/ui/gfx/platform_font_mac.mm#99
        switch weightValue {
        case -1.0 ... -0.70:
            return .ultraLight
        case -0.70 ... -0.45:
            return .thin
        case -0.45 ... -0.10:
            return .light
        case -0.10 ... 0.10:
            return .regular
        case 0.10 ... 0.27:
            return .medium
        case 0.27 ... 0.35:
            return .semibold
        case 0.35 ... 0.50:
            return .bold
        case 0.50 ... 0.60:
            return .heavy
        case 0.60 ... 1.0:
            return .black
        default:
            return .regular
        }
    }
    
    public var family: FontFamily {
        CTFontCopyFamilyName(font) as String
    }
    
    public var styleName: String {
        CTFontCopyAttribute(font, kCTFontStyleNameAttribute) as? String ?? self
    }
    
    private var font: CTFont {
        CTFontCreateWithNameAndOptions(self as CFString, 0, nil, [.preventAutoActivation])
    }
}
