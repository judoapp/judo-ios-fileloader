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

public struct DocumentFont: Decodable {
    public struct CustomFont: Decodable {
        public var fontName: FontName
        public var size: CGFloat
    }
    
    public var fontFamily: FontFamily
    public var largeTitle: CustomFont
    public var title: CustomFont
    public var title2: CustomFont
    public var title3: CustomFont
    public var headline: CustomFont
    public var body: CustomFont
    public var callout: CustomFont
    public var subheadline: CustomFont
    public var footnote: CustomFont
    public var caption: CustomFont
    public var caption2: CustomFont
}
