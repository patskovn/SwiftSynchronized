//
//  Synchronized.swift
//  Pods-SwiftSynchronized_Example
//
//  Created by Пацков Н.Д. on 22/02/2018.
//

import Foundation


extension NSObject {
	

	internal func synchronized<T, U>(value: T, block: (T) -> U) -> U {
		objc_sync_enter(self)
		defer { objc_sync_exit(self) }
		
		return block(value)
	}
	
	internal func synchronized<U>(block: () -> U) -> U {
		objc_sync_enter(self)
		defer { objc_sync_exit(self) }
		
		return block()
	}
	
	func synchronized<U>(block: () throws -> U) rethrows -> U {
		objc_sync_enter(self)
		defer { objc_sync_exit(self) }
		
		return try block()
	}
	
}



public protocol Synchronized {
	
	associatedtype Value
	
	var monitor: NSObject { get }
	
	var object: Value { get set }
	
	init(object: Value)
}


public struct SynchronizedObject<T>: Synchronized {
	
	public var object: T
	
	
	public let monitor: NSObject = NSObject()
	
	
	public init(object: Value) {
		self.object = object
	}
	
}


public struct SynchronizedDictionary<Key: Hashable, Value>: Synchronized {
	
	
	public var object: Dictionary<Key, Value>
	
	public let monitor: NSObject = NSObject()
	
	public init(object: Dictionary<Key, Value>) {
		self.object = object
	}
	
	public subscript(key: Key) -> Value? {
		get {
			return self.monitor.synchronized { object[key] }
		}
		
		set {
			self.monitor.synchronized { object[key] = newValue }
		}
	}
	
	
	public mutating func removeValue(forKey key: Key) -> Value? {
		return self.monitor.synchronized { object.removeValue(forKey: key) }
	}
}


public struct SynchronizedArray<T>: Synchronized {
	
	public var object: Array<T>
	
	public let monitor: NSObject = NSObject()
	
	public init(object: Value) {
		self.object = object
	}
	
	/// The last element of the collection.
	public var last: T? {
		return self.monitor.synchronized { self.object.last }
	}
	
	
	public mutating func append(_ newElement: T) {
		self.monitor.synchronized { self.object.append(newElement) }
	}
	
	
	public mutating func append<S: Sequence>(contentsOf newElements: S) where T == S.Element {
		self.monitor.synchronized { self.object.append(contentsOf: newElements) }
	}
	
	public mutating func insert(_ newElement: T, at i: Int) {
		self.monitor.synchronized { self.object.insert(newElement, at: i) }
	}
	
	public mutating func insert<C>(contentsOf newElements: C, at i: Int) where C : Collection, T == C.Element {
		self.monitor.synchronized { self.object.insert(contentsOf: newElements, at: i) }
	}
	
	public subscript(index: Int) -> T {
		get {
			return self.monitor.synchronized { object[index] }
		}
		
		set {
			self.monitor.synchronized { object[index] = newValue }
		}
	}
}



public struct SynchronizedSet<T: Hashable>: Synchronized {
	
	public var object: Set<T>
	
	public let monitor: NSObject = NSObject()
	
	public init(object: Value) {
		self.object = object
	}
	
	public mutating func insert(_ newMember: T) -> (inserted: Bool, memberAfterInsert: T) {
		return self.monitor.synchronized { object.insert(newMember) }
	}
	
	
	public mutating func remove(_ member: T) -> T? {
		return self.monitor.synchronized { object.remove(member) }
	}
	
	
	public func intersection<S>(_ other: S) -> Set<T> where T == S.Element, S : Sequence {
		return self.monitor.synchronized { object.intersection(other) }
	}
	
	
	public mutating func formIntersection<S>(_ other: S) where T == S.Element, S : Sequence {
		return self.monitor.synchronized { object.formIntersection(other) }
	}
	
	
	public func union<S>(_ other: S) -> Set<T> where T == S.Element, S : Sequence {
		return self.monitor.synchronized { object.union(other) }
	}
	
	
	public mutating func formUnion<S>(_ other: S) where T == S.Element, S : Sequence {
		return self.monitor.synchronized { object.formUnion(other) }
	}
	
	
	public mutating func subtract<S>(_ other: S) where T == S.Element, S : Sequence {
		return self.monitor.synchronized { object.subtract(other) }
	}
	
	
	public func subtracting<S>(_ other: S) -> Set<T> where T == S.Element, S : Sequence {
		return self.monitor.synchronized { object.subtracting(other) }
	}
	
	
	public func isDisjoint<S>(with other: S) -> Bool where T == S.Element, S : Sequence {
		return self.monitor.synchronized { object.isDisjoint(with: other) }
	}
	
}



extension Synchronized where Value: Collection {
	
	/// The first element of the collection.
	public var first: Value.Element? {
		return self.monitor.synchronized { self.object.first }
	}
	
	
	/// A Boolean value indicating whether the collection is empty.
	public var isEmpty: Bool {
		return self.monitor.synchronized { self.object.isEmpty }
	}
	
	
	public var count: Value.IndexDistance {
		return self.monitor.synchronized { self.object.count }
	}
	
	
	public func dropLast() -> Value.SubSequence  {
		return self.monitor.synchronized { object.dropLast() }
	}
	
	
	public func dropLast(_ n: Int) -> Value.SubSequence {
		return self.monitor.synchronized { object.dropLast(n) }
	}
	
	public func dropFirst() -> Value.SubSequence {
		return self.monitor.synchronized { object.dropFirst() }
	}
	
	public func dropFirst(_ n: Int) -> Value.SubSequence {
		return self.monitor.synchronized { object.dropFirst(n) }
	}
	
}


// MARK: - Immutable
extension Synchronized where Value: Collection {
	
	/// Returns the first element of the sequence that satisfies the given predicate or nil if no such element is found.
	///
	/// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
	/// - Returns: The first match or nil if there was no match.
	public func first(where predicate: (Value.Element) throws -> Bool) rethrows -> Value.Element? {
		return try self.monitor.synchronized { try self.object.first(where: predicate) }
	}
	
	/// Returns an array containing, in order, the elements of the sequence that satisfy the given predicate.
	///
	/// - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned array.
	/// - Returns: An array of the elements that includeElement allowed.
	public func filter(_ isIncluded: (Value.Element) throws -> Bool) rethrows -> [Value.Element] {
		return try self.monitor.synchronized { try self.object.filter(isIncluded) }
	}
	
	/// Returns the first index in which an element of the collection satisfies the given predicate.
	///
	/// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
	/// - Returns: The index of the first element for which predicate returns true. If no elements in the collection satisfy the given predicate, returns nil.
	public func index(where predicate: (Value.Element) throws -> Bool) rethrows -> Value.Index? {
		return try self.monitor.synchronized { try self.object.index(where: predicate) }
	}
	
	/// Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
	///
	/// - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
	/// - Returns: A sorted array of the collection’s elements.
	public func sorted(by areInIncreasingOrder: (Value.Element, Value.Element) throws -> Bool) rethrows -> [Value.Element] {
		return try self.monitor.synchronized { try self.object.sorted(by: areInIncreasingOrder) }
	}
	
	/// Returns an array containing the non-nil results of calling the given transformation with each element of this sequence.
	///
	/// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
	/// - Returns: An array of the non-nil results of calling transform with each element of the sequence.
	public func flatMap<ElementOfResult>(_ transform: (Value.Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
		return try self.monitor.synchronized { try self.object.flatMap(transform) }
	}
	
	/// Calls the given closure on each element in the sequence in the same order as a for-in loop.
	///
	/// - Parameter body: A closure that takes an element of the sequence as a parameter.
	public func forEach(_ body: (Value.Element) throws -> Void) rethrows {
		try self.monitor.synchronized { try self.object.forEach(body) }
	}
	
	/// Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
	///
	/// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value that indicates whether the passed element represents a match.
	/// - Returns: true if the sequence contains an element that satisfies predicate; otherwise, false.
	public func contains(where predicate: (Value.Element) throws -> Bool) rethrows -> Bool {
		return try self.monitor.synchronized { try self.object.contains(where: predicate) }
	}
	
	
	public func reduce<Result>(_ initialResult: Result, nextPartialResult: (Result, Value.Element) throws -> Result) rethrows -> Result {
		return try self.monitor.synchronized { try self.object.reduce(initialResult, nextPartialResult) }
	}
	
	
	public func reduce<Result>(into initialResult: Result, updateAccumulatingResult: (inout Result, Value.Element) throws -> ()) rethrows -> Result {
		return try self.monitor.synchronized { try self.object.reduce(into: initialResult, updateAccumulatingResult) }
	}
	
}
