extension Array {
	func prettyPrint(initiator: String = "[",
	                 separator: String = ", ",
	                 terminator: String = "]") {
		let count = self.count
		guard let lastElement = self.last else {
			print(initiator + terminator)
			return
		}
		guard count > 1 else {
			print(initiator + "\(self[0])" + terminator)
			return
		}

		for element in self.dropLast() {
			print("\(element)" + separator, terminator: "")
		}

		print("\(lastElement)" + terminator)
	}

	func prettyPrintInLines() {
		self.prettyPrint(initiator: "", separator: "\n", terminator: "")
	}

	subscript (safe index: Int) -> Element? {
		guard index < count else { return nil }
		return self[index]
	}
}

extension String {
	public func withMutableCString<Result>(
		_ closure: @escaping (UnsafeMutablePointer<Int8>) throws -> Result)
		rethrows -> Result {

			do {
				return try self.withCString { pointer in
					let mutablePointer = UnsafeMutablePointer<Int8>(
						mutating: pointer)
					return try closure(mutablePointer)
				}
			} catch (let error) {
				throw error
			}
	}
}
