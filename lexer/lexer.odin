package lexer


import tok "../tokens"
import "core:bytes"
import "core:fmt"
import "core:log"
import "core:strings"


MAX_SHORT_FLAGS :: 10

Lexer :: struct {
	input:         string,
	shorttokens:   string, // tokens for short flags
	stidx:         int, //short token index
	position:      int,
	read_position: int,
	char:          byte,
}

// Creates a new lexer
new_lexer :: proc(input: string, alloc := context.allocator) -> Lexer {
	l := Lexer {
		input = input,
	}
	read_char(&l)
	return l
}


@(private)
// Reads next character
read_char :: proc(l: ^Lexer) {
	if l.read_position >= len(l.input) {
		l.char = 0
	} else {
		l.char = l.input[l.read_position]
	}

	l.position = l.read_position
	l.read_position += 1
}


// Retrieves short tokens from `l` until the list is empty out
get_short_toks :: proc(l: ^Lexer) -> u8 {
	if l.stidx >= len(l.shorttokens) {
		l.shorttokens = ""
		l.stidx = 0
		return '0'
	}
	c := l.shorttokens[l.stidx]
	l.stidx += 1
	return c
}

// Returns the next token
next_token :: proc(l: ^Lexer, alloc := context.allocator) -> tok.Token {
	skip_white_space(l)

	token: tok.Token

	if c := get_short_toks(l); c != '0' {
		token = tok.new_token(tok.SHORT_IDENT, c)
		return token
	}

	switch l.char {
	case '-':
		if is_next_char(l, '-') {
			token = tok.new_token(tok.DOUBLE_DASH)
			read_char(l)
		} else {
			token = tok.new_token(tok.SINGLE_DASH)

			//HACK: this can probably be inprove is a hack to be able to lex short flags
			buff, e := make([]byte, MAX_SHORT_FLAGS, alloc)
			assert(e == nil, fmt.aprintf("memory allocation error is not nil, %s", e))
			read := 0
			for {
				itIs, c := is_next_a_letter(l)
				if !itIs {
					break
				}

				if read >= MAX_SHORT_FLAGS {
					//NOTE: this is style choice i don't see the need for more than 10 short flags in a row
					panic("error could not allocate enough memory for short flags")
				}

				buff[read] = c
				read += 1
				read_char(l)
			}
			l.shorttokens = string(buff[:read])
			l.stidx = 0
		}
	case '"':
		token = tok.new_token(tok.QUOTE)
	case 0:
		token = tok.new_token(tok.EOF)
	case:
		if is_letter(l) {
			i := read_ident(l)
			if tok.is_command(i) do return tok.new_token(tok.COMMAND, i)
			return tok.new_token(tok.IDENT, i)
		} else if is_digit(l) {
			digit := concat_digit(l)
			return tok.new_token(tok.INT, digit)
		} else {
			token = tok.new_token(tok.ILLEGAL)
		}
	}

	read_char(l)
	return token
}


@(private)
skip_white_space :: proc(l: ^Lexer) {
	for l.char == ' ' || l.char == '\n' || l.char == '\t' || l.char == '\r' {
		read_char(l)
	}
}

@(private)
is_next_char :: proc(l: ^Lexer, c: byte) -> bool {
	if l.input[l.read_position] == c {
		return true
	}
	return false
}


@(private)
is_letter :: proc(l: ^Lexer) -> bool {
	return 'a' <= l.char && l.char <= 'z' || 'A' <= l.char && l.char <= 'Z' || l.char == '_'
}

@(private)
// Checks if current char is a digit
is_digit :: proc(l: ^Lexer) -> bool {
	return l.char >= '0' && l.char <= '9'
}


@(private)
// Concatunates digits that are not separated by space
concat_digit :: proc(l: ^Lexer) -> string {
	pos := l.position
	for is_digit(l) {
		read_char(l)
	}
	digit := l.input[pos:l.position]
	return digit
}

// Checks if next character is a letter
is_next_a_letter :: proc(l: ^Lexer) -> (bool, u8) {
	if l.read_position >= len(l.input) {
		l.char = 0
		return false, l.char
	}
	c := l.input[l.read_position]
	return ('a' <= c && c <= 'z' || 'A' <= c && c <= 'Z'), c
}


// Returns the next character to to be observed
peek_next_char :: proc(l: ^Lexer) -> byte {
	return l.input[l.read_position]
}

@(private)
read_ident :: proc(l: ^Lexer) -> string {
	pos := l.position
	for is_letter(l) {
		read_char(l)
	}
	ident := l.input[pos:l.position]
	return ident
}
