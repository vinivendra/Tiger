// TODO: Parse ID's
// TODO: Parse all other tokens in Tiger

import XCTest

class Chapter2Tests: XCTestCase {
	func testComments() {
		let tokens = Parser.parse(file: "Common/Test files/testComments.tig")

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
		let tokens = Parser.parse(file: "Common/Test files/testIDs.tig")
    print(tokens)
    let ids: [(position: CInt, value: String)] =
      [(33, "foo"), (37, "bar"), (103, "baz"), (107, "blah"), (112, "b0lah"),
       (118, "b0l0ah"), (125, "blah0"), (131, "b0lah_"), (138, "b_lah"),
       (144, "b_l_ah")]

    for id in ids {
      XCTAssert(tokens.contains(Token(name: "ID",
                                      position: id.position,
                                      value: id.value)!))
    }

    XCTAssertEqual(tokens.filter { $0.name == "ID" }.count, ids.count)
	}

  func testTypes() {
    let tokens = Parser.parse(file: "Common/Test files/testIDs.tig")
    print(tokens)

    let types: [(position: CInt, value: String)] =
      [(152, "HUE"), (156, "Hue"), (160, "Hue_"), (165, "Hue2"),
       (170, "Hue2hue"), (178, "H_ue"), (183, "H_u_e"), (189, "Hue_2_hue")]

    for type in types {
      XCTAssert(tokens.contains(Token(name: "TYPE",
                                      position: type.position,
                                      value: type.value)!))
    }

    XCTAssertEqual(tokens.filter { $0.name == "TYPE" }.count, types.count)
  }
}
