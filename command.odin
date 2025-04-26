package rhombi


import "core:fmt"
import "core:log"

// Run function signature
RunFn :: proc(args: ..string) -> Error


Command :: struct {
	Name:        string,
	Desc:        string,
	LongDesc:    string,
	Run:         RunFn,
	Subs:        []^Command,
	Flags:       []^Flag,
	subs_index:  int,
	flags_index: int,
}


@(private)
init_flags :: proc(length: int, alloc := context.allocator) -> []^Flag {
	//TODO: not sure if this is the best way. Deep research this
	arr := make([]^Flag, length, alloc)
	return arr
}

// Add sub commands to command
add_subs :: proc(cmd: ^Command, commands: ..^Command) -> Error {

	if len(cmd.Subs) == 0 {
		return Error.SubsNotSet
	}

	if cmd.subs_index >= len(cmd.Subs) - 1 {
		return Error.SubsSliceFull
	}


	if len(commands) > (len(cmd.Subs) - cmd.subs_index) - 1 {
		return Error.NoCapForSubs
	}

	for c in commands {
		cmd.Subs[cmd.subs_index] = c
		cmd.subs_index += 1
	}

	return nil
}

// Add flags to command
add_flags :: proc(cmd: ^Command, flags: ..^Flag, alloc := context.allocator) -> Error {

	if cmd.Flags == nil {
		// cmd.Flags = init_flags(5)
	}

	if len(cmd.Flags) == 0 {
		return Error.FlagsNotSet
	}


	if cmd.flags_index >= len(cmd.Flags) - 1 && cmd.flags_index != 0 {
		return Error.FlagsSliceFull
	}

	if len(flags) > (len(cmd.Flags) - cmd.flags_index) - 1 && cmd.flags_index != 0 {
		return Error.NoCapForFlags
	}

	for f in flags {
		cmd.Flags[cmd.flags_index] = f
		cmd.flags_index += 1
	}

	return nil
}
