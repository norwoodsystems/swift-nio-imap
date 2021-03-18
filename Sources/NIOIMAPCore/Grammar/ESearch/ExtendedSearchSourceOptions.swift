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

/// RFC 6237 - Source options
public struct ExtendedSearchSourceOptions: Equatable {
    /// Array of at least one mailbox filter.
    public private(set) var sourceMailbox: [MailboxFilter]

    /// Scope Options
    public private(set) var scopeOptions: ExtendedSearchScopeOptions?

    /// Creates a new `ExtendedSearchSourceOptions` from given scope options and mailbox filters.
    /// - parameter sourceMailbox: One or more mailboxes filters
    /// - parameter scopeOptions: Optional ExtendedSearch Scope options.
    public init?(sourceMailbox: [MailboxFilter], scopeOptions: ExtendedSearchScopeOptions? = nil) {
        guard sourceMailbox.count >= 1 else {
            return nil
        }
        self.sourceMailbox = sourceMailbox
        self.scopeOptions = scopeOptions
    }
}

// MARK: - Encoding

extension _EncodeBuffer {
    @discardableResult mutating func writeExtendedSearchSourceOptions(_ options: ExtendedSearchSourceOptions) -> Int {
        self._writeString("IN (") +
            self.writeArray(options.sourceMailbox, parenthesis: false) { (filter, buffer) -> Int in
                buffer.writeMailboxFilter(filter)
            } +
            self.writeIfExists(options.scopeOptions) { scopeOptions in
                self._writeString(" (") +
                    self.writeExtendedSearchScopeOptions(scopeOptions) +
                    self._writeString(")")
            } +
            self._writeString(")")
    }
}