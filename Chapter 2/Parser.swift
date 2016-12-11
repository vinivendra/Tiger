enum Parser {
	public static func parse(file: String) -> [Token] {
		let path = CommandLine.arguments[1] + "/"
		let filename = path + file
		filename.withMutableCString { EM_reset($0) }

		var tokens = [Token]()
		let getNextToken = yylex

		var tokenID = getNextToken()
		while tokenID != 0 {
			let token: Token
			switch tokenID {
			case ID, STRING:
				token = Token(id: tokenID,
				              value: String(cString: yylval.sval))
			case INT:
				token = Token(id: tokenID,
				              value: CInt(yylval.ival))
			default:
				token = Token(id: tokenID)
			}

			tokens.append(token)
			tokenID = getNextToken()
		}

		return tokens
	}
}
