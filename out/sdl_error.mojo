# x--------------------------------------------------------------------------x #
# | SDL3 Bindings in Mojo
# x--------------------------------------------------------------------------x #
# | Simple DirectMedia Layer
# | Copyright (C) 1997-2025 Sam Lantinga <slouken@libsdl.org>
# |
# | This software is provided 'as-is', without any express or implied
# | warranty.  In no event will the authors be held liable for any damages
# | arising from the use of this software.
# |
# | Permission is granted to anyone to use this software for any purpose,
# | including commercial applications, and to alter it and redistribute it
# | freely, subject to the following restrictions:
# |
# | 1. The origin of this software must not be misrepresented; you must not
# |    claim that you wrote the original software. If you use this software
# |    in a product, an acknowledgment in the product documentation would be
# |    appreciated but is not required.
# | 2. Altered source versions must be plainly marked as such, and must not be
# |    misrepresented as being the original software.
# | 3. This notice may not be removed or altered from any source distribution.
# x--------------------------------------------------------------------------x #

"""Error

Simple error message routines for SDL.

Most apps will interface with these APIs in exactly one function: when
almost any SDL function call reports failure, you can get a human-readable
string of the problem from SDL_GetError().

These strings are maintained per-thread, and apps are welcome to set their
own errors, which is popular when building libraries on top of SDL for
other apps to consume. These strings are set by calling SDL_SetError().

A common usage pattern is to have a function that returns true for success
and false for failure, and do this when something fails:

```c
if (something_went_wrong) {
   return SDL_SetError("The thing broke in this specific way: %d", errcode);
}
```

It's also common to just return `false` in this case if the failing thing
is known to call SDL_SetError(), so errors simply propagate through.
"""


fn out_of_memory() -> Bool:
    """Set an error indicating that memory allocation failed.

    This function does not do any memory allocation.

    Returns:
        False.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OutOfMemory.
    """

    return _get_dylib_function[lib, "SDL_OutOfMemory", fn () -> Bool]()()


fn get_error() -> Ptr[c_char, mut=False]:
    """Retrieve a message about the last error that occurred on the current
    thread.

    It is possible for multiple errors to occur before calling SDL_GetError().
    Only the last error is returned.

    The message is only applicable when an SDL function has signaled an error.
    You must check the return values of SDL function calls to determine when to
    appropriately call SDL_GetError(). You should *not* use the results of
    SDL_GetError() to decide if an error has occurred! Sometimes SDL will set
    an error string even when reporting success.

    SDL will *not* clear the error string for successful API calls. You *must*
    check return values for failure cases before you can assume the error
    string applies.

    Error strings are set per-thread, so an error set in a different thread
    will not interfere with the current thread's operation.

    The returned value is a thread-local string which will remain valid until
    the current thread's error string is changed. The caller should make a copy
    if the value is needed after the next SDL API call.

    Returns:
        A message with information about the specific error that occurred,
        or an empty string if there hasn't been an error message set since
        the last call to SDL_ClearError().

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetError.
    """

    return _get_dylib_function[lib, "SDL_GetError", fn () -> Ptr[c_char, mut=False]]()()


fn clear_error() -> Bool:
    """Clear any previous error message for this thread.

    Returns:
        True.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ClearError.
    """

    return _get_dylib_function[lib, "SDL_ClearError", fn () -> Bool]()()
