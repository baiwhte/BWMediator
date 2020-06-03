//
//  LinkedMap.swift
//  BWMediator
//
//  Created by baiwhte on 2020/5/29.
//  Copyright © 2020 baiwhte. All rights reserved.
//

import Foundation


final class LinkedNode: Equatable {
    static func == (lhs: LinkedNode, rhs: LinkedNode) -> Bool {
        return (lhs.index == rhs.index) && (lhs.key == rhs.key)
    }
    
    weak var previous : LinkedNode?
    var next          : LinkedNode?
    
    var index : Int
    var key   : String
    var value : AnyObject
    //缓存命中次数
    var hits  : Int = 1
    
    init(key: String, value: AnyObject, index: Int = 0) {
        self.index = index;
        self.key = key
        self.value = value
    }
    
}

final class LinkedMap {
    
    fileprivate lazy var map: Dictionary<String, LinkedNode> = Dictionary.init()
    
    fileprivate var head: LinkedNode?
    private var tail: LinkedNode?
    var maxCount: Int = 100;
    
    var count: Int {
        get {
            return self.map.count
        }
    }
    
    
    
    func append(node: LinkedNode?) {
        guard let newNode = node else {
            return
        }
        if self.count + 1 > self.maxCount {
            self.removeTail()
        }
        
        if let tailNode = tail {
            newNode.previous = tailNode
            newNode.next     = nil
            
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }
    
    func insertAtHead(node: LinkedNode?) {
        guard let newNode = node else {
            return
        }
        
        if self.count + 1 > self.maxCount {
            self.removeTail()
        }
        
        self[newNode.key, newNode.index] = newNode
        
        if head != nil {
            newNode.next = head
            newNode.previous = nil
            
            head?.previous = newNode
        } else {
            tail = newNode
        }
        
        head = newNode
        #if DEBUG
        self.printNodes()
        #endif
    }
    
    func bringToHead(node: LinkedNode?) {
        guard let newNode = node, head != newNode else {
            return
        }
        if tail == newNode {
            tail = newNode.previous
            tail?.next = nil
        } else {
            newNode.next?.previous = newNode.previous
            newNode.previous?.next = newNode.next
        }
        
        newNode.next = head
        newNode.previous = nil
        
        head?.previous = node
        head = node
        #if DEBUG
        self.printNodes()
        #endif
    }
    
    
    
    func remove(node: LinkedNode?) {
        guard let newNode = node else {
            return
        }
        
        self.map.removeValue(forKey: "\(newNode.key)_\(newNode.index)")
        
        if let next = newNode.next {
            next.previous = newNode.previous
        }
        if let previous = newNode.previous {
            previous.next = newNode.next
        }
        if head == node {
            head = newNode.next
        }
        if tail == node {
            tail = newNode.previous
        }
    }
    
    func removeTail()  {
        self.map.removeValue(forKey: "\(tail?.key ?? "")_\(tail?.index ?? 0)")
        if head == tail {
            removeAll()
        } else {
            tail = tail?.previous
            tail?.next = nil
        }
    }
    
    func removeAll()  {
        head = nil
        tail = nil
        self.map.removeAll()
    }
    
    subscript(key: String, index: Int = 0) -> LinkedNode? {
        get {
            return map["\(key)_\(index)"]
        }
        set {
            map["\(key)_\(index)"] = newValue
        }
    }
    
    #if DEBUG
    func printNodes() {
        var node = head
        while node != nil {
            let newNode = node!;
            print("key:\(newNode.key) index:\(newNode.index) value:\(newNode.value)")
            node = newNode.next
        }
    }
    #endif
    
}
