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

//
enum BinaryOperation: CustomStringConvertible {
	case plus
	case minus
	case times
	case div

	var description: String {
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

enum InterpretationError: Error {
	case VariableNotFound(String)
}

indirect enum Statement: CustomStringConvertible {
	case compound(Statement, Statement)
	case assign(String, Expression)
	case print(List<Expression>)

	var description: String {
		switch self {
		case .compound(let statementA, let statementB):
			return "\(statementA); \(statementB)"
		case .assign(let id, let expression):
			return "\(id) := \(expression)"
		case .print(let list):
			return "print(\(list.description(withSeparator: ", ")))"
		}
	}

	typealias Environment = List<(id: String, value: Int)>
	@discardableResult
	func interpret(_ table: Environment = []) throws -> Environment {
		var table = table

		do {
			switch self {
			case .compound(let statementA, let statementB):
				table = try statementA.interpret(table)
				table = try statementB.interpret(table)
			case .assign(let id, let expression):
				let result: Int
				(result: result, table: table) = try expression.interpret(table)
				table = table.inserting((id, result))
			case .print(let list):
				for expression in list {
					let result: Int
					(result: result, table: table) =
						try expression.interpret(table)
					print(result, terminator: " ")
				}
				print("")
			}
		} catch (let error) {
			throw error
		}

		return table
	}

	func visit(_ closure: (Statement) -> ()) {
		closure(self)

		switch self {
		case .compound(let statementA, let statementB):
			statementA.visit(closure)
			statementB.visit(closure)
		case .assign(_, let expression):
			expression.visit(closure)
		case .print(let list):
			for expression in list {
				expression.visit(closure)
			}
		}
	}

	func maxArgs() -> UInt {
		var result: UInt = 0
		self.visit { (statement: Statement) in
			switch statement {
			case .print(let list):
				result = max(result, list.count())
			default: break
			}
		}
		return result
	}
}

indirect enum Expression: CustomStringConvertible {
	case id(String)
	case number(Int)
	case operation(Expression, BinaryOperation, Expression)
	case sequential(Statement, Expression)

	var description: String {
		switch self {
		case .id(let id):
			return id
		case .number(let int):
			return "\(int)"
		case .operation(let expressionA,
		                let binaryOperation,
		                let expressionB):
			return "\(expressionA)\(binaryOperation)\(expressionB)"
		case .sequential(let statement, let expression):
			return "(\(statement), \(expression))"
		}
	}

	typealias Environment = List<(id: String, value: Int)>
	@discardableResult
	func interpret(_ table: Environment)
		throws -> (result: Int, table: Environment) {

			var table = table
			let result: Int

			do {
				switch self {
				case .id(let id):
					let optionalBinding = table.find { $0?.id == id }
					guard let binding = optionalBinding else {
						throw InterpretationError.VariableNotFound(id)
					}
					result = binding.value

				case .number(let number):
					result = number

				case .operation(let expressionA, let binOp, let expressionB):
					let lhs, rhs: Int
					(result: lhs, table: table) = try expressionA.interpret(table)
					(result: rhs, table: table) = try expressionB.interpret(table)
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

				case .sequential(let statement, let expression):
					table = try statement.interpret(table)
					(result: result, table: table) = try expression.interpret(table)
				}
			} catch (let error) {
				throw error
			}

			return (result: result, table: table)
	}

	func visit(_ closure: (Statement) -> ()) {
		switch self {
		case .id: break
		case .number: break
		case .operation(let expressionA, _, let expressionB):
			expressionA.visit(closure)
			expressionB.visit(closure)
		case .sequential(let statement, let expression):
			statement.visit(closure)
			expression.visit(closure)
		}
	}
}

//
let a1 = Statement.assign("a", .operation(.number(5), .plus, .number(3)))
let l1: List<Expression> = [.id("a"), .operation(.id("a"), .minus, .number(1))]
let a2 = Statement.assign("b",
                          .sequential(.print(l1),
                                      .operation(.number(10),
                                                 .times,
                                                 .id("a"))))
let prog = Statement.compound(a1, .compound(a2, .print([.id("b")])))

print(prog)

print(prog.maxArgs())

try! prog.interpret()
