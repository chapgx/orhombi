package rhombi


import "./tokens"
import "core:fmt"
import "core:log"
import "core:sync"

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
// Sets flags by creating an slice of defined length
init_flags :: proc(length: int, alloc := context.allocator) -> []^Flag {
	//TODO: not sure if this is the best way. Deep research this
	arr := make([]^Flag, length, alloc)
	return arr
}

@(private)
_root: ^Command

@(private)
once: sync.Once


@(private)
// Sets root command
set_root :: proc(cmd: ^Command) {
	sync.once_do(&once, proc() {
		_root = &Command{}
	})
}

// Returns root command. Creates a new root the first time is called
root :: proc() -> ^Command {
	if _root == nil {
		set_root(_root)
	}
	return _root
}


// Set flags for root command by taking a slice from an array
set_root_flags :: proc(flags: []^Flag) -> Error {
	if _root == nil {
		return Error.RootIsNotSet
	}
	_root.Flags = flags
	return nil
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
		tokens.add_command_kw(c.Name)
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
