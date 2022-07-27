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

public struct Frame {
    public enum FrameType {
        case fixed
        case constrained
    }
    
    public var frameType: FrameType {
        willSet {
            if frameType != newValue {
                switch newValue {
                case .constrained:
                    if width != nil {
                        width = nil
                    }
                    
                    if height != nil {
                        height = nil
                    }
                case .fixed:
                    if minWidth != nil {
                        minWidth = nil
                    }
                    
                    if maxWidth != nil {
                        maxWidth = nil
                    }
                    
                    if minHeight != nil {
                        minHeight = nil
                    }
                    
                    if maxHeight != nil {
                        maxHeight = nil
                    }
                }
            }
        }
    }
    
    public var width: CGFloat? {
        willSet {
            frameType = .fixed
        }
    }
    
    public var minWidth: CGFloat? {
        willSet {
            frameType = .constrained
        }
    }
    
    public var maxWidth: CGFloat? {
        willSet {
            frameType = .constrained
        }
    }
    
    public var height: CGFloat? {
        willSet {
            frameType = .fixed
        }
    }
    
    public var minHeight: CGFloat? {
        willSet {
            frameType = .constrained
        }
    }
    
    public var maxHeight: CGFloat? {
        willSet {
            frameType = .constrained
        }
    }
    
    public var alignment: Alignment
    
    public init(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) {
        self.frameType = .fixed
        self.width = width
        self.minWidth = nil
        self.maxWidth = nil
        self.height = height
        self.minHeight = nil
        self.maxHeight = nil
        self.alignment = alignment
    }
    
    public init(minWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, minHeight: CGFloat? = nil, maxHeight: CGFloat? = nil, alignment: Alignment = .center) {
        self.frameType = .constrained
        self.width = nil
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.height = nil
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.alignment = alignment
    }
}

extension Frame: Decodable {
    private enum CodingKeys: String, CodingKey {
        case width
        case minWidth
        case maxWidth
        case height
        case minHeight
        case maxHeight
        case alignment
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let width = try container.decodeIfPresent(CGFloat.self, forKey: .width)
        let minWidth = try container.decodeIfPresent(CGFloat.self, forKey: .minWidth)
        let maxWidth = try container.decodeIfPresent(CGFloat.self, forKey: .maxWidth)
        let height = try container.decodeIfPresent(CGFloat.self, forKey: .height)
        let minHeight = try container.decodeIfPresent(CGFloat.self, forKey: .minHeight)
        let maxHeight = try container.decodeIfPresent(CGFloat.self, forKey: .maxHeight)
        let alignment = try container.decodeIfPresent(Alignment.self, forKey: .alignment) ?? .center
        
        if minWidth != nil || maxWidth != nil || minHeight != nil || maxHeight != nil {
            self.init(
                minWidth: minWidth,
                maxWidth: maxWidth,
                minHeight: minHeight,
                maxHeight: maxHeight,
                alignment: alignment
            )
        } else {
            self.init(width: width, height: height, alignment: alignment)
        }
    }
}
