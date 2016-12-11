struct ListIterator<T>: IteratorProtocol {
	typealias Element = T

	var node: List<T>?

	init(node: List<T>) {
		self.node = node
	}

	mutating func next() -> T? {
		defer { node = node?.next }
		return node?.value
	}
}

class List<T>: ExpressibleByArrayLiteral, CustomStringConvertible, Sequence {
	let value: T?
	var next: List<T>?

	init(value: T?, next: List<T>?) {
		self.value = value
		self.next = next
	}

	init(value: T?) {
		self.value = value
		self.next = nil
	}

	required convenience init(arrayLiteral elements: T...) {
		guard let firstElement = elements.first else {
			self.init(value: nil)
			return
		}

		self.init(value: firstElement)
		var node = self
		for element in elements.dropFirst() {
			let newNode = List<T>(value: element)
			node.next = newNode
			node = newNode
		}
	}

	//
	var description: String {
		return description(withSeparator: " -> ")
	}

	func description(withSeparator separator: String) -> String {
		if let value = value {
			if let next = self.next?.description {
				return "\(value)\(separator)\(next)"
			} else {
				return "\(value)"
			}
		} else {
			if let next = self.next?.description {
				return "nil\(separator)\(next)"
			} else {
				return "nil"
			}
		}
	}

	//
	func inserting(_ item: T?) -> List<T> {
		return List(value: item, next: self)
	}

	func find(withPredicate predicate: (T?) -> Bool) -> T? {
		for element in self {
			if predicate(element) {
				return element
			}
		}

		return nil
	}

	var last: T? {
		if let next = next {
			return next.last
		} else {
			return self.value
		}
	}

	//
	func count() -> UInt {
		return 1 + (next?.count() ?? 0)
	}

	func makeIterator() -> ListIterator<T> {
		return ListIterator<T>(node: self)
	}
}

extension List where T: Equatable {
	func find(item: T?) -> T? {
		return find { $0 == item }
	}
}
