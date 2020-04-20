//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2020 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import struct NIO.ByteBuffer

extension NIOIMAP {

    /// IMAPv4 `Namespace-Description`
    public struct NamespaceDescription: Equatable {
        public var string: ByteBuffer
        public var char: Character?
        public var responseExtensions: [NamespaceResponseExtension]

        public static func string(_ string: ByteBuffer, char: Character?, responseExtensions: [NamespaceResponseExtension]) -> Self {
            return Self(string: string, char: char, responseExtensions: responseExtensions)
        }
    }

}

// MARK: - Encoding
extension ByteBuffer {

    @discardableResult mutating func writeNamespaceDescription(_ description: NIOIMAP.NamespaceDescription) -> Int {
        var size = 0
        size += self.writeString("(")
        size += self.writeIMAPString(description.string)
        size += self.writeSpace()

        if let char = description.char {
            size += self.writeString("\"\(char)\"")
        } else {
            size += self.writeNil()
        }

        size += self.writeNamespaceResponseExtensions(description.responseExtensions)
        size += self.writeString(")")
        return size
    }

}