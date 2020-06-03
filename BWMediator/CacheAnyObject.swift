//
//  CacheAnyObject.swift
//  BWMediator
//
//  Created by baiwhte on 2020/5/29.
//  Copyright © 2020 baiwhte. All rights reserved.
//

import Foundation

public class CacheAnyObject: NSObject {
    
    private var map: LinkedMap
    
    public override init() {
        self.map = LinkedMap()
    }
    
    public var count: Int {
        get {
            self.map.count
        }
    }
    
    public func contain(key: String) -> Bool {
        return false
    }
    
    subscript (key: String, index: Int = 0) -> AnyObject? {
        get {
            assert(!key.isEmpty, "key is invalid")
            let node = map[key, index]
            return node?.value
        }
        set {
            assert(!key.isEmpty, "key is invalid")
            guard let value = newValue else {
                //删除
                map[key, index] = nil
                return
            }
            let node = map[key, index];
            guard let newNode = node else {
                let newNode = LinkedNode.init(key: key, value: value, index: index)
                map.insertAtHead(node: newNode)
                return
            }
            
            newNode.key = key
            newNode.value = value
            newNode.index = index
            newNode.hits += 1
            if newNode.hits > 3 {
                map.bringToHead(node: node)
            }
        }
    }
    
}
