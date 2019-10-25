//
//  LinkedList.swift
//  Pods-SwiftOverpassAPI_Example
//
//  Created by Edward Samson on 10/25/19.
//

import Foundation

class LinkedListNode<T> {
	var value: T
	var next: LinkedListNode?
	
	public init(value: T) {
		self.value = value
	}
}

// A singly linked list
class LinkedList<T> {
	typealias Node = LinkedListNode<T>
	
	private var head: Node?
	private var tail: Node?
	
	var isEmpty: Bool {
		return head == nil
	}
	
	var first: Node? {
		return head
	}
	
	var last: Node? {
		return tail
	}
	
	var count = 0
	
	func append(value: T) {
		let newNode = Node(value: value)
		if let lastNode = last {
			lastNode.next = newNode
		} else {
			head = newNode
		}
		tail = newNode
		count += 1
	}
	
	func node(atIndex index: Int) -> Node {
		if index == 0 {
			return head!
		} else {
			var node = head!.next
			for _ in 1..<index {
				node = node?.next
				if node == nil {
					break
				}
			}
			return node!
		}
	}
	
	func insert(value: T, atIndex index: Int) {
		let newNode = Node(value: value)
		if index == 0 {
			newNode.next = head
			head = newNode
			if tail == nil {
				tail = newNode
			}
		} else {
			let prev = self.node(atIndex: index - 1)
			newNode.next = prev.next
			prev.next = newNode
			if prev === tail {
				tail = newNode
			}
		}
		count += 1
	}
	
	func remove(_ index: Int) -> T {
		if index == 0 {
			let value = head!.value
			
			if let next = head?.next {
				head = next
				count -= 1
			} else {
				removeAll()
			}
			return value
		}
		
		let prev = node(atIndex: index - 1)
		let value = prev.next!.value
		
		if let newNext = prev.next?.next {
			prev.next = newNext
		} else {
			tail = prev
		}
		
		count -= 1
		return value
	}
	
	func removeAll() {
		head = nil
		tail = nil
		count = 0
	}
}
