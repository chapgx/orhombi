package rhombi


import "core:fmt"
import "core:log"
import "core:testing"

test_version_cmd :: proc(args: ..string) -> Error {
	log.info("v0.1.0")
	return nil
}
