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

commands: map[string]bool = make(map[string]bool)

DOUBLE_DASH: Type : "--"
SINGLE_DASH: Type : "-"
EOF: Type : "EOF"
IDENT: Type : "IDENT"
SHORT_IDENT: Type : "SHORT_IDENT"
COMMAND: Type : "COMMAND"
ILLEGAL: Type : "ILLEGAL"
QUOTE: Type : "\""
STRING: Type : "STRING"
INT: Type : "INT"

// Adds command as a keyword to the tokens
add_command_kw :: proc(cmd: string) {
	commands[cmd] = true
}


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
	tok := Token{t, literal}
	return tok
}


is_command :: proc(ident: string) -> bool {
	_, exists := commands[ident]
	if exists do return true
	return false
}


// Converts a byte to string.
new_token_from_byte :: proc(t: Type, literal: byte) -> Token {
	//TODO: test the hell out of this in function call relationships
	buff, e := make([]byte, 1, context.allocator)
	assert(e == nil, "allocation of memory for byte failed")
	defer delete(buff, context.allocator)
	buff[0] = literal
	tok := Token {
		Type    = t,
		Literal = string(buff),
	}
	return tok
}
