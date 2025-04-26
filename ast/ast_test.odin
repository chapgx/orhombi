package ast

import "../tokens"
import "core:log"
import "core:testing"

@(test)
test_node :: proc(t: ^testing.T) {
	tok := tokens.Token{tokens.IDENT, "rhombi"}
	root := Identifier{tok}
	lit := token_literal(&root)
	testing.expectf(t, lit == "rhombi", "expect %q to be equal  to %q", lit, root.token.Literal)
}
