package tokens

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strconv"
import "core:testing"


Type :: string

Token :: struct {
	Type:    Type,
	Literal: string,
}


DOUBLE_DASH: Type : "--"
SINGLE_DASH: Type : "-"
EOF: Type : "EOF"
IDENT: Type : "IDENT"
ILLEGAL: Type : "ILLEGAL"


new_token :: proc {
	new_token_from_type,
	new_token_from_byte,
	new_token_from_string,
}


new_token_from_type :: proc(t: Type) -> Token {
	tok := Token{t, string(t)}
	return tok
}


new_token_from_string :: proc(t: Type, literal: string) -> Token {
	tok: Token
	tok.Type = literal
	return tok
}


new_token_from_byte :: proc(t: Type, literal: byte, alloc := context.allocator) -> Token {
	buff := make([]byte, 1, alloc)
	buff[0] = literal
	s := cast(string)buff
	tok := Token {
		Type    = t,
		Literal = s,
	}
	return tok
}
