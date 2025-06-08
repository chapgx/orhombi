package parser

import "../ast"
import lex "../lexer"
import tok "../tokens"
import "core:fmt"
import "core:log"
import "core:mem"


MAX_FLAG_VALUES :: 20

Parser :: struct {
	l:          ^lex.Lexer,
	cur_token:  tok.Token,
	peek_token: tok.Token,
	errors:     [dynamic]string,
}


parse_statement :: proc(p: ^Parser) -> ast.Statement {
	switch p.cur_token.Type {
	case tok.COMMAND:
		return parse_command_statement(p)
	case tok.DOUBLE_DASH:
		return parse_flag_statement(p)
	case tok.SINGLE_DASH:
		return parse_short_flag(p)
	case:
		return nil
	}
}

// Parse a flag statement. Allocates memory if flag has values
parse_flag_statement :: proc(p: ^Parser, alloc := context.allocator) -> ast.Statement {
	statement := ast.FlagStatement {
		token = p.cur_token,
	}

	if !expect_peek(p, tok.IDENT) {
		return ast.Statement{}
	}

	statement.value = ast.Identifier {
		token = p.cur_token,
		value = p.cur_token.Literal,
	}

	values := make([]ast.Identifier, MAX_FLAG_VALUES)
	index := 0
	for expect_peek(p, tok.IDENT) {
		v := ast.Identifier {
			token = p.cur_token,
			value = p.cur_token.Literal,
		}
		values[index] = v
		index += 1
	}

	if index == 0 {
		delete(values)
		return statement
	}

	statement.values = values[:index]
	return statement
}

parse_short_flag :: proc(p: ^Parser, alloc := context.allocator) -> ast.Statement {

	if p.cur_token.Type != tok.SINGLE_DASH {
		append(&p.errors, fmt.aprintf("expected single dash got %q", p.cur_token.Type))
		return nil
	}

	statement := ast.ShortFlagStatement {
		token = p.cur_token,
	}


	if !expect_peek(p, tok.SHORT_IDENT) {
		append(&p.errors, fmt.aprintf("expected short ident got %q", p.cur_token.Type))
		return nil
	}


	statement.value = ast.Identifier {
		token = p.cur_token,
		value = p.cur_token.Literal,
	}


	//TODO: need to change this at the root by chaning tokens type
	if !peek_token_is(p, tok.SINGLE_DASH) || !expect_peek(p, tok.DOUBLE_DASH) {
		statement.values = make([dynamic]ast.Identifier, MAX_FLAG_VALUES)
		index := 0
		for expect_peek(p, tok.IDENT) || expect_peek(p, tok.INT) {
			statement.values[index] = ast.Identifier {
				token = p.cur_token,
				value = p.cur_token.Literal,
			}
			index += 1
		}
		shrink(&statement.values, index)
	}

	return statement
}


parse_command_statement :: proc(p: ^Parser) -> ast.Statement {

	statement := ast.CommandStatement {
		token = p.cur_token,
		value = p.cur_token.Literal,
	}


	return statement
}


// Returns a pointer to a new parser
new_parser :: proc(l: ^lex.Lexer, alloc := context.allocator) -> Parser {
	p := Parser {
		l      = l,
		errors = make([dynamic]string),
	}

	next_token(&p)
	next_token(&p)

	return p
}


next_token :: proc(p: ^Parser, alloc := context.allocator) {
	p.cur_token = p.peek_token
	p.peek_token = lex.next_token(p.l, alloc)
}


// Peeks at the next token in the [Lexer]
peek_token_is :: proc(p: ^Parser, typ: tok.Type) -> bool {
	return p.peek_token.Type == typ
}

// Checks the expected next token
expect_peek :: proc(p: ^Parser, t: tok.Type) -> bool {
	if peek_token_is(p, t) {
		next_token(p)
		return true
	} else {
		if p.peek_token.Type == tok.EOF {
			return false
		}
		// append(&p.errors, fmt.aprintf("expected type %q got %q", t, p.peek_token.Type))
		return false
	}
}


// Parse program
parse_program :: proc(p: ^Parser, alloc := context.allocator) -> ast.Program {
	program := ast.Program{}
	statements, e := make([dynamic]ast.Statement, 10, alloc)
	if e != nil {
		panic(fmt.aprintf("memory allocation error: %s\n", e))
	}
	program.statements = statements

	counter := 0
	for p.cur_token.Type != tok.EOF {
		statement := parse_statement(p)
		if statement != nil {
			if counter >= len(program.statements) do append(&program.statements, statement)
			else do program.statements[counter] = statement
			counter += 1
		}

		next_token(p)
	}
	shrink(&program.statements, counter)

	return program
}
