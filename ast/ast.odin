package ast

import tok "../tokens"
import "core:log"


Statement :: union {
	CommandStatement,
	FlagStatement,
	Identifier,
	ShortFlagStatement,
}


Identifier :: struct {
	token: tok.Token,
	value: string,
}


CommandStatement :: struct {
	token:  tok.Token,
	value:  string,
	values: [dynamic]Identifier,
}


FlagStatement :: struct {
	token:  tok.Token,
	value:  Identifier,
	values: []Identifier,
}

ShortFlagStatement :: struct {
	token:  tok.Token,
	value:  Identifier,
	values: [dynamic]Identifier,
}


Program :: struct {
	statements: [dynamic]Statement,
}


// Retrieves the token literal
token_literal :: proc(node: Statement) -> string {
	literal: string
	switch t in node {
	case FlagStatement:
		literal = t.token.Literal
	case CommandStatement:
		literal = t.token.Literal
	case Identifier:
		literal = t.token.Literal
	case ShortFlagStatement:
		literal = t.token.Literal
	}
	return literal
}


token_value :: proc(node: Statement) -> string {
	val: string
	switch t in node {
	case FlagStatement:
		val = t.value.value
	case CommandStatement:
		val = t.value
	case Identifier:
		val = t.value
	case ShortFlagStatement:
		val = t.value.value
	}
	return val
}
