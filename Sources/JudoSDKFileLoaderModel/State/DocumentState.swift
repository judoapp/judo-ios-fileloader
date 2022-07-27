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

import Combine
import SwiftUI

/// The `DocumentState` object encompasses all the values that belong to the document.
public final class DocumentState: Decodable {
    public enum Appearance: String, Decodable {
        case light
        case dark
        case auto
    }
    
    public var screens = [Screen]()
    public var initialScreen: Screen?
    public var segues = [Segue]()
    public var colors = [DocumentColor]()
    public var gradients = [DocumentGradient]()
    public var localization = StringTable()
    public var fonts = [DocumentFont]()
    public var mediaURLs = [URL]()
    public var fontURLs = [URL]()
    public var appearance = Appearance.auto
    
    public var urlParameters = UserInfo()
    public var userInfo = UserInfo()
    public var authorizers = [Authorizer]()

    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case nodes
        case screenIDs
        case initialScreenID
        case segues
        case colors
        case gradients
        case fonts
        case mediaURLs
        case fontURLs
        case appearance
        case urlParameters
        case userInfo
        case authorizers
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        segues = try container.decode([Segue].self, forKey: .segues)
        colors = try container.decode([DocumentColor].self, forKey: .colors)
        gradients = try container.decode([DocumentGradient].self, forKey: .gradients)
        fonts = try container.decode([DocumentFont].self, forKey: .fonts)
        localization = coordinator.stringTable
        mediaURLs = Array(coordinator.mediaURLs)
        fontURLs = Array(coordinator.fontURLs)
        appearance = try container.decode(Appearance.self, forKey: .appearance)
        
        if coordinator.documentVersion >= 7 {
            urlParameters = try container.decode(UserInfo.self, forKey: .urlParameters)
        }
        
        userInfo = try container.decode(UserInfo.self, forKey: .userInfo)
        
        if coordinator.documentVersion >= 8 {
            authorizers = try container.decode([Authorizer].self, forKey: .authorizers)
        }
        
        coordinator.registerOneToManyRelationship(
            nodeIDs: try container.decode([Node.ID].self, forKey: .screenIDs),
            to: self,
            keyPath: \.screens
        )
        
        if container.contains(.initialScreenID) {
            coordinator.registerOneToOneRelationship(
                nodeID: try container.decode(Node.ID.self, forKey: .initialScreenID),
                to: self,
                keyPath: \.initialScreen
            )
        }
        
        let nodes = try container.decodeNodes(forKey: .nodes)
        try coordinator.resolveRelationships(nodes: nodes, documentColors: colors, documentGradients: gradients)
    }
}
