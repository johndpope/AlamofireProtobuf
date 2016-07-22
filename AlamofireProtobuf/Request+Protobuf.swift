//
//  Alamore + Protobuf.swift
//  HuiPin-iOS-Swift
//
//  Created by 仕炜 叶 on 16/1/7.
//  Copyright © 2016年 YEP.IO. All rights reserved.
//

import Foundation
import Alamofire
import ProtocolBuffers



extension Manager {
    
    public func request(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
        message: Message)
        -> Request
    {
        let headers = ["Content-Type" : "application/x-protobuf;charset=UTF-8", "Accept" : "application/x-protobuf;charset=UTF-8"]
        let data = try! message.data()
        let mutableURLRequest = URLRequest(method, URLString, data: data, headers: headers)

        return request(mutableURLRequest)
    }
    
    internal func URLRequest(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
        data: NSData,
        headers: [String: String]? = nil)
        -> NSMutableURLRequest
    {
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: URLString.URLString)!)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let headers = headers {
            for (headerField, headerValue) in headers {
                mutableURLRequest.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
        mutableURLRequest.HTTPBody = data
        
        return mutableURLRequest
    }
    
}

// MARK: - Protobuf

extension Request {
    
    /**
     Creates a response serializer that returns an object constructed from the response data using
     `GeneratedMessageBuilder`.
     
     - returns: A protobuf object response serializer.
     */
    public static func protobufResponseSerializer(
        messageBuilder messageBuilder: MessageBuilder)
        -> ResponseSerializer<Message, NSError>
    {
        return ResponseSerializer { _, response, data, error in
            guard error == nil else { return .Failure(error!) }
            
            //if let response = response where response.statusCode == 204 { return .Success(Abst) }
//
            guard let validData = data where validData.length > 0 else {
                let failureReason = "Protobuf data could not be serialized. Input data was nil or zero length."
                let error = Error.errorWithCode(.PropertyListSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            do {
                let message: Message = try messageBuilder.mergeFromData(data!, extensionRegistry: ExtensionRegistry()).build()
                return .Success(message)
            } catch {
                return .Failure(error as NSError)
            }
        }
    }
    
    /**
     Adds a handler to be called once the request has finished.
     
     - parameter messageBuilder:  The message builder
     - parameter completionHandler: A closure to be executed once the request has finished. The closure takes 3
     arguments: the URL request, the URL response, the server data and the result
     produced while creating the protobuf object.
     
     - returns: The request.
     */
    public func responseProtobuf(
        messageBuilder messageBuilder: MessageBuilder,
        completionHandler: Response<Message, NSError> -> Void)
        -> Self
    {
        return response(
            responseSerializer: Request.protobufResponseSerializer(messageBuilder: messageBuilder),
            completionHandler: completionHandler
        )
    }
}