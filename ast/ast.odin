package ast

import tok "../tokens"

Statement :: union {
	Identifier,
	SingleDash,
	DoubleDash,
}

Identifier :: struct {
	token: tok.Token,
	value: string,
}


SingleDash :: struct {
}


DoubleDash :: struct {
	token: tok.Token,
	name:  ^Identifier,
}


Program :: struct {
	statements: [dynamic]Statement,
}


// Retrieves the token literal
token_literal :: proc(node: ^$T) -> string {
	return node.token.Literal
}
