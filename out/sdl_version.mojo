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

"""Version

Functionality to query the current SDL version, both as headers the app was
compiled against, and a library the app is linked to.
"""


fn get_version() -> c_int:
    """Get the version of SDL that is linked against your program.

    If you are linking to SDL dynamically, then it is possible that the current
    version will be different than the version you compiled against. This
    function returns the current version, while SDL_VERSION is the version you
    compiled with.

    This function may be called safely at any time, even before SDL_Init().

    Returns:
        The version of the linked library.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetVersion.
    """

    return _get_dylib_function[lib, "SDL_GetVersion", fn () -> c_int]()()


fn get_revision() -> Ptr[c_char, mut=False]:
    """Get the code revision of SDL that is linked against your program.

    This value is the revision of the code you are linked with and may be
    different from the code you are compiling with, which is found in the
    constant SDL_REVISION.

    The revision is arbitrary string (a hash value) uniquely identifying the
    exact revision of the SDL library in use, and is only useful in comparing
    against other revisions. It is NOT an incrementing number.

    If SDL wasn't built from a git repository with the appropriate tools, this
    will return an empty string.

    You shouldn't use this function for anything but logging it for debugging
    purposes. The string is not intended to be reliable in any way.

    Returns:
        An arbitrary string, uniquely identifying the exact revision of
        the SDL library in use.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRevision.
    """

    return _get_dylib_function[lib, "SDL_GetRevision", fn () -> Ptr[c_char, mut=False]]()()
