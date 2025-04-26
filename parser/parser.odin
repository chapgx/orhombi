package parser

import "../ast"
import lex "../lexer"
import tok "../tokens"
import "core:mem"

@(private)
_cmd_ids: [dynamic]Cmd_Id

Parser :: struct {
	l:          ^lex.Lexer,
	cur_token:  tok.Token,
	peek_token: tok.Token,
}


// Returns a pointer to a new parser
new_parser :: proc(l: ^lex.Lexer) -> ^Parser {
	p := &Parser{}
	p.l = l

	next_token(p)
	next_token(p)

	return p
}


next_token :: proc(p: ^Parser, alloc := context.allocator) {
	p.cur_token = p.peek_token
	p.peek_token = lex.next_token(p.l, alloc)
}


peek_token_is :: proc(p: ^Parser, typ: tok.Type) -> bool {
	return p.peek_token.Type == typ
}

expect_peek :: proc(p: ^Parser, t: tok.Type) -> bool {
	if peek_token_is(p, t) {
		next_token(p)
		return true
	} else {
		//TODO: handler error
		return false
	}
}


parse_program :: proc(p: ^Parser, alloc := context.allocator) -> ^ast.Program {
	program := &ast.Program{}
	program.statements = make([dynamic]ast.Statement, 10, alloc)


	//TODO: parsing logic
	for s in program.statements {
		switch t in s {
		case ast.Identifier:

		case ast.DoubleDash:

		case ast.SingleDash:

		}
	}

	return program
}


Cmd_Id :: struct {
	name:  string,
	flags: []Flag_Id,
}

Flag_Id :: struct {
	long:  string,
	short: string,
}


load_commands :: proc(identifiers: ..Cmd_Id, alloc := context.allocator) -> mem.Allocator_Error {
	if _cmd_ids == nil {
		_cmd_ids = make([dynamic]Cmd_Id, 10, alloc)
	}
	_, e := append(&_cmd_ids, ..identifiers)
	return e
}
