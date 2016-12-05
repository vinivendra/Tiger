import XCTest

class Chapter2Tests: XCTestCase {

	override func setUp() {
		super.setUp()
		let tokens = parse(file: "Chapter 2/test.tig")
		tokens.prettyPrintInLines()
		XCTAssert(tokens.contains(Token(name: "COMMENT_START",
		                                position: 1)!))
		XCTAssert(tokens.contains(Token(name: "COMMENT_START",
		                                position: 40)!))
		XCTAssert(tokens.contains(Token(name: "COMMENT_END",
		                                position: 54)!))
		XCTAssert(tokens.contains(Token(name: "COMMENT_END",
		                                position: 62)!))
	}

	func testComments() {

	}
}
