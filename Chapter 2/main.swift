public struct Token: CustomStringConvertible, Equatable {
	public static func == (lhs: Token, rhs: Token) -> Bool {
		return lhs.id == rhs.id
			&& lhs.position == rhs.position
			&& lhs.value == rhs.value
	}

	let id: CInt
	let position: CInt
	let value: SemanticValue?

	var name: String {
		get {
			precondition(
				id >= Token.namesBaseIndex &&
				id <= Token.namesBaseIndex + Token.namesCount)
			return Token.names[id - Token.namesBaseIndex]
		}
	}

	init(id: CInt, position: CInt = EM_tokPos, value: SemanticValue? = nil) {
		self.id = id
		self.position = position
		self.value = value
	}

	init?(name: String,
	      position: CInt = EM_tokPos,
	      value: SemanticValue? = nil) {
		guard let id = Token.names.index(of: name) else { return nil }
		self.init(id: CInt(id) + Token.namesBaseIndex,
		          position: position,
		          value: value)
	}

	//
	enum SemanticValue: CustomStringConvertible, Equatable {
		public static func == (lhs: SemanticValue, rhs: SemanticValue) -> Bool {
			switch (lhs, rhs) {
			case (.int(let lhsInt), .int(let rhsInt)):
				return lhsInt == rhsInt
			case (.string(let lhsString), .string(let rhsString)):
				return lhsString == rhsString
			default:
				return false
			}
		}

		case int(CInt)
		case string(String)

		var description: String {
			get {
				switch self {
				case .int(let int):
					return String(int)
				case .string(let string):
					return string
				}
			}
		}
	}

	private static let namesBaseIndex: CInt = 257
	private static let namesCount: CInt = CInt(names.count)
	private static let names = [
		"ID", "STRING", "INT", "COMMA", "COLON", "SEMICOLON", "LPAREN",
		"RPAREN", "LBRACK", "RBRACK", "LBRACE", "RBRACE", "DOT", "PLUS",
		"MINUS", "TIMES", "DIVIDE", "EQ", "NEQ", "LT", "LE", "GT", "GE",
		"AND", "OR", "ASSIGN", "ARRAY", "IF", "THEN", "ELSE", "WHILE", "FOR",
		"TO", "DO", "LET", "IN", "END", "OF", "BREAK", "NIL", "FUNCTION",
		"VAR", "TYPE",
		//
		"COMMENT_START", "COMMENT_END"
	]

	//
	public var description: String {
		get {
			if let value = self.value?.description {
				return "(\(name) at \(position): \(value))"
			} else {
				return "(\(name) at \(position))"
			}
		}
	}
}

//
public func parse(file: String) -> [Token] {
	let path = CommandLine.arguments[1] + "/"
	let filename = path + file
	filename.withMutableCString { EM_reset($0) }

	var tokens = [Token]()

	var tokenID = yylex()
	while tokenID != 0 {
		defer { tokenID = yylex() }

		let token: Token
		switch tokenID {
		case ID, STRING:
			token = Token(id: tokenID,
			              value: .string(String(describing: yylval.sval)))
		case INT:
			token = Token(id: tokenID,
			              value: .int(CInt(yylval.ival)))
		default:
			token = Token(id: tokenID)
		}

		tokens.append(token)
	}

	return tokens
}

let tokens = parse(file: "Chapter 2/test.tig")
tokens.prettyPrintInLines()
