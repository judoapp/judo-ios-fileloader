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

import os.log
import SwiftUI
import ZIPFoundation
import JudoSDKFileLoaderModel

// MARK: Reading and Writing

extension DocumentState {

    @_spi(Judo)
    public static func read(from data: Data) throws -> DocumentState {
        guard let archive = ZIPFoundation.Archive(data: data, accessMode: .read) else {
            os_log("Unable to open ZIP container", type: .error)
            throw CocoaError(.fileReadCorruptFile)
        }
        
        // Strings Table
        
        let localization: StringTable
        do {
            localization = try archive.extractStringsTables()
        } catch {
            os_log(
                "Unable to read document string tables due to ZIP decoding issue: %s",
                log: OSLog.default,
                type: .error,
                error.debugDescription
            )
            throw CocoaError(.fileReadUnknown)
        }

        let decoder = JSONDecoder()
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "inf",
            negativeInfinity: "-inf",
            nan: "nan"
        )
        
        guard let metaFile = archive["meta.json"], metaFile.type == .file else {
            os_log(
                "Unable to read document due to ZIP decoding issue: meta.json is missing.",
                log: OSLog.default,
                type: .error
            )
            throw CocoaError(.fileReadUnknown)
        }
        
        let metaData: Data
        let meta: Meta
        do {
            metaData = try archive.extractEntire(entry: metaFile)
            meta = try decoder.decode(Meta.self, from: metaData)
        } catch {
            os_log(
                "Unable to read document metadata due to ZIP decoding issue: %s",
                log: OSLog.default,
                type: .error,
                error.debugDescription
            )
            throw CocoaError(.fileReadUnknown)
        }
        
        decoder.userInfo[.decodingCoordinator] = DecodingCoordinator(
            documentVersion: meta.version,
            stringTable: localization,
            images: try archive.extractImages(),
            mediaURLs: try archive.extractMediaURLs(),
            fontURLs: try archive.extractFontURLs()
        )

        guard let documentFile = archive["document.json"], documentFile.type == .file else {
            throw CocoaError(.fileReadUnknown)
        }

        let documentData: Data
        do {
            documentData = try archive.extractEntire(entry: documentFile)
        } catch {
            os_log(
                "Unable to read document due to ZIP decoding issue: %s",
                log: OSLog.default,
                type: .error,
                error.debugDescription
            )
            throw CocoaError(.fileReadUnknown)
        }

        do {
            return try decoder.decode(DocumentState.self, from: documentData)
        } catch {
            os_log(
                "Unable to read document due to JSON decoding issue: %s",
                log: OSLog.default,
                type: .error,
                error.debugDescription
            )
            throw CocoaError(.fileReadUnknown)
        }
    }
    
    struct Meta: Decodable {
        var version: Int
    }
}
