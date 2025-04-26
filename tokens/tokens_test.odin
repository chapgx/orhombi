package tokens


import "core:log"
import "core:testing"


@(test)
test_new_token_from_byte :: proc(t: ^testing.T) {
	b: byte = 'j'
	tok := new_token_from_byte(ILLEGAL, b)
	log.infof("%+v", tok)
	testing.expect_value(t, tok.Literal, "j")
	free_all(context.allocator)
}
