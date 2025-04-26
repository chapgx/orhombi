package lexer

import "../tokens"
import "core:log"
import "core:testing"

@(test)
test_lexer :: proc(t: ^testing.T) {
	input := "rhombi --val sample -abc"
	l := new_lexer(input)

	expected := [8]tokens.Token {
		tokens.Token{tokens.IDENT, "rhombi"},
		tokens.Token{tokens.DOUBLE_DASH, "--"},
		tokens.Token{tokens.IDENT, "val"},
		tokens.Token{tokens.IDENT, "sample"},
		tokens.Token{tokens.SINGLE_DASH, "-"},
		tokens.Token{tokens.IDENT, "a"},
		tokens.Token{tokens.IDENT, "b"},
		tokens.Token{tokens.IDENT, "c"},
	}


	for tok in expected {
		lextok := next_token(l)

		testing.expectf(t, lextok.Type == tok.Type, "expected %s got %s", tok.Type, lextok.Type)
		testing.expectf(
			t,
			lextok.Literal == tok.Literal,
			"expected %s got %s",
			tok.Literal,
			lextok.Literal,
		)
	}


	free_all(context.allocator)
}
