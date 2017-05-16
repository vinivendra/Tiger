// TODO: Parse ID's
// TODO: Parse all other tokens in Tiger

import XCTest

class Chapter2Tests: XCTestCase {
	func testComments() {
		let tokens = Parser.parse(file: "Chapter 2 Tests/testComments.tig")

		// Simple comment
		XCTAssert(tokens.contains(Token(name: "COMMENT_START",
		                                position: 1)!))
		XCTAssert(tokens.contains(Token(name: "COMMENT_END",
		                                position: 29)!))

		// Nested comment
		XCTAssert(tokens.contains(Token(name: "COMMENT_START",
		                                position: 33)!))
		XCTAssert(tokens.contains(Token(name: "COMMENT_START",
		                                position: 54)!))
		XCTAssert(tokens.contains(Token(name: "COMMENT_END",
		                                position: 79)!))
		XCTAssert(tokens.contains(Token(name: "COMMENT_END",
		                                position: 90)!))

		// Nothing inside the comments
		XCTAssertEqual(tokens.count, 6)
	}

	func testIDs() {
		let tokens = Parser.parse(file: "Chapter 2 Tests/testIDs.tig")
    print(tokens)
		XCTAssert(tokens.contains(Token(name: "ID",
		                                position: 33,
		                                value: "foo")!))
		XCTAssert(tokens.contains(Token(name: "ID",
		                                position: 37,
		                                value: "bar")!))
		XCTAssert(tokens.contains(Token(name: "ID",
		                                position: 103,
		                                value: "baz")!))
		XCTAssert(tokens.contains(Token(name: "ID",
		                                position: 107,
		                                value: "blah")!))

    XCTAssertEqual(tokens.filter { $0.name == "ID" }.count, 4)
	}
}
