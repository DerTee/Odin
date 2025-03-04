package os2

import "base:runtime"

@(private="file")
MAX_ATTEMPTS :: 1<<13 // Should be enough for everyone, right?

// Creates a new temperatory file in the directory `dir`.
//
// Opens the file for reading and writing, with 0o666 permissions, and returns the new `^File`.
// The filename is generated by taking a pattern, and adding a randomized string to the end.
// If the pattern includes an "*", the random string replaces the last "*".
// If `dir` is an empty string, `temp_directory()` will be used.
//
// The caller must `close` the file once finished with.
@(require_results)
create_temp_file :: proc(dir, pattern: string) -> (f: ^File, err: Error) {
	TEMP_ALLOCATOR_GUARD()
	dir := dir if dir != "" else temp_directory(temp_allocator()) or_return
	prefix, suffix := _prefix_and_suffix(pattern) or_return
	prefix = temp_join_path(dir, prefix) or_return

	rand_buf: [10]byte
	name_buf := make([]byte, len(prefix)+len(rand_buf)+len(suffix), temp_allocator())

	attempts := 0
	for {
		name := concatenate_strings_from_buffer(name_buf[:], prefix, random_string(rand_buf[:]), suffix)
		f, err = open(name, {.Read, .Write, .Create, .Excl}, 0o666)
		if err == .Exist {
			close(f)
			attempts += 1
			if attempts < MAX_ATTEMPTS {
				continue
			}
			return nil, err
		}
		return f, err
	}
}

mkdir_temp :: make_directory_temp
// Creates a new temporary directory in the directory `dir`, and returns the path of the new directory.
//
// The directory name is generated by taking a pattern, and adding a randomized string to the end.
// If the pattern includes an "*", the random string replaces the last "*".
// If `dir` is an empty tring, `temp_directory()` will be used.
@(require_results)
make_directory_temp :: proc(dir, pattern: string, allocator: runtime.Allocator) -> (temp_path: string, err: Error) {
	TEMP_ALLOCATOR_GUARD()
	dir := dir if dir != "" else temp_directory(temp_allocator()) or_return
	prefix, suffix := _prefix_and_suffix(pattern) or_return
	prefix = temp_join_path(dir, prefix) or_return

	rand_buf: [10]byte
	name_buf := make([]byte, len(prefix)+len(rand_buf)+len(suffix), temp_allocator())

	attempts := 0
	for {
		name := concatenate_strings_from_buffer(name_buf[:], prefix, random_string(rand_buf[:]), suffix)
		err = make_directory(name, 0o700)
		if err == nil {
			return clone_string(name, allocator)
		}
		if err == .Exist {
			attempts += 1
			if attempts < MAX_ATTEMPTS {
				continue
			}
			return "", err
		}
		if err == .Not_Exist {
			if _, serr := stat(dir, temp_allocator()); serr == .Not_Exist {
				return "", serr
			}
		}
		return "", err
	}

}

temp_dir :: temp_directory
@(require_results)
temp_directory :: proc(allocator: runtime.Allocator) -> (string, Error) {
	return _temp_dir(allocator)
}



@(private="file")
temp_join_path :: proc(dir, name: string) -> (string, runtime.Allocator_Error) {
	if len(dir) > 0 && is_path_separator(dir[len(dir)-1]) {
		return concatenate({dir, name}, temp_allocator(),)
	}

	return concatenate({dir, Path_Separator_String, name}, temp_allocator())
}
