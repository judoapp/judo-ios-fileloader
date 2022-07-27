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

import SwiftUI
import os.log

// MARK: Axis

extension Axis: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value {
        case "horizontal":
            self = .horizontal
        case "vertical":
            self = .vertical
        default:
            self = .vertical
            assertionFailure("Unsupported axis: \(value)")
        }
    }
}

// MARK: TextAlignment

extension TextAlignment: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value {
        case "center":
            self = .center
        case "leading":
            self = .leading
        case "trailing":
            self = .trailing
        default:
            self = .center
            assertionFailure("Unsupported text alignment: \(value)")
        }
    }
}

// MARK: HorizontalAlignment

extension HorizontalAlignment: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "center":
            self = .center
        case "leading":
            self = .leading
        case "trailing":
            self = .trailing
        default:
            assertionFailure("Unsupported horizontal alignment: \(rawValue)")
            self = .center
        }
    }
}

// MARK: VerticalAlignment

extension VerticalAlignment: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "bottom":
            self = .bottom
        case "center":
            self = .center
        case "baseline":
            self = .firstTextBaseline
        case "top":
            self = .top
        default:
            assertionFailure("Unsupported vertical alignment: \(rawValue)")
            self = .bottom
        }
    }
}

// MARK: Alignment

extension Alignment: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "bottom":
            self = .bottom
        case "bottomLeading":
            self = .bottomLeading
        case "bottomTrailing":
            self = .bottomTrailing
        case "center":
            self = .center
        case "leading":
            self = .leading
        case "top":
            self = .top
        case "topLeading":
            self = .topLeading
        case "topTrailing":
            self = .topTrailing
        case "trailing":
            self = .trailing
        default:
            assertionFailure("Unsupported alignment: \(rawValue)")
            self = .center
        }
    }
}

// MARK: Edge

extension Edge: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value {
        case "top":
            self = .top
        case "leading":
            self = .leading
        case "bottom":
            self = .bottom
        case "trailing":
            self = .trailing
        default:
            self = .leading
            assertionFailure("Unsupported edge: \(rawValue)")
        }
    }
}

// MARK: SwiftUI.Font.TextStyle

extension SwiftUI.Font.TextStyle: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        switch value {
        case "largeTitle":
            self = .largeTitle
        case "title":
            self = .title
        case "title2":
            if #available(iOS 14.0, *) {
                self = .title2
            } else {
                self = .title
            }
        case "title3":
            if #available(iOS 14.0, *) {
                self = .title3
            } else {
                self = .title
            }
        case "headline":
            self = .headline
        case "body":
            self = .body
        case "callout":
            self = .callout
        case "subheadline":
            self = .subheadline
        case "footnote":
            self = .footnote
        case "caption":
            self = .caption
        case "caption2":
            if #available(iOS 14.0, *) {
                self = .caption2
            } else {
                self = .caption
            }
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid value: \(value.self)"
            )
        }
    }
}

// MARK: SwiftUI.Font.Weight

extension SwiftUI.Font.Weight: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        switch value {
        case "ultraLight":
            self = .ultraLight
        case "thin":
            self = .thin
        case "light":
            self = .light
        case "regular":
            self = .regular
        case "medium":
            self = .medium
        case "semibold":
            self = .semibold
        case "bold":
            self = .bold
        case "heavy":
            self = .heavy
        case "black":
            self = .black
        default:
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid value: \(value.self)"
            )
        }
    }
}
