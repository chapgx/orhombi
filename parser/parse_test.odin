package parser


import "../ast/"
import "../lexer"
import "../tokens/"
import "core:log"
import "core:mem"
import "core:testing"

@(test)
test_command_satetement :: proc(t: ^testing.T) {
	arena: mem.Arena
	buff: [1024 * 5]byte
	mem.arena_init(&arena, buff[:])
	alloc := mem.arena_allocator(&arena)
	context.allocator = alloc
	defer free_all(alloc)

	input := "rhombi help"
	tokens.add_command_kw("rhombi")
	tokens.add_command_kw("help")

	l := lexer.new_lexer(input)
	p := new_parser(&l)

	program := parse_program(&p)

	testing.expectf(
		t,
		2 == len(program.statements),
		"expected %d statement got $d",
		2,
		len(program.statements),
	)

	tests := [2]string{"rhombi", "help"}


	for tt, i in tests {
		statement := program.statements[i]
		testing.expectf(
			t,
			ast.token_literal(statement) == tt,
			"expected %q got %q",
			tt,
			ast.token_literal(statement),
		)
	}

}


@(test)
test_flag_statement :: proc(t: ^testing.T) {
	arena: mem.Arena
	buff: [1024 * 5]byte
	mem.arena_init(&arena, buff[:])
	alloc := mem.arena_allocator(&arena)
	context.allocator = alloc
	defer free_all(alloc)

	input := "rhombi --del all -d 12 34"
	tokens.add_command_kw("rhombi")

	l := lexer.new_lexer(input)
	p := new_parser(&l)

	program := parse_program(&p)
	// log.info(program.statements)
	check_parse_errors(t, p)


	testing.expectf(
		t,
		len(program.statements) == 3,
		"expected 3 statements got %d",
		len(program.statements),
	)

	test := [3]ast.Statement {
		ast.CommandStatement{token = tokens.new_token(tokens.COMMAND, "rhombi"), value = "rhombi"},
		ast.FlagStatement {
			token = tokens.new_token(tokens.DOUBLE_DASH),
			value = ast.Identifier{token = tokens.new_token(tokens.IDENT, "del"), value = "del"},
		},
		ast.ShortFlagStatement {
			token = tokens.new_token(tokens.SINGLE_DASH),
			value = ast.Identifier{token = tokens.new_token(tokens.SHORT_IDENT, "d"), value = "d"},
		},
	}


	for s in program.statements {
		log.info(s)
	}

	for tt, i in test {
		statement := program.statements[i]
		got := ast.token_literal(statement)
		expected := ast.token_literal(tt)
		testing.expectf(t, got == expected, "expected  %q got %q", expected, got)


		got = ast.token_value(statement)
		expected = ast.token_value(tt)
		testing.expectf(t, got == expected, "expected  %q got %q", expected, got)
	}
}


check_parse_errors :: proc(t: ^testing.T, p: Parser) {

	if len(p.errors) == 0 {
		return
	}


	for e in p.errors {
		log.info(e)
	}

	testing.fail_now(t)
}
