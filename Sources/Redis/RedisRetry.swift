//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-nio-redis open source project
//
// Copyright (c) 2018 ZeeZide GmbH. and the swift-nio-redis project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import struct Foundation.Date
import struct Foundation.TimeInterval

/// A callback which defines the connect-retry strategy.
public typealias RedisRetryStrategyCB = ( RedisRetryInfo ) -> RedisRetryResult


/// Object passed to the RetryStrategy callback. Contains information on the
/// number of tries etc.
public struct RedisRetryInfo {
  
  var attempt         : Int    = 0
  var totalRetryTime  : Date   = Date()
  var timesConnected  : Int    = 0
  var lastSocketError : Error? = nil
  
  mutating func registerSuccessfulConnect() {
    self.timesConnected  += 1
    self.totalRetryTime  = Date()
    self.lastSocketError = nil
    self.attempt         = 0
  }
}

public enum RedisRetryResult {
  case retryAfter(TimeInterval)
  case error(Swift.Error)
  case stop
}

/// This way the callback can do a simple:
///
///     return 250
///
/// instead of
///
///     return .RetryAfter(0.250)
///
/// To retry after 250ms. Makes it more similar
/// to the original API.
///
extension RedisRetryResult : ExpressibleByIntegerLiteral {
  
  public init(integerLiteral value: Int) { // milliseconds
    self = .retryAfter(TimeInterval(value) / 1000.0)
  }
  
}
