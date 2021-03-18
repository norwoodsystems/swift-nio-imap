//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2021 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import NIO
import NIOIMAP

class CommandTester: Benchmark {
    var command: Command
    var iterations: Int

    init(command: Command, iterations: Int) {
        self.command = command
        self.iterations = iterations
    }

    func setUp() throws {}

    func tearDown() {}

    func run() throws -> Int {
        for i in 1 ... self.iterations {
            var commandBuffer = CommandEncodeBuffer(buffer: ByteBuffer(), options: .init())
            commandBuffer.writeCommand(.init(tag: "\(i)", command: self.command))

            var buffer = ByteBuffer()
            var chunk = commandBuffer._buffer._nextChunk()
            var chunkBuffer = chunk._bytes
            buffer.writeBuffer(&chunkBuffer)
            while chunk._waitForContinuation {
                chunk = commandBuffer._buffer._nextChunk()
                var chunkBuffer = chunk._bytes
                buffer.writeBuffer(&chunkBuffer)
            }

            var parser = CommandParser(bufferLimit: 1000)
            _ = try! parser.parseCommandStream(buffer: &buffer)
        }
        return self.iterations
    }
}
