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
import SwiftUI

public class Node: Decodable {
    public typealias ID = String
    public private(set) var id: ID
    
    public var name: String?
    public var parent: Node?
    public var children = [Node]()
    public var segue: Segue?
    
    // Layout
    public var ignoresSafeArea: Set<Edge>?
    public var aspectRatio: CGFloat?
    public var padding: Padding?
    public var frame: Frame?
    public var layoutPriority: Double?
    public var offset: CGPoint?
    
    // Appearance
    public var shadow: Shadow?
    public var opacity: Double?
    
    // Layering
    public var background: Background?
    public var overlay: Overlay?
    public var mask: Node?
    
    // Interaction
    public var action: Action?
    public var accessibility: Accessibility?
    public var metadata: Metadata?
    
    // MARK: Codable

    public static var typeName: String {
        String(describing: Self.self)
    }
    
    private enum CodingKeys: String, CodingKey {
        case typeName = "__typeName"
        case id
        case name
        case childIDs
        case isSelected
        case isCollapsed
        case ignoresSafeArea
        case aspectRatio
        case padding
        case frame
        case layoutPriority
        case offset
        case shadow
        case opacity
        case background
        case overlay
        case mask
        case action
        case accessibility
        case metadata
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Node.ID.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        
        let coordinator = decoder.userInfo[.decodingCoordinator] as! DecodingCoordinator
        
        // Layout
        ignoresSafeArea = try container.decodeIfPresent(Set<Edge>.self, forKey: .ignoresSafeArea)
        aspectRatio = try container.decodeIfPresent(CGFloat.self, forKey: .aspectRatio)
        padding = try container.decodeIfPresent(Padding.self, forKey: .padding)
        frame = try container.decodeIfPresent(Frame.self, forKey: .frame)
        layoutPriority = try container.decodeIfPresent(Double.self, forKey: .layoutPriority)
        offset = try container.decodeIfPresent(CGPoint.self, forKey: .offset)
        
        // Appearance
        shadow = try container.decodeIfPresent(Shadow.self, forKey: .shadow)
        opacity = try container.decodeIfPresent(Double.self, forKey: .opacity)
        
        // Layering
        background = try container.decodeIfPresent(Background.self, forKey: .background)
        overlay = try container.decodeIfPresent(Overlay.self, forKey: .overlay)
        mask = try container.decodeNodeIfPresent(forKey: .mask)
        
        // Interaction
        action = try container.decodeIfPresent(Action.self, forKey: .action)
        accessibility = try container.decodeIfPresent(Accessibility.self, forKey: .accessibility)
        metadata = try container.decodeIfPresent(Metadata.self, forKey: .metadata)
        
        coordinator.registerOneToManyRelationship(
            nodeIDs: try container.decode([Node.ID].self, forKey: .childIDs),
            to: self,
            keyPath: \.children,
            inverseKeyPath: \.parent
        )
    }
    
}


// MARK: Sequence

extension Sequence where Element: Node {
    /// Traverses the node graph, starting with the node's children, until it finds a node that matches the
    /// supplied predicate, from the top of the z-order.
    func highest(where predicate: (Node) -> Bool) -> Node? {
        reduce(nil) { result, node in
            guard result == nil else {
                return result
            }
            
            if predicate(node) {
                return node
            }
            
            return node.children.highest(where: predicate)
        }
    }
    
    /// Traverses the node graph, starting with the node's children, until it finds a node that matches the
    /// supplied predicate, from the bottom of the z-order.
    func lowest(where predicate: (Node) -> Bool) -> Node? {
        reversed().reduce(nil) { result, node in
            guard result == nil else {
                return result
            }
            
            if predicate(node) {
                return node
            }
            
            return node.children.lowest(where: predicate)
        }
    }
    
    func traverse(_ block: (Node) -> Void) {
        forEach { node in
            block(node)
            node.children.traverse(block)
        }
    }

    func flatten() -> [Node] {
        flatMap { node -> [Node] in
            [node] + node.children.flatten()
        }
    }
}
