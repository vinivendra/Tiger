// TODO: Add tests?
// TODO: Consider adding CString lib

func tokname(_ tok: Int32) -> String {
	let toknames = [
		"ID", "STRING", "INT", "COMMA", "COLON", "SEMICOLON", "LPAREN",
		"RPAREN", "LBRACK", "RBRACK", "LBRACE", "RBRACE", "DOT", "PLUS",
		"MINUS", "TIMES", "DIVIDE", "EQ", "NEQ", "LT", "LE", "GT", "GE",
		"AND", "OR", "ASSIGN", "ARRAY", "IF", "THEN", "ELSE", "WHILE", "FOR",
		"TO", "DO", "LET", "IN", "END", "OF", "BREAK", "NIL", "FUNCTION",
		"VAR", "TYPE",
		//
		"COMMENT_START", "COMMENT_END"
	]

	if tok < 257 || tok > 301 {
		return "BAD_TOKEN"
	} else {
		return toknames[tok - 257]
	}
}

typealias CString = UnsafeMutablePointer<Int8>

//
public func parse(file: String) {
	let path = CommandLine.arguments[1] + "/"
	let filename = path + file
	filename.withCString { EM_reset(CString(mutating: $0)) }

	while true {
		let token = yylex()
		if token == 0 {
			break
		}

		switch token {
		case ID:
			print("ID:     \(tokname(token)) \(EM_tokPos) \(yylval.sval)")
		case STRING:
			print("String: \(tokname(token)) \(EM_tokPos) \(yylval.sval)")
		case INT:
			print("Int:    \(tokname(token)) \(EM_tokPos) \(yylval.ival)")
		default:
			print("Other:  \(tokname(token)) \(EM_tokPos)")
		}
	}
}

parse(file: "Chapter 2/test.tig")
