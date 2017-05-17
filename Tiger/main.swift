// Chapter 1
print("--------- Chapter 1 ---------")
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

// Chapter 2
print("--------- Chapter 2 ---------")
let tokens = Parser.parse(file: "Chapter 2 Tests/testComments.tig")
tokens.prettyPrintInLines()
