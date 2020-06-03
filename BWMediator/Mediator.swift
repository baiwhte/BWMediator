//
//  Mediator.swift
//  BWMediator
//
//  Created by baiwhte on 2020/5/29.
//  Copyright © 2020 baiwhte. All rights reserved.
//

import Foundation


@objc public class Mediator : NSObject {
    @objc public static let shared = Mediator()
    fileprivate let semaphore = DispatchSemaphore(value: 1)
    
    fileprivate var cache: CacheAnyObject
//    fileprivate var dictionary: Dictionary<String, Any>
    
    private override init() {
        self.cache = CacheAnyObject.init()
    }
    
    @objc public func append(object: AnyObject?, forKey key: String, index: Int = 0) {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        
        guard let value = object else {
            return
        }
        
        self.cache[key, index] = value
    }
    
    @objc(objectForKey:index:)
    public func getObject(key: String, index: Int = 0) -> AnyObject? {
        semaphore.wait()
        defer {
            semaphore.signal()
        }
        
        return self.cache[key, index]
    }
}
