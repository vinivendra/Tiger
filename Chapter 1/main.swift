
struct ListIterator<T>: IteratorProtocol {
	typealias Element = T

	var node: list<T>?

	init(node: list<T>) {
		self.node = node
	}

	mutating func next() -> T? {
		defer { node = node?.next }
		return node?.value
	}
}

class list<T>: ExpressibleByArrayLiteral, CustomStringConvertible, Sequence {
	let value: T?
	var next: list<T>?

	init(value: T?, next: list<T>?) {
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
			let newNode = list<T>(value: element)
			node.next = newNode
			node = newNode
		}
	}

	//
	var description: String {
		get {
			return description(withSeparator: " -> ")
		}
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
	func inserting(_ item: T?) -> list<T> {
		return list(value: item, next: self)
	}

	func find(withPredicate predicate: (T?) -> Bool) -> T? {
		for element in self {
			if predicate(element) {
				return element
			}
		}

		return nil
	}

	//
	func count() -> UInt {
		return 1 + (next?.count() ?? 0)
	}

	func makeIterator() -> ListIterator<T> {
		return ListIterator<T>(node: self)
	}
}

extension list where T: Equatable {
	func find(item: T?) -> T? {
		return find { $0 == item }
	}
}

//
typealias id = String

enum binop: CustomStringConvertible {
	case plus
	case minus
	case times
	case div

	var description: String {
		get {
			switch self {
			case .plus:
				return "+"
			case .minus:
				return "-"
			case .times:
				return "*"
			case .div:
				return "/"
			}
		}
	}
}

enum InterpretationError: Error {
	case VariableNotFound(String)
}

indirect enum stm: CustomStringConvertible {
	case CompoundStm(stm, stm)
	case AssignStm(id, exp)
	case PrintStm(list<exp>)

	var description: String {
		get {
			switch self {
			case .CompoundStm(let stmA, let stmB):
				return "\(stmA); \(stmB)"
			case .AssignStm(let id, let exp):
				return "\(id) := \(exp)"
			case .PrintStm(let list):
				return "print(\(list.description(withSeparator: ", ")))"
			}
		}
	}

	typealias Environment = list<(id: String, value: Int)>
	@discardableResult
	func interpret(_ table: Environment = []) throws -> Environment {
		var table = table

		do {
			switch self {
			case .CompoundStm(let stmA, let stmB):
				table = try stmA.interpret(table)
				table = try stmB.interpret(table)
			case .AssignStm(let id, let exp):
				let result: Int
				(result: result, table: table) = try exp.interpret(table)
				table = table.inserting((id, result))
			case .PrintStm(let list):
				for exp in list {
					let result: Int
					(result: result, table: table) = try exp.interpret(table)
					print(result, terminator: " ")
				}
				print("")
			}
		} catch (let error) {
			throw error
		}

		return table
	}

	func visit(_ closure: (stm) -> ()) {
		closure(self)

		switch self {
		case .CompoundStm(let stmA, let stmB):
			stmA.visit(closure)
			stmB.visit(closure)
		case .AssignStm(_, let exp):
			exp.visit(closure)
		case .PrintStm(let list):
			for exp in list {
				exp.visit(closure)
			}
		}
	}

	func maxArgs() ->  UInt {
		var result: UInt = 0
		self.visit { (stm: stm) in
			switch stm {
			case .PrintStm(let list):
				result = max(result, list.count())
			default: break
			}
		}
		return result
	}
}

indirect enum exp: CustomStringConvertible {
	case IdExp(id)
	case NumExp(Int)
	case OpExp(exp, binop, exp)
	case EseqExp(stm, exp)

	var description: String {
		get {
			switch self {
			case .IdExp(let id):
				return id
			case .NumExp(let int):
				return "\(int)"
			case .OpExp(let expA, let binop, let expB):
				return "\(expA)\(binop)\(expB)"
			case .EseqExp(let stm, let exp):
				return "(\(stm), \(exp))"
			}
		}
	}

	typealias Environment = list<(id: String, value: Int)>
	@discardableResult
	func interpret(_ table: Environment)
		throws -> (result: Int, table: Environment) {

			var table = table
			let result: Int

			do {
				switch self {
				case .IdExp(let id):
					let optionalBinding = table.find { $0?.id == id }
					guard let binding = optionalBinding else {
						throw InterpretationError.VariableNotFound(id)
					}
					result = binding.value

				case .NumExp(let number):
					result = number

				case .OpExp(let expA, let binOp, let expB):
					let lhs, rhs: Int
					(result: lhs, table: table) = try expA.interpret(table)
					(result: rhs, table: table) = try expB.interpret(table)
					switch binOp {
					case .plus:
						result = lhs + rhs
					case .minus:
						result = lhs - rhs
					case .times:
						result = lhs * rhs
					case .div:
						result = lhs / rhs
					}

				case .EseqExp(let stm, let exp):
					table = try stm.interpret(table)
					(result: result, table: table) = try exp.interpret(table)
				}
			} catch (let error) {
				throw error
			}

			return (result: result, table: table)
	}

	func visit(_ closure: (stm) -> ()) {
		switch self {
		case .IdExp: break
		case .NumExp: break
		case .OpExp(let expA, _, let expB):
			expA.visit(closure)
			expB.visit(closure)
		case .EseqExp(let stm, let exp):
			stm.visit(closure)
			exp.visit(closure)
		}
	}
}

//
let a1 = stm.AssignStm("a", .OpExp(.NumExp(5), .plus, .NumExp(3)))
let l1: list<exp> = [.IdExp("a"), .OpExp(.IdExp("a"), .minus, .NumExp(1))]
let a2 = stm.AssignStm("b", .EseqExp(.PrintStm(l1), .OpExp(.NumExp(10), .times, .IdExp("a"))))
let prog = stm.CompoundStm(a1, .CompoundStm(a2, .PrintStm([.IdExp("b")])))

print(prog)

print(prog.maxArgs())

try! prog.interpret()

