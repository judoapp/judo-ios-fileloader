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

public final class NavBar: Node {
    public enum TitleDisplayMode: String, Decodable {
        case inline
        case large
    }
    
    public struct Background: Decodable {
        public var fillColor: ColorReference
        public var shadowColor: ColorReference
        public var blurEffect: Bool
    }
    
    public struct Appearance: Decodable {
        public var titleColor: ColorReference
        public var buttonColor: ColorReference
        public var background: Background
    }
    
    public var title: String
    public var titleDisplayMode: TitleDisplayMode
    public var hidesBackButton: Bool
    public var titleFont: Font
    public var largeTitleFont: Font
    public var buttonFont: Font
    public var appearance: Appearance
    public var alternateAppearance: Appearance?
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case title
        case titleDisplayMode
        case hidesBackButton
        case titleFont
        case largeTitleFont
        case buttonFont
        case appearance
        case alternateAppearance
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        titleDisplayMode = try container.decode(TitleDisplayMode.self, forKey: .titleDisplayMode)
        hidesBackButton = try container.decode(Bool.self, forKey: .hidesBackButton)
        titleFont = try container.decode(Font.self, forKey: .titleFont)
        largeTitleFont = try container.decode(Font.self, forKey: .largeTitleFont)
        buttonFont = try container.decode(Font.self, forKey: .buttonFont)
        appearance = try container.decode(Appearance.self, forKey: .appearance)
        alternateAppearance = try container.decodeIfPresent(Appearance.self, forKey: .alternateAppearance)
        try super.init(from: decoder)
    }
}
