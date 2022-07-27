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

import CoreGraphics
import SwiftUI

public final class Text: Layer {
    public enum Transform: String, Codable {
        case uppercase
        case lowercase
    }
    
    public var text: String
    public var font: Font
    public var textColor: ColorReference
    public var textAlignment: TextAlignment
    public var lineLimit: Int?
    public var transform: Transform?
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case text
        case font
        case textColor
        case textAlignment
        case lineLimit
        case transform
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        font = try container.decode(Font.self, forKey: .font)
        textColor = try container.decode(ColorReference.self, forKey: .textColor)
        textAlignment = try container.decode(TextAlignment.self, forKey: .textAlignment)
        lineLimit = try container.decodeIfPresent(Int.self, forKey: .lineLimit)
        transform = try container.decodeIfPresent(Transform.self, forKey: .transform)
        try super.init(from: decoder)
    }
}
