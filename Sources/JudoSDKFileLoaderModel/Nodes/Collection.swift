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

public final class Collection: Layer {
    public struct Limit: Decodable {
        public var show: Int
        public var startAt: Int
    }
    
    public var keyPath: String
    public var filters: [Condition]
    public var sortDescriptors: [SortDescriptor]
    public var limit: Limit?
    
    // MARK: Decodable

    private enum CodingKeys: String, CodingKey {
        case keyPath
        case filters
        case sortDescriptors
        case limit
        case dataKey // Legacy
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        
        if coordinator.documentVersion >= 7 {
            keyPath = try container.decode(String.self, forKey: .keyPath)
        } else {
            let dataKey = try container.decode(String.self, forKey: .dataKey)
            keyPath = "data.\(dataKey)"
        }
        
        filters = try container.decode([Condition].self, forKey: .filters)
        sortDescriptors = try container.decode([SortDescriptor].self, forKey: .sortDescriptors)
        limit = try container.decodeIfPresent(Limit.self, forKey: .limit)
        try super.init(from: decoder)
    }
}
