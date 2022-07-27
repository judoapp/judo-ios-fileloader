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

public final class WebView: Layer {
    public enum Source {
        case url(String)
        case html(String)
    }
    
    public var source: Source
    public var isScrollEnabled: Bool
    
    // MARK: Codable

    private enum CodingKeys: String, CodingKey {
        case source
        case isScrollEnabled
        case url // Legacy
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        
        if coordinator.documentVersion >= 9 {
            source = try container.decode(Source.self, forKey: .source)
        } else {
            let url = try container.decode(String.self, forKey: .url)
            source = .url(url)
        }
        
        isScrollEnabled = try container.decode(Bool.self, forKey: .isScrollEnabled)
        try super.init(from: decoder)
    }
}

extension WebView.Source: Decodable {
    private enum CodingKeys: String, CodingKey {
        case caseName = "__caseName"
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let caseName = try container.decode(String.self, forKey: .caseName)
        let value = try container.decode(String.self, forKey: .value)
        switch caseName {
        case "url":
            self = .url(value)
        case "html":
            self = .html(value)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .caseName,
                in: container,
                debugDescription: "Invalid value: \(caseName)"
            )
        }
    }
}
