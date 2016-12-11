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
	case output(List<Expression>)

	var description: String {
		switch self {
		case .compound(let statementA, let statementB):
			return "\(statementA); \(statementB)"
		case .assign(let id, let expression):
			return "\(id) := \(expression)"
		case .output(let list):
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
			case .output(let list):
				for expression in list.dropLast() {
					let result: Int
					(result: result, table: table) =
						try expression.interpret(table)
					Statement.printString(result, terminator: " ")
				}

				if let lastExpression = list.last {
					let result: Int
					(result: result, table: table) =
						try lastExpression.interpret(table)
					Statement.printString(result)
				}
			}
		} catch (let error) {
			throw error
		}

		return table
	}

	//
	static var outputString = ""
	static var shouldPrintToString = false

	static func printString(_ string: Any, terminator: String = "\n") {
		if shouldPrintToString {
			print(string, terminator: terminator, to: &outputString)
		} else {
			print(string, terminator: terminator)
		}
	}

	//
	func visit(_ closure: (Statement) -> ()) {
		closure(self)

		switch self {
		case .compound(let statementA, let statementB):
			statementA.visit(closure)
			statementB.visit(closure)
		case .assign(_, let expression):
			expression.visit(closure)
		case .output(let list):
			for expression in list {
				expression.visit(closure)
			}
		}
	}

	func maxArgs() -> UInt {
		var result: UInt = 0
		self.visit { (statement: Statement) in
			switch statement {
			case .output(let list):
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
