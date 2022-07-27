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

public class Segue: Decodable {
    public enum Style: Decodable {
        case push
        case modal(presentationStyle: ModalPresentationStyle)
        
        private enum CodingKeys: String, CodingKey {
            case caseName = "__caseName"
            case presentationStyle
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let caseName = try container.decode(String.self, forKey: .caseName)
            switch caseName {
            case "push":
                self  = .push
            case "modal":
                let presentationStyle = try container.decode(ModalPresentationStyle.self, forKey: .presentationStyle)
                self = .modal(presentationStyle: presentationStyle)
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .caseName,
                    in: container,
                    debugDescription: "Invalid value: \(caseName)"
                )
            }
        }
    }
    
    public var source: Node!
    public var destination: Screen!
    public var style: Style
    
    // MARK: Decodable
    
    private enum CodingKeys: String, CodingKey {
        case sourceID
        case destinationID
        case style
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        style = try container.decode(Style.self, forKey: .style)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        coordinator.registerOneToOneRelationship(
            nodeID: try container.decode(Node.ID.self, forKey: .sourceID),
            to: self,
            keyPath: \.source,
            inverseKeyPath: \.segue
        )
        
        coordinator.registerManyToOneRelationship(
            nodeID: try container.decode(Node.ID.self, forKey: .destinationID),
            to: self,
            keyPath: \.destination
        )
    }
}
