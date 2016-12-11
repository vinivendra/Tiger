import XCTest

class Chapter1Tests: XCTestCase {
	func testExampleProgram() {
		Statement.shouldPrintToString = true

		let a1 = Statement.assign("a",
		                          .operation(.number(5), .plus, .number(3)))
		let l1: List<Expression> = [.id("a"),
		                            .operation(.id("a"), .minus, .number(1))]
		let a2 = Statement.assign("b",
		                          .sequential(.output(l1),
		                                      .operation(.number(10),
		                                                 .times,
		                                                 .id("a"))))
		let prog = Statement.compound(a1, .compound(a2, .output([.id("b")])))
		try! prog.interpret()

		XCTAssertEqual(prog.description,
		               "a := 5+3; b := (print(a, a-1), 10*a); print(b)")

		XCTAssertEqual(prog.maxArgs(), 2)

		XCTAssertEqual(Statement.outputString, "8 7\n80\n")
	}
}
