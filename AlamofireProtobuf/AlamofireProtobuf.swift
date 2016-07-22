//
//  Alamofire+Protobuf.swift
//  AlamofireProtobuf
//
//  Created by 仕炜 叶 on 16/2/14.
//  Copyright © 2016年 YEP.IO. All rights reserved.
//

import Foundation
import Alamofire
import ProtocolBuffers

public func request(
    method: Alamofire.Method,
    _ URLString: URLStringConvertible,
    message: AbstractMessage)
    -> Request
{
    let policyManager = ServerTrustPolicyManager(policies: ["spdy.api.huipin.yep.io": ServerTrustPolicy.DisableEvaluation])
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    configuration.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
    let manager = Manager(configuration: configuration, serverTrustPolicyManager: policyManager)
    return manager.request(method, URLString, message: message)
}