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

public class Screen: Node {
    public var statusBarStyle: StatusBarStyle
    public var backButtonStyle: BackButtonStyle
    public var backgroundColor: ColorReference
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case statusBarStyle
        case backButtonStyle
        case backgroundColor
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        statusBarStyle = try container.decode(StatusBarStyle.self, forKey: .statusBarStyle)
        backButtonStyle = try container.decode(BackButtonStyle.self, forKey: .backButtonStyle)
        backgroundColor = try container.decode(ColorReference.self, forKey: .backgroundColor)
        try super.init(from: decoder)
    }
}
