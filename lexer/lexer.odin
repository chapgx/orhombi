package lexer


import tok "../tokens"
import "core:bytes"
import "core:log"
import "core:strings"

Lexer :: struct {
	input:         string,
	shorttokens:   string, // tokens for short flags
	stidx:         int, //short token index
	position:      int,
	read_position: int,
	char:          byte,
}

// Creates a new lexer
new_lexer :: proc(input: string, alloc := context.allocator) -> ^Lexer {
	l := new(Lexer, alloc)
	l.input = input
	read_char(l)
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


get_short_tok :: proc(l: ^Lexer) -> u8 {
	if l.stidx >= len(l.shorttokens) {
		l.shorttokens = ""
		l.stidx = 0
		return '0'
	}
	c := l.shorttokens[l.stidx]
	l.stidx += 1
	return c
}


next_token :: proc(l: ^Lexer, alloc := context.allocator) -> tok.Token {
	skip_white_space(l)


	token: tok.Token

	if c := get_short_tok(l); c != '0' {
		token = tok.new_token(tok.IDENT, c)
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
			blen := 10
			buff := make([]byte, blen, alloc)
			read := 0
			for {
				it_is, c := is_next_a_letter(l)
				if !it_is {
					break
				}
				if read >= blen {
					panic("error could not allocate enough memory for short flags")
				}
				buff[read] = c
				read += 1
				read_char(l)
			}
			buff = buff[:read]
			l.shorttokens = cast(string)buff
			l.stidx = 0
		}
	case 0:
		token = tok.new_token(tok.EOF)
	case:
		if is_letter(l) {
			i := read_ident(l)
			token.Type = tok.IDENT
			token.Literal = i
			return token
		} else {
			token = tok.new_token(tok.ILLEGAL, l.char)
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
