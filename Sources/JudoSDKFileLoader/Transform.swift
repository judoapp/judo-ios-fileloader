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
import JudoModel
import SwiftUI
import os.log
import JudoSDKFileLoaderModel

extension DocumentState {

    @_spi(Judo)
    public func transformToSDKFormat() -> JudoModel.Experience {
        var pendingActionRelationships = [PendingActionRelationship]()
        var pendingPageControlRelationships = [PendingPageControlRelationship]()

        let document = JudoModel.Experience(
            id: "",
            name: "",
            revisionID: "",
            nodes: screens.compactMap { node in
                node.transformToSDKFormat(documentState: self, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships)
            },
            localization: self.localization,
            fonts: fontURLs,
            initialScreenID: self.initialScreen?.id ?? "",
            appearance: self.appearance.transformToSDKFormat()
        )

        let nodesByID = document.nodes.flatten().reduce(into: [JudoModel.Node.ID: JudoModel.Node]()) { (byID: inout [JudoModel.Node.ID: JudoModel.Node], node) in
            byID[node.id] = node
        }
        
        pendingActionRelationships.forEach { $0.resolve(nodes: nodesByID) }
        pendingPageControlRelationships.forEach { $0.resolve(nodes: nodesByID) }
        
        return document
    }
}

private struct PendingActionRelationship {
    var action: JudoModel.Action
    var nodeID: JudoModel.Node.ID
    var keyPath: ReferenceWritableKeyPath<JudoModel.Action, JudoModel.Screen?>
    
    func resolve(nodes: [JudoModel.Node.ID: JudoModel.Node]) {
        guard let node = nodes[nodeID] as? JudoModel.Screen else {
            assertionFailure("""
                Failed to resolve relationship. No node found with id \
                \(nodeID).
                """
            )
            
            return
        }
        
        action[keyPath: keyPath] = node
    }
}

private struct PendingPageControlRelationship {
    var pageControl: JudoModel.PageControl
    var carouselID: JudoModel.Node.ID
    var keyPath: ReferenceWritableKeyPath<JudoModel.PageControl, JudoModel.Carousel?>
    
    func resolve(nodes: [JudoModel.Node.ID: JudoModel.Node]) {
        guard let carousel = nodes[carouselID] as? JudoModel.Carousel else {
            assertionFailure("""
                Failed to resolve relationship. No node found with id \
                \(carouselID).
                """
            )
            
            return
        }
        
        pageControl[keyPath: keyPath] = carousel
    }
}

private extension JudoSDKFileLoaderModel.Node {
    func transformToSDKFormat(
        documentState: DocumentState,
        pendingActionRelationships: inout [PendingActionRelationship],
        pendingPageControlRelationships: inout [PendingPageControlRelationship]
    ) -> JudoModel.Node? {
        let children = self.children.compactMap { $0.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships) }

        switch self {
        case let carousel as JudoSDKFileLoaderModel.Carousel:
            return JudoModel.Carousel(
                id: carousel.id,
                name: carousel.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: carousel.ignoresSafeArea,
                aspectRatio: carousel.aspectRatio,
                padding: carousel.padding?.transformToSDKFormat(),
                frame: carousel.frame?.transformToSDKFormat(),
                layoutPriority: carousel.layoutPriority.map { CGFloat($0) },
                offset: carousel.offset,
                shadow: carousel.shadow?.transformToSDKFormat(),
                opacity: carousel.opacity.map { CGFloat($0) },
                background: carousel.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: carousel.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: carousel.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: carousel.action?.transformToSDKFormat(segue: carousel.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: carousel.accessibility?.transformToSDKFormat(),
                metadata: carousel.metadata?.transformToSDKFormat(),
                isLoopEnabled: carousel.isLoopEnabled
            )
        case let scrollContainer as JudoSDKFileLoaderModel.ScrollContainer:
            return JudoModel.ScrollContainer(
                id: scrollContainer.id,
                name: scrollContainer.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: scrollContainer.ignoresSafeArea,
                aspectRatio: scrollContainer.aspectRatio,
                padding: scrollContainer.padding?.transformToSDKFormat(),
                frame: scrollContainer.frame?.transformToSDKFormat(),
                layoutPriority: scrollContainer.layoutPriority.map { CGFloat($0) },
                offset: scrollContainer.offset,
                shadow: scrollContainer.shadow?.transformToSDKFormat(),
                opacity: scrollContainer.opacity.map { CGFloat($0) },
                background: scrollContainer.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: scrollContainer.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: scrollContainer.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: scrollContainer.action?.transformToSDKFormat(segue: scrollContainer.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: scrollContainer.accessibility?.transformToSDKFormat(),
                metadata: scrollContainer.metadata?.transformToSDKFormat(),
                axis: scrollContainer.axis,
                disableScrollBar: scrollContainer.disableScrollBar
            )
        case let spacer as JudoSDKFileLoaderModel.Spacer:
            return JudoModel.Spacer(
                id: spacer.id,
                name: spacer.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: spacer.ignoresSafeArea,
                aspectRatio: spacer.aspectRatio,
                padding: spacer.padding?.transformToSDKFormat(),
                frame: spacer.frame?.transformToSDKFormat(),
                layoutPriority: spacer.layoutPriority.map { CGFloat($0) },
                offset: spacer.offset,
                shadow: spacer.shadow?.transformToSDKFormat(),
                opacity: spacer.opacity.map { CGFloat($0) },
                background: spacer.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: spacer.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: spacer.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: spacer.action?.transformToSDKFormat(segue: spacer.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: spacer.accessibility?.transformToSDKFormat(),
                metadata: spacer.metadata?.transformToSDKFormat()
            )
        case let pageControl as JudoSDKFileLoaderModel.PageControl:
            let sdkPageControl = JudoModel.PageControl(
                id: pageControl.id,
                name: pageControl.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: pageControl.ignoresSafeArea,
                aspectRatio: pageControl.aspectRatio,
                padding: pageControl.padding?.transformToSDKFormat(),
                frame: pageControl.frame?.transformToSDKFormat(),
                layoutPriority: pageControl.layoutPriority.map { CGFloat($0) },
                offset: pageControl.offset,
                shadow: pageControl.shadow?.transformToSDKFormat(),
                opacity: pageControl.opacity.map { CGFloat($0) },
                background: pageControl.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: pageControl.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: pageControl.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: pageControl.action?.transformToSDKFormat(segue: pageControl.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: pageControl.accessibility?.transformToSDKFormat(),
                metadata: pageControl.metadata?.transformToSDKFormat(),
                carousel: nil,
                style: pageControl.style.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                hidesForSinglePage: pageControl.hidesForSinglePage
            )

            if let carouselID = pageControl.carousel?.id {
                pendingPageControlRelationships.append(
                   PendingPageControlRelationship(pageControl: sdkPageControl, carouselID: carouselID, keyPath: \.carousel)
                )
            }

            return sdkPageControl
        case let rectangle as JudoSDKFileLoaderModel.Rectangle:
            return JudoModel.Rectangle(
                id: rectangle.id,
                name: rectangle.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: rectangle.ignoresSafeArea,
                aspectRatio: rectangle.aspectRatio,
                padding: rectangle.padding?.transformToSDKFormat(),
                frame: rectangle.frame?.transformToSDKFormat(),
                layoutPriority: rectangle.layoutPriority.map { CGFloat($0) },
                offset: rectangle.offset,
                shadow: rectangle.shadow?.transformToSDKFormat(),
                opacity: rectangle.opacity.map { CGFloat($0) },
                background: rectangle.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: rectangle.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: rectangle.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: rectangle.action?.transformToSDKFormat(segue: rectangle.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: rectangle.accessibility?.transformToSDKFormat(),
                metadata: rectangle.metadata?.transformToSDKFormat(),
                fill: rectangle.fill.transformToSDKFormat(),
                border: rectangle.border?.transformToSDKFormat(),
                cornerRadius: rectangle.cornerRadius
            )
        case let image as JudoSDKFileLoaderModel.Image:
            if let imageURL = image.source.url {
                return JudoModel.Image(
                    id: image.id,
                    name: image.name,
                    // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                    parent: nil,
                    children: children,
                    ignoresSafeArea: image.ignoresSafeArea,
                    aspectRatio: image.aspectRatio,
                    padding: image.padding?.transformToSDKFormat(),
                    frame: image.frame?.transformToSDKFormat(),
                    layoutPriority: image.layoutPriority.map { CGFloat($0) },
                    offset: image.offset,
                    shadow: image.shadow?.transformToSDKFormat(),
                    opacity: image.opacity.map { CGFloat($0) },
                    background: image.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                    overlay: image.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                    mask: image.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                    action: image.action?.transformToSDKFormat(segue: image.segue, pendingActionRelationships: &pendingActionRelationships),
                    accessibility: image.accessibility?.transformToSDKFormat(),
                    metadata: image.metadata?.transformToSDKFormat(),
                    imageURL: imageURL,
                    darkModeImageURL: image.darkModeSource?.url,
                    resolution: image.resolution,
                    resizingMode: image.resizingMode.transformToSDKFormat(),
                    blurHash: nil,
                    darkModeBlurHash: nil,
                    imageWidth: nil,
                    imageHeight: nil,
                    darkModeImageWidth: nil,
                    darkModeImageHeight: nil
                )
            } else if let imageValue = image.source.image {
                return JudoModel.Image(
                    id: image.id,
                    name: image.name,
                    // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                    parent: nil,
                    children: children,
                    ignoresSafeArea: image.ignoresSafeArea,
                    aspectRatio: image.aspectRatio,
                    padding: image.padding?.transformToSDKFormat(),
                    frame: image.frame?.transformToSDKFormat(),
                    layoutPriority: image.layoutPriority.map { CGFloat($0) },
                    offset: image.offset,
                    shadow: image.shadow?.transformToSDKFormat(),
                    opacity: image.opacity.map { CGFloat($0) },
                    background: image.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                    overlay: image.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                    mask: image.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                    action: image.action?.transformToSDKFormat(segue: image.segue, pendingActionRelationships: &pendingActionRelationships),
                    accessibility: image.accessibility?.transformToSDKFormat(),
                    metadata: image.metadata?.transformToSDKFormat(),
                    image: imageValue.uiImage,
                    darkModeImage: image.darkModeSource?.image?.uiImage,
                    resolution: image.resolution,
                    resizingMode: image.resizingMode.transformToSDKFormat(),
                    blurHash: nil,
                    darkModeBlurHash: nil
                )
            } else {
                return nil
            }
        case let icon as JudoSDKFileLoaderModel.Icon:
            return JudoModel.Icon(
                id: icon.id,
                name: icon.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: icon.ignoresSafeArea,
                aspectRatio: icon.aspectRatio,
                padding: icon.padding?.transformToSDKFormat(),
                frame: icon.frame?.transformToSDKFormat(),
                layoutPriority: icon.layoutPriority.map { CGFloat($0) },
                offset: icon.offset,
                shadow: icon.shadow?.transformToSDKFormat(),
                opacity: icon.opacity.map { CGFloat($0) },
                background: icon.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: icon.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: icon.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: icon.action?.transformToSDKFormat(segue: icon.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: icon.accessibility?.transformToSDKFormat(),
                metadata: icon.metadata?.transformToSDKFormat(),
                icon: icon.icon.transformToSDKFormat(),
                size: icon.pointSize,
                color: icon.color.transformToSDKFormat()
            )
        case let screen as JudoSDKFileLoaderModel.Screen:
            return JudoModel.Screen(
                id: screen.id,
                name: screen.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: screen.ignoresSafeArea,
                aspectRatio: screen.aspectRatio,
                padding: screen.padding?.transformToSDKFormat(),
                frame: screen.frame?.transformToSDKFormat(),
                layoutPriority: screen.layoutPriority.map { CGFloat($0) },
                offset: screen.offset,
                shadow: screen.shadow?.transformToSDKFormat(),
                opacity: screen.opacity.map { CGFloat($0) },
                background: screen.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: screen.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: screen.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: screen.action?.transformToSDKFormat(segue: screen.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: screen.accessibility?.transformToSDKFormat(),
                metadata: screen.metadata?.transformToSDKFormat(),
                statusBarStyle: screen.statusBarStyle.transformToSDKFormat(),
                backButtonStyle: screen.backButtonStyle.transformToSDKFormat(),
                backgroundColor: screen.backgroundColor.transformToSDKFormat()
            )
        case let navBar as JudoSDKFileLoaderModel.NavBar:
            return JudoModel.NavBar(
                id: navBar.id,
                name: navBar.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: navBar.ignoresSafeArea,
                aspectRatio: navBar.aspectRatio,
                padding: navBar.padding?.transformToSDKFormat(),
                frame: navBar.frame?.transformToSDKFormat(),
                layoutPriority: navBar.layoutPriority.map { CGFloat($0) },
                offset: navBar.offset,
                shadow: navBar.shadow?.transformToSDKFormat(),
                opacity: navBar.opacity.map { CGFloat($0) },
                background: navBar.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: navBar.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: navBar.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: navBar.action?.transformToSDKFormat(segue: navBar.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: navBar.accessibility?.transformToSDKFormat(),
                metadata: navBar.metadata?.transformToSDKFormat(),
                title: navBar.title,
                titleDisplayMode: navBar.titleDisplayMode.transformToSDKFormat(),
                hidesBackButton: navBar.hidesBackButton,
                titleFont: navBar.titleFont.transformToSDKFormat(documentState: documentState),
                largeTitleFont: navBar.largeTitleFont.transformToSDKFormat(documentState: documentState),
                buttonFont: navBar.buttonFont.transformToSDKFormat(documentState: documentState),
                appearance: navBar.appearance.transformToSDKFormat(),
                alternateAppearance: navBar.alternateAppearance?.transformToSDKFormat()
            )
        case let navBarButton as JudoSDKFileLoaderModel.NavBarButton:
            return JudoModel.NavBarButton(
                id: navBarButton.id,
                name: navBarButton.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: navBarButton.ignoresSafeArea,
                aspectRatio: navBarButton.aspectRatio,
                padding: navBarButton.padding?.transformToSDKFormat(),
                frame: navBarButton.frame?.transformToSDKFormat(),
                layoutPriority: navBarButton.layoutPriority.map { CGFloat($0) },
                offset: navBarButton.offset,
                shadow: navBarButton.shadow?.transformToSDKFormat(),
                opacity: navBarButton.opacity.map { CGFloat($0) },
                background: navBarButton.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: navBarButton.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: navBarButton.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: navBarButton.action?.transformToSDKFormat(segue: navBarButton.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: navBarButton.accessibility?.transformToSDKFormat(),
                metadata: navBarButton.metadata?.transformToSDKFormat(),
                placement: navBarButton.placement.transformToSDKFormat(),
                style: navBarButton.style.transformToSDKFormat(),
                title: navBarButton.title,
                icon: navBarButton.icon?.transformToSDKFormat()
            )
        case let zstack as JudoSDKFileLoaderModel.ZStack:
            return JudoModel.ZStack(
                id: zstack.id,
                name: zstack.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: zstack.ignoresSafeArea,
                aspectRatio: zstack.aspectRatio,
                padding: zstack.padding?.transformToSDKFormat(),
                frame: zstack.frame?.transformToSDKFormat(),
                layoutPriority: zstack.layoutPriority.map { CGFloat($0) },
                offset: zstack.offset,
                shadow: zstack.shadow?.transformToSDKFormat(),
                opacity: zstack.opacity.map { CGFloat($0) },
                background: zstack.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: zstack.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: zstack.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: zstack.action?.transformToSDKFormat(segue: zstack.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: zstack.accessibility?.transformToSDKFormat(),
                metadata: zstack.metadata?.transformToSDKFormat(),
                alignment: zstack.alignment
            )
        case let hstack as JudoSDKFileLoaderModel.HStack:
            return JudoModel.HStack(
                id: hstack.id,
                name: hstack.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: hstack.ignoresSafeArea,
                aspectRatio: hstack.aspectRatio,
                padding: hstack.padding?.transformToSDKFormat(),
                frame: hstack.frame?.transformToSDKFormat(),
                layoutPriority: hstack.layoutPriority.map { CGFloat($0) },
                offset: hstack.offset,
                shadow: hstack.shadow?.transformToSDKFormat(),
                opacity: hstack.opacity.map { CGFloat($0) },
                background: hstack.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: hstack.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: hstack.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: hstack.action?.transformToSDKFormat(segue: hstack.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: hstack.accessibility?.transformToSDKFormat(),
                metadata: hstack.metadata?.transformToSDKFormat(),
                alignment: hstack.alignment,
                spacing: hstack.spacing
            )
        case let vstack as JudoSDKFileLoaderModel.VStack:
            return JudoModel.VStack(
                id: vstack.id,
                name: vstack.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: vstack.ignoresSafeArea,
                aspectRatio: vstack.aspectRatio,
                padding: vstack.padding?.transformToSDKFormat(),
                frame: vstack.frame?.transformToSDKFormat(),
                layoutPriority: vstack.layoutPriority.map { CGFloat($0) },
                offset: vstack.offset,
                shadow: vstack.shadow?.transformToSDKFormat(),
                opacity: vstack.opacity.map { CGFloat($0) },
                background: vstack.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: vstack.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: vstack.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: vstack.action?.transformToSDKFormat(segue: vstack.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: vstack.accessibility?.transformToSDKFormat(),
                metadata: vstack.metadata?.transformToSDKFormat(),
                alignment: vstack.alignment,
                spacing: vstack.spacing
            )
        case let text as JudoSDKFileLoaderModel.Text:
            return JudoModel.Text(
                id: text.id,
                name: text.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: text.ignoresSafeArea,
                aspectRatio: text.aspectRatio,
                padding: text.padding?.transformToSDKFormat(),
                frame: text.frame?.transformToSDKFormat(),
                layoutPriority: text.layoutPriority.map { CGFloat($0) },
                offset: text.offset,
                shadow: text.shadow?.transformToSDKFormat(),
                opacity: text.opacity.map { CGFloat($0) },
                background: text.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: text.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: text.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: text.action?.transformToSDKFormat(segue: text.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: text.accessibility?.transformToSDKFormat(),
                metadata: text.metadata?.transformToSDKFormat(),
                text: text.text,
                font: text.font.transformToSDKFormat(documentState: documentState),
                textColor: text.textColor.transformToSDKFormat(),
                textAlignment: text.textAlignment,
                lineLimit: text.lineLimit,
                transform: text.transform?.transformToSDKFormat()
            )
        case let divider as JudoSDKFileLoaderModel.Divider:
            return JudoModel.Divider(
                id: divider.id,
                name: divider.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: divider.ignoresSafeArea,
                aspectRatio: divider.aspectRatio,
                padding: divider.padding?.transformToSDKFormat(),
                frame: divider.frame?.transformToSDKFormat(),
                layoutPriority: divider.layoutPriority.map { CGFloat($0) },
                offset: divider.offset,
                shadow: divider.shadow?.transformToSDKFormat(),
                opacity: divider.opacity.map { CGFloat($0) },
                background: divider.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: divider.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: divider.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: divider.action?.transformToSDKFormat(segue: divider.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: divider.accessibility?.transformToSDKFormat(),
                metadata: divider.metadata?.transformToSDKFormat(),
                backgroundColor: divider.backgroundColor.transformToSDKFormat()
            )
        case let webView as JudoSDKFileLoaderModel.WebView:
            return JudoModel.WebView(
                id: webView.id,
                name: webView.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: webView.ignoresSafeArea,
                aspectRatio: webView.aspectRatio,
                padding: webView.padding?.transformToSDKFormat(),
                frame: webView.frame?.transformToSDKFormat(),
                layoutPriority: webView.layoutPriority.map { CGFloat($0) },
                offset: webView.offset,
                shadow: webView.shadow?.transformToSDKFormat(),
                opacity: webView.opacity.map { CGFloat($0) },
                background: webView.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: webView.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: webView.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: webView.action?.transformToSDKFormat(segue: webView.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: webView.accessibility?.transformToSDKFormat(),
                metadata: webView.metadata?.transformToSDKFormat(),
                source: webView.source.transformToSDKFormat(),
                isScrollEnabled: webView.isScrollEnabled
            )
        case let video as JudoSDKFileLoaderModel.Video:
            return JudoModel.Video(
                id: video.id,
                name: video.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: video.ignoresSafeArea,
                aspectRatio: video.aspectRatio,
                padding: video.padding?.transformToSDKFormat(),
                frame: video.frame?.transformToSDKFormat(),
                layoutPriority: video.layoutPriority.map { CGFloat($0) },
                offset: video.offset,
                shadow: video.shadow?.transformToSDKFormat(),
                opacity: video.opacity.map { CGFloat($0) },
                background: video.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: video.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: video.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: video.action?.transformToSDKFormat(segue: video.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: video.accessibility?.transformToSDKFormat(),
                metadata: video.metadata?.transformToSDKFormat(),
                sourceURL: video.source.url,
                posterImageURL: video.posterImageURL,
                resizingMode: JudoModel.Video.ResizingMode(rawValue: video.resizingMode.rawValue)!,
                showControls: video.showControls,
                autoPlay: video.autoPlay,
                looping: video.looping,
                removeAudio: video.removeAudio
            )
        case let audio as JudoSDKFileLoaderModel.Audio:
            return JudoModel.Audio(
                id: audio.id,
                name: audio.name,
                // parent will be set in the initializer of the parent that receives this node in the children array given to its initializer.
                parent: nil,
                children: children,
                ignoresSafeArea: audio.ignoresSafeArea,
                aspectRatio: audio.aspectRatio,
                padding: audio.padding?.transformToSDKFormat(),
                frame: audio.frame?.transformToSDKFormat(),
                layoutPriority: audio.layoutPriority.map { CGFloat($0) },
                offset: audio.offset,
                shadow: audio.shadow?.transformToSDKFormat(),
                opacity: audio.opacity.map { CGFloat($0) },
                background: audio.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: audio.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: audio.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: audio.action?.transformToSDKFormat(segue: audio.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: audio.accessibility?.transformToSDKFormat(),
                metadata: audio.metadata?.transformToSDKFormat(),
                sourceURL: audio.source.url,
                autoPlay: audio.autoPlay,
                looping: audio.looping
            )
        case let dataSource as JudoSDKFileLoaderModel.DataSource:
            return JudoModel.DataSource(
                id: dataSource.id,
                name: dataSource.name,
                parent: nil,
                children: children,
                ignoresSafeArea: dataSource.ignoresSafeArea,
                aspectRatio: dataSource.aspectRatio,
                padding: dataSource.padding?.transformToSDKFormat(),
                frame: dataSource.frame?.transformToSDKFormat(),
                layoutPriority: dataSource.layoutPriority.map { CGFloat($0) },
                offset: dataSource.offset,
                shadow: dataSource.shadow?.transformToSDKFormat(),
                opacity: dataSource.opacity.map { CGFloat($0) },
                background: dataSource.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: dataSource.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: dataSource.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: dataSource.action?.transformToSDKFormat(segue: dataSource.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: dataSource.accessibility?.transformToSDKFormat(),
                metadata: dataSource.metadata?.transformToSDKFormat(),
                url: dataSource.url,
                httpMethod: dataSource.httpMethod.transformToSDKFormat(),
                httpBody: dataSource.httpBody,
                headers: dataSource.headers.map { $0.transformToSDKFormat() },
                pollInterval: dataSource.pollInterval
            )
        case let collection as JudoSDKFileLoaderModel.Collection:
            return JudoModel.Collection(
                id: collection.id,
                name: collection.name,
                parent: nil,
                children: children,
                ignoresSafeArea: collection.ignoresSafeArea,
                aspectRatio: collection.aspectRatio,
                padding: collection.padding?.transformToSDKFormat(),
                frame: collection.frame?.transformToSDKFormat(),
                layoutPriority: collection.layoutPriority.map { CGFloat($0) },
                offset: collection.offset,
                shadow: collection.shadow?.transformToSDKFormat(),
                opacity: collection.opacity.map { CGFloat($0) },
                background: collection.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: collection.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: collection.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: collection.action?.transformToSDKFormat(segue: collection.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: collection.accessibility?.transformToSDKFormat(),
                metadata: collection.metadata?.transformToSDKFormat(),
                keyPath: collection.keyPath,
                filters: collection.filters.map { $0.transformToSDKFormat() },
                sortDescriptors: collection.sortDescriptors.map { $0.transformToSDKFormat() },
                limit: collection.limit?.transformToSDKFormat()
            )
        case let conditional as JudoSDKFileLoaderModel.Conditional:
            return JudoModel.Conditional(
                id: conditional.id,
                name: conditional.name,
                parent: nil,
                children: children,
                ignoresSafeArea: conditional.ignoresSafeArea,
                aspectRatio: conditional.aspectRatio,
                padding: conditional.padding?.transformToSDKFormat(),
                frame: conditional.frame?.transformToSDKFormat(),
                layoutPriority: conditional.layoutPriority.map { CGFloat($0) },
                offset: conditional.offset,
                shadow: conditional.shadow?.transformToSDKFormat(),
                opacity: conditional.opacity.map { CGFloat($0) },
                background: conditional.background?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                overlay: conditional.overlay?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                mask: conditional.mask?.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships),
                action: conditional.action?.transformToSDKFormat(segue: conditional.segue, pendingActionRelationships: &pendingActionRelationships),
                accessibility: conditional.accessibility?.transformToSDKFormat(),
                metadata: conditional.metadata?.transformToSDKFormat(),
                conditions: conditional.conditions.map { $0.transformToSDKFormat() }
            )
        default:
            assertionFailure("Node of type \(String(describing: type(of: self))) not supported.")
            os_log(.error, "Node of type %@ not supported.", String(describing: type(of: self)))
            return nil
        }
    }
}

private extension JudoSDKFileLoaderModel.Metadata {
    func transformToSDKFormat() -> JudoModel.Metadata {
        let userInfoHash = self.properties.reduce(into: [String: String]()) { (result, pair) in
            result[pair.key] = pair.value
        }
        return JudoModel.Metadata(properties: userInfoHash, tags: Set(self.tags))
    }
}

private extension JudoSDKFileLoaderModel.Text.Transform {
    func transformToSDKFormat() -> JudoModel.Text.Transform {
        switch self {
        case .lowercase:
            return .lowercase
        case .uppercase:
            return .uppercase
        }
    }
}

private extension JudoSDKFileLoaderModel.Font {
    func transformToSDKFormat(documentState: DocumentState) -> JudoModel.Font {
        let documentFonts = documentState.fonts

        switch self {
        case .custom(let fontName, let size):
            return .custom(fontName: fontName, size: size, isDynamic: false)
        case .dynamic(let textStyle, let emphases):
            return .dynamic(textStyle: textStyle, emphases: emphases.transformToSDKFormat())
        case .document(let fontFamily, let textStyle):
            guard let matchingDocumentFont = documentFonts.first(where: { font in
                font.fontFamily == fontFamily
            }) else {
                assertionFailure("Document Font for family is missing: \(fontFamily)")
                os_log(.error, "Document Font for family is missing: %@", fontFamily)
                return .dynamic(textStyle: .body, emphases: [])
            }
            
            let customFont = matchingDocumentFont.customFontByStyle(textStyle)
            
            return .custom(fontName: customFont.fontName, size: customFont.size, isDynamic: true)
        case .fixed(let size, let weight):
            return .fixed(size: size, weight: weight)
        }
    }
}

private extension JudoSDKFileLoaderModel.DocumentState.Appearance {
    func transformToSDKFormat() -> JudoModel.Experience.Appearance {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        case .auto:
            return .auto
        }
    }
}

private extension JudoSDKFileLoaderModel.Font.Emphasis {
    func transformToSDKFormat() -> JudoModel.Font.Emphasis {
        switch self {
            case .bold:
                return .bold
            case .italic:
                return .italic
        }
    }
}

extension Set where Element == JudoSDKFileLoaderModel.Font.Emphasis {
    func transformToSDKFormat() -> Set<JudoModel.Font.Emphasis> {
        Swift.Set(
            map {
                $0.transformToSDKFormat()
            }
        )
    }
}

private extension JudoSDKFileLoaderModel.DocumentFont {
    func customFontByStyle(_ style: SwiftUI.Font.TextStyle) -> JudoSDKFileLoaderModel.DocumentFont.CustomFont {
        switch style {
        case .largeTitle:
            return largeTitle
        case .title:
            return title
        case .title2:
            return title2
        case .title3:
            return title3
        case .headline:
            return headline
        case .body:
            return body
        case .callout:
            return callout
        case .subheadline:
            return subheadline
        case .footnote:
            return footnote
        case .caption:
            return caption
        case .caption2:
            return caption2
        default:
            assertionFailure("Unsupported text style: \(style)")
            os_log(.error, "Unsupported text style: %@", String(describing: style))
            return body
        }
    }
}

private extension JudoSDKFileLoaderModel.Image.ResizingMode {
    func transformToSDKFormat() -> JudoModel.Image.ResizingMode {
        switch self {
        case .originalSize:
            return .originalSize
        case .scaleToFill:
            return .scaleToFill
        case .scaleToFit:
            return .scaleToFit
        case .stretch:
            return .stretch
        case .tile:
            return .tile
        }
    }
}

private extension JudoSDKFileLoaderModel.Border {
    func transformToSDKFormat() -> JudoModel.Border {
        return JudoModel.Border(color: color.transformToSDKFormat(), width: width)
    }
}

private extension JudoSDKFileLoaderModel.Accessibility {
    func transformToSDKFormat() -> JudoModel.Accessibility {
        return JudoModel.Accessibility(
            isHidden: isHidden,
            label: label,
            sortPriority: sortPriority,
            isHeader: isHeader,
            isSummary: isSummary,
            playsSound: playsSound,
            startsMediaSession: startsMediaSession
        )
    }
}

private extension JudoSDKFileLoaderModel.Action {
    func transformToSDKFormat(segue: Segue?, pendingActionRelationships: inout [PendingActionRelationship]) -> JudoModel.Action {
        switch self {
        case .performSegue:
            let segueStyle: JudoModel.SegueStyle?
            let modalPresentationStyle: JudoModel.ModalPresentationStyle?
            switch segue?.style {
            case .modal(let presentationStyle):
                segueStyle = .modal
                modalPresentationStyle = presentationStyle.transformToSDKFormat()
            default:
                segueStyle = .push
                modalPresentationStyle = nil
            }
            
            let action = JudoModel.Action(
                actionType: .performSegue,
                segueStyle: segueStyle,
                modalPresentationStyle: modalPresentationStyle
            )
        
            if let screen = segue?.destination {
                pendingActionRelationships.append(
                    PendingActionRelationship(
                        action: action,
                        nodeID: screen.id,
                        keyPath: \.screen
                    )
                )
            }

            return action
        case .openURL(let url, let dismissExperience):
            return JudoModel.Action(
                actionType: .openURL,
                screen: nil,
                modalPresentationStyle: nil,
                url: url,
                dismissExperience: dismissExperience
            )
        case .presentWebsite(let url):
            return JudoModel.Action(
                actionType: .presentWebsite,
                screen: nil,
                modalPresentationStyle: nil,
                url: url
            )
        case .close:
            return JudoModel.Action(
                actionType: .close,
                screen: nil,
                modalPresentationStyle: nil,
                url: nil
            )
        case .custom(let dismissExperience):
            return JudoModel.Action(
                actionType: .custom,
                screen: nil,
                modalPresentationStyle: nil,
                url: nil,
                dismissExperience: dismissExperience
            )
        }
    }
}

private extension JudoSDKFileLoaderModel.StatusBarStyle {
    func transformToSDKFormat() -> JudoModel.StatusBarStyle {
        switch self {
        case .default:
            return .default
        case .light:
            return .light
        case .dark:
            return .dark
        case .inverted:
            return .inverted
        }
    }
}

extension JudoSDKFileLoaderModel.BackButtonStyle {
    func transformToSDKFormat() -> JudoModel.BackButtonStyle {
        switch self {
        case .default(let title):
            return .default(title: title)
        case .generic:
            return .generic
        case .minimal:
            return .minimal
        }
    }
}

private extension JudoSDKFileLoaderModel.ModalPresentationStyle {
    func transformToSDKFormat() -> JudoModel.ModalPresentationStyle {
        switch self {
        case .sheet:
            return .sheet
        case .fullScreen:
            return .fullScreen
        }
    }
}

extension JudoSDKFileLoaderModel.NavBar.TitleDisplayMode {
    func transformToSDKFormat() -> JudoModel.NavBar.TitleDisplayMode {
        switch self {
        case .inline:
            return .inline
        case .large:
            return .large
        }
    }
}

extension JudoSDKFileLoaderModel.NavBar.Background {
    func transformToSDKFormat() -> JudoModel.NavBar.Background {
        JudoModel.NavBar.Background(
            fillColor: fillColor.transformToSDKFormat(),
            shadowColor: shadowColor.transformToSDKFormat(),
            blurEffect: blurEffect
        )
    }
}

extension JudoSDKFileLoaderModel.NavBar.Appearance {
    func transformToSDKFormat() -> JudoModel.NavBar.Appearance {
        JudoModel.NavBar.Appearance(
            titleColor: titleColor.transformToSDKFormat(),
            buttonColor: buttonColor.transformToSDKFormat(),
            background: background.transformToSDKFormat()
        )
    }
}

extension JudoSDKFileLoaderModel.NavBarButton.Placement {
    func transformToSDKFormat() -> JudoModel.NavBarButton.Placement {
        switch self {
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        }
    }
}

extension JudoSDKFileLoaderModel.NavBarButton.Style {
    func transformToSDKFormat() -> JudoModel.NavBarButton.Style {
        switch self {
        case .custom:
            return .custom
        case .done:
            return .done
        case .close:
            return .close
        }
    }
}

extension JudoSDKFileLoaderModel.NamedIcon {
    func transformToSDKFormat() -> JudoModel.NamedIcon {
        JudoModel.NamedIcon(
            symbolName: symbolName,
            materialName: materialName
        )
    }
}

private extension JudoSDKFileLoaderModel.Shadow {
    func transformToSDKFormat() -> JudoModel.Shadow {
        return JudoModel.Shadow(color: color.transformToSDKFormat(), blur: blur, x: x, y: y)
    }
}

private extension JudoSDKFileLoaderModel.Padding {
    func transformToSDKFormat() -> JudoModel.Padding {
        return JudoModel.Padding(
            top: self.top,
            leading: self.leading,
            bottom: self.bottom,
            trailing: self.trailing
        )
    }
}

private extension JudoSDKFileLoaderModel.Frame {
    func transformToSDKFormat() -> JudoModel.Frame {
        return JudoModel.Frame(
            width: width,
            height: height,
            minWidth: minWidth,
            maxWidth: maxWidth,
            minHeight: minHeight,
            maxHeight: maxHeight,
            alignment: alignment
        )
    }
}

private extension JudoSDKFileLoaderModel.Fill {
    func transformToSDKFormat() -> JudoModel.Fill {
        switch self {
        case .flat(let colorReference):
            return JudoModel.Fill.flat(colorReference.transformToSDKFormat())
        case .gradient(let gradientReference):
            return JudoModel.Fill.gradient(gradientReference.transformToSDKFormat())
        }
    }
}

private extension ColorReference {
    func transformToSDKFormat() -> JudoModel.ColorVariants {
        let defaultValue: ColorValue?
        switch self.referenceType {
        case .custom:
            guard let customValue = self.customColor else {
                assertionFailure("Invalid custom ColorReference, lacking a customColor value")
                defaultValue = nil
                break
            }
            defaultValue = customValue
        case .document:
            guard let universalValue = self.documentColor?.resolveColor(darkMode: false, highContrast: false) else {
                assertionFailure("Invalid document ColorReference, lacking a documentColor value")
                defaultValue = nil
                break
            }
            defaultValue = universalValue
        case .system:
            defaultValue = nil
        }
    
        return JudoModel.ColorVariants(
            systemName: self.systemColorName,
            default: defaultValue?.transformToSDKFormat(),
            highContrast: self.documentColor?.resolveColor(darkMode: false, highContrast: true).transformToSDKFormat(),
            darkMode: self.documentColor?.resolveColor(darkMode: true, highContrast: false).transformToSDKFormat(),
            darkModeHighContrast: self.documentColor?.resolveColor(darkMode: true, highContrast: true).transformToSDKFormat()
        )
    }
}

private extension JudoSDKFileLoaderModel.DataSource.HTTPMethod {
    func transformToSDKFormat() -> JudoModel.DataSource.HTTPMethod {
        switch self {
            case .get:
                return .get
            case .post:
                return .post
            case .put:
                return .put
        }
    }
}

private extension JudoSDKFileLoaderModel.DataSource.Header {
    func transformToSDKFormat() -> JudoModel.DataSource.Header {
        JudoModel.DataSource.Header(key: key, value: value)
    }
}

private extension JudoSDKFileLoaderModel.Condition {
    func transformToSDKFormat() -> JudoModel.Condition {
        JudoModel.Condition(
            keyPath: keyPath,
            predicate: predicate.transformToSDKFormat(),
            value: value
        )
    }
}

private extension JudoSDKFileLoaderModel.Condition.Predicate {
    func transformToSDKFormat() -> JudoModel.Condition.Predicate {
        switch self {
        case .equals:
            return .equals
        case .doesNotEqual:
            return .doesNotEqual
        case .isGreaterThan:
            return .isGreaterThan
        case .isLessThan:
            return .isLessThan
        case .isSet:
            return .isSet
        case .isNotSet:
            return .isNotSet
        case .isTrue:
            return .isTrue
        case .isFalse:
            return .isFalse
        }
    }
}

private extension JudoSDKFileLoaderModel.SortDescriptor {
    func transformToSDKFormat() -> JudoModel.Collection.SortDescriptor {
        JudoModel.Collection.SortDescriptor(
            keyPath: keyPath,
            ascending: ascending
        )
    }
}

private extension JudoSDKFileLoaderModel.Collection.Limit {
    func transformToSDKFormat() -> JudoModel.Collection.Limit {
        JudoModel.Collection.Limit(show: show, startAt: startAt)
    }
}

private extension ColorValue {
    func transformToSDKFormat() -> JudoModel.Color {
        return JudoModel.Color(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }
}

private extension GradientReference {
    func transformToSDKFormat() -> JudoModel.GradientVariants {
        let defaultValue: GradientValue?
        switch self.referenceType {
        case .custom:
            defaultValue = self.customGradient
        case .document:
            defaultValue = self.documentGradient?.resolveGradient(darkMode: false, highContrast: false)
        }
        
        return JudoModel.GradientVariants(
            default: (defaultValue ?? GradientValue.default).transformToSDKFormat(),
            darkMode: self.documentGradient?.resolveGradient(darkMode: true, highContrast: false).transformToSDKFormat(),
            highContrast: self.documentGradient?.resolveGradient(darkMode: false, highContrast: true).transformToSDKFormat(),
            darkModeHighContrast: self.documentGradient?.resolveGradient(darkMode: true, highContrast: true).transformToSDKFormat()
        )
    }
}

private extension GradientValue {
    func transformToSDKFormat() -> JudoModel.Gradient {
        return JudoModel.Gradient(
            from: self.from,
            to: self.to,
            stops: self.stops.map { $0.transformToSDKFormat() }
        )
    }
}

private extension GradientValue.Stop {
    func transformToSDKFormat() -> JudoModel.GradientStop {
        return GradientStop(
            position: CGFloat(self.position),
            color: self.color.transformToSDKFormat()
        )
    }
}

private extension JudoSDKFileLoaderModel.Background {
    func transformToSDKFormat(documentState: DocumentState, pendingActionRelationships: inout [PendingActionRelationship], pendingPageControlRelationships: inout [PendingPageControlRelationship]) -> JudoModel.Background? {
        JudoModel.Background(
            node.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships)!,
            alignment: alignment
        )
    }
}

private extension JudoSDKFileLoaderModel.Overlay {
    func transformToSDKFormat(documentState: DocumentState, pendingActionRelationships: inout [PendingActionRelationship], pendingPageControlRelationships: inout [PendingPageControlRelationship]) -> JudoModel.Overlay? {
        JudoModel.Overlay(
            node.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships)!,
            alignment: alignment
        )
    }

}

private extension JudoSDKFileLoaderModel.PageControl.Style {
    func transformToSDKFormat(documentState: DocumentState, pendingActionRelationships: inout [PendingActionRelationship], pendingPageControlRelationships: inout [PendingPageControlRelationship]) -> JudoModel.PageControl.Style {
        switch self {
            case .default:
                return .default
            case .light:
                return .light
            case .dark:
                return .dark
            case .inverted:
                return .inverted
            case .custom(let normalColor, let currentColor):
                return .custom(normalColor: normalColor.transformToSDKFormat(), currentColor: currentColor.transformToSDKFormat())
            case .image(let normalImage, let normalColor, let currentImage, let currentColor):
                return .image(
                    normalImage: normalImage.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships) as! JudoModel.Image,
                    normalColor: normalColor.transformToSDKFormat(),
                    currentImage: currentImage.transformToSDKFormat(documentState: documentState, pendingActionRelationships: &pendingActionRelationships, pendingPageControlRelationships: &pendingPageControlRelationships) as! JudoModel.Image,
                    currentColor: currentColor.transformToSDKFormat()
                )
                
        }
    }
}

private extension JudoSDKFileLoaderModel.WebView.Source {
    func transformToSDKFormat() -> JudoModel.WebView.Source {
        switch self {
        case .url(let value):
            return .url(value)
        case .html(let value):
            return .html(value)
        }
    }
}

extension Sequence where Element: JudoModel.Node {
    func flatten() -> [JudoModel.Node] {
        flatMap { node -> [JudoModel.Node] in
            [node] + node.children.flatten()
        }
    }
}
