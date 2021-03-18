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

/// Contains information returned from a complete search command, not on a per-message basis.
public enum SearchReturnData: Equatable {
    /// Return the lowest message number/UID that satisfies the SEARCH criteria.
    case min(Int)

    /// Return the highest message number/UID that satisfies the SEARCH criteria.
    case max(Int)

    /// Return all message numbers/UIDs that satisfy the SEARCH criteria.
    case all(LastCommandSet<SequenceRangeSet>)

    /// Return number of the messages that satisfy the SEARCH criteria.
    case count(Int)

    /// Contains the highest mod-sequence for all messages being returned.
    case modificationSequence(ModificationSequenceValue)

    /// Implemented as a catch-all to support any return data options defined in future extensions.
    case dataExtension(KeyValue<String, ParameterValue>)
}

// MARK: - Encoding

extension _EncodeBuffer {
    @discardableResult mutating func writeSearchReturnData(_ data: SearchReturnData) -> Int {
        switch data {
        case .min(let num):
            return self._writeString("MIN \(num)")
        case .max(let num):
            return self._writeString("MAX \(num)")
        case .all(let set):
            return
                self._writeString("ALL ") +
                self.writeLastCommandSet(set)
        case .count(let num):
            return self._writeString("COUNT \(num)")
        case .dataExtension(let optionExt):
            return self.writeSearchReturnDataExtension(optionExt)
        case .modificationSequence(let seq):
            return self._writeString("MODSEQ \(seq)")
        }
    }
}
