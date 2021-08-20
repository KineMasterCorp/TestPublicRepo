//
//  VideoCache.swift
//  FeedUI
//
//  Created by JT3 on 2021/06/24.
//

import Foundation

class VideoInfo {
    private(set) var data = Data()
    private(set) var offset = 0
    private(set) var response: URLResponse
    private(set) var contentLength: Int64 = 0

    init(response: URLResponse) {
        self.response = response
        contentLength = 0
        if let contentRange = response.valueForHeaderField("content-range") {
            let components = contentRange.components(separatedBy: "/")
            if components.count == 2 {
                if let string = components.last,
                   let length = Int64(string){
                    contentLength = length
                }
            }
        }
        
        if contentLength == 0 {
            contentLength = response.expectedContentLength
        }
        
        NSLog("VideoInfo[\(response.url?.lastPathComponent ?? "")] ContentLength: \(contentLength)")
    }

    func store(data newData: Data, offset newOffset: Int) {
        // The data range should be overwrapped to merge. Otherwise, the data will be dropped.
        let downloadedEndOffset = offset + data.count
        guard newOffset <= downloadedEndOffset,
              newOffset + newData.count >= downloadedEndOffset else {
            NSLog("mergeData: drop non-overwrapping data. org(\(offset) ~ \(data.count)), new(\(newOffset) ~ \(newData.count))")
            return
        }
        let removeCount = Int(downloadedEndOffset - newOffset)
        let newRange = (removeCount..<newData.count)
        data.append(newData.subdata(in: newRange))
        
//        NSLog("mergeData: org(\(offset) ~ \(downloadedEndOffset)), new(\(newOffset) ~ \(newData.count)), afterMerge(\(data.count))")
    }

    func getData(from offset: Int, length: Int?) -> Data? {
        guard offset < self.offset + Int(data.count) else {
            return nil
        }
        
        var returnLength = self.offset + Int(data.count) - offset
        if let requestLength = length, returnLength > requestLength {
            returnLength = requestLength
        }

        return data.subdata(in: offset..<offset+returnLength)
    }
    
    private func getContentLength(from response: URLResponse) {
        
    }
}

class ListNode<Key, Value> {
    var value: Value
    var key: Key
    var next: ListNode?
    var previous: ListNode?
    
    init(value: Value, key: Key, next: ListNode? = nil, previous: ListNode? = nil) {
        self.value = value
        self.key = key
        self.next = next
        self.previous = previous
    }
}

class QueuedLinkedList<Key, Value> {
    var head: ListNode<Key, Value>?
    var tail: ListNode<Key, Value>?
    var count: Int = 0
    
    init() { }
    
    func add(_ key: Key, _ value: Value) -> ListNode<Key, Value>? {
        let node = ListNode(value: value, key: key)
        count += 1
        guard let temphead = head, let _ = tail else {
            head = node; tail = head; return node
        }
        
        temphead.previous = node
        node.next = temphead
        head = node
        return node
    }
    
    func removeLast() -> ListNode<Key, Value>? {
        guard let temptail = tail else { return nil }
        let previous = temptail.previous
        previous?.next = nil
        defer {
            count -= 1
            tail = previous
        }
        return tail
    }
    
    func moveNodeTowardsHead(node: ListNode<Key, Value>) {
        guard head !== node else { return }
        if tail === node { tail = node.previous }
        node.previous?.next = node.next
        node.next?.previous = node.previous
        
        node.next = head
        node.previous = nil
        
        head?.previous = node
        head = node
    }
}

class LRUCache<Key: Hashable, Value>   {
    var data: [Key: ListNode<Key, Value>] = [:]
    let list: QueuedLinkedList<Key, Value> = QueuedLinkedList()
    var maximumSize: Int
    init(maximumSize: Int) {
        guard maximumSize > 0 else { fatalError() }
        self.maximumSize = maximumSize
    }
    
    func add(key: Key, value: Value) {
        NSLog("lru cache adding - \(key)")
        if let node = data[key] {
            list.moveNodeTowardsHead(node: node)
        } else {
            guard let node = list.add(key, value) else { fatalError() }
            data[key] =  node
        }
        
        if list.count > maximumSize {
            guard let node = list.removeLast() else { return }
            data[node.key] = nil
            NSLog("lru cache removing - \(node.key)")
        }
    }
    
    func get(key: Key) -> Value? {
        guard let node = data[key] else { return nil }
        list.moveNodeTowardsHead(node: node)
        //NSLog("---------------------------------------------")
        //NSLog("Moved to head - \(node.key)")
        return node.value
    }
    
    func isValid(key: Key) -> Bool {
        return data[key] != nil
    }
}

class VideoCache {
    private let cache: LRUCache<String, VideoInfo>
    
    init(capacity: Int) {
        cache = LRUCache<String, VideoInfo>(maximumSize: capacity)
    }
    
    func set(for url: URL, with response: URLResponse) {
        let videoInfo = VideoInfo(response: response)
        cache.add(key: url.absoluteString, value: videoInfo)
    }
    
    func cache(for url: URL) -> VideoInfo? {
        return cache.get(key: url.absoluteString)
    }
    
    func isCompleted(for url: URL) -> (Bool, Error?) {
        return (true, nil)
    }
}

public extension URLResponse {
    func valueForHeaderField(_ headerField: String) -> String? {
        guard let response = self as? HTTPURLResponse else { return nil }
        if #available(iOS 13.0, *) {
            return response.value(forHTTPHeaderField: headerField)
        } else {
            return (response.allHeaderFields as NSDictionary)[headerField] as? String
        }
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
