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

public final class Image: Layer {
    public enum ResizingMode: String, Decodable {
        case originalSize
        case scaleToFit
        case scaleToFill
        case tile
        case stretch
    }

    public struct Source: Decodable, Hashable {
        /// A streamable media source available through the network.
        public let url: String?
        public let image: ImageValue?

        private enum CodingKeys: String, CodingKey {
            case caseName = "__caseName"
            case assetName
            case url
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator

            let caseName = try container.decode(String.self, forKey: .caseName)
            switch caseName {
            case "fromFile":
                let fileName = try container.decode(String.self, forKey: .assetName)
                guard let imageValue = coordinator.imageByFilename(fileName) else {
                    fatalError("Unknown media file")
                }
                self.image = imageValue
                self.url = nil
            case "fromURL":
                self.url = try container.decode(String.self, forKey: .url)
                self.image = nil
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .caseName,
                    in: container,
                    debugDescription: "Invalid value: \(caseName)"
                )
            }
        }
    }
    
    public var source: Source
    public var darkModeSource: Source?
    public var resolution: CGFloat
    public var resizingMode: ResizingMode
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case source
        case darkModeSource
        case resolution
        case resizingMode
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.source = try container.decode(Source.self, forKey: .source)
        self.darkModeSource = try container.decodeIfPresent(Source.self, forKey: .darkModeSource)
        
        resolution = try container.decode(CGFloat.self, forKey: .resolution)
        resizingMode = try container.decode(ResizingMode.self, forKey: .resizingMode)
        try super.init(from: decoder)
    }
}
