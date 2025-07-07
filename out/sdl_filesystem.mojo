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

"""Filesystem

SDL offers an API for examining and manipulating the system's filesystem.
This covers most things one would need to do with directories, except for
actual file I/O (which is covered by [CategoryIOStream](CategoryIOStream)
and [CategoryAsyncIO](CategoryAsyncIO) instead).

There are functions to answer necessary path questions:

- Where is my app's data? SDL_GetBasePath().
- Where can I safely write files? SDL_GetPrefPath().
- Where are paths like Downloads, Desktop, Music? SDL_GetUserFolder().
- What is this thing at this location? SDL_GetPathInfo().
- What items live in this folder? SDL_EnumerateDirectory().
- What items live in this folder by wildcard? SDL_GlobDirectory().
- What is my current working directory? SDL_GetCurrentDirectory().

SDL also offers functions to manipulate the directory tree: renaming,
removing, copying files.
"""


fn get_base_path() -> Ptr[c_char, mut=False]:
    """Get the directory where the application was run from.

    SDL caches the result of this call internally, but the first call to this
    function is not necessarily fast, so plan accordingly.

    **macOS and iOS Specific Functionality**: If the application is in a ".app"
    bundle, this function returns the Resource directory (e.g.
    MyApp.app/Contents/Resources/). This behaviour can be overridden by adding
    a property to the Info.plist file. Adding a string key with the name
    SDL_FILESYSTEM_BASE_DIR_TYPE with a supported value will change the
    behaviour.

    Supported values for the SDL_FILESYSTEM_BASE_DIR_TYPE property (Given an
    application in /Applications/SDLApp/MyApp.app):

    - `resource`: bundle resource directory (the default). For example:
      `/Applications/SDLApp/MyApp.app/Contents/Resources`
    - `bundle`: the Bundle directory. For example:
      `/Applications/SDLApp/MyApp.app/`
    - `parent`: the containing directory of the bundle. For example:
      `/Applications/SDLApp/`

    **Nintendo 3DS Specific Functionality**: This function returns "romfs"
    directory of the application as it is uncommon to store resources outside
    the executable. As such it is not a writable directory.

    The returned path is guaranteed to end with a path separator ('\\\\' on
    Windows, '/' on most other platforms).

    Returns:
        An absolute path in UTF-8 encoding to the application data
        directory. NULL will be returned on error or when the platform
        doesn't implement this functionality, call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetBasePath.
    """

    return _get_dylib_function[lib, "SDL_GetBasePath", fn () -> Ptr[c_char, mut=False]]()()


fn get_pref_path(owned org: String, owned app: String) -> Ptr[c_char, mut=True]:
    """Get the user-and-app-specific path where files can be written.

    Get the "pref dir". This is meant to be where users can write personal
    files (preferences and save games, etc) that are specific to your
    application. This directory is unique per user, per application.

    This function will decide the appropriate location in the native
    filesystem, create the directory if necessary, and return a string of the
    absolute path to the directory in UTF-8 encoding.

    On Windows, the string might look like:

    `C:\\\\Users\\\\bob\\\\AppData\\\\Roaming\\\\My Company\\\\My Program Name\\\\`

    On Linux, the string might look like:

    `/home/bob/.local/share/My Program Name/`

    On macOS, the string might look like:

    `/Users/bob/Library/Application Support/My Program Name/`

    You should assume the path returned by this function is the only safe place
    to write files (and that SDL_GetBasePath(), while it might be writable, or
    even the parent of the returned path, isn't where you should be writing
    things).

    Both the org and app strings may become part of a directory name, so please
    follow these rules:

    - Try to use the same org string (_including case-sensitivity_) for all
      your applications that use this function.
    - Always use a unique app string for each one, and make sure it never
      changes for an app once you've decided on it.
    - Unicode characters are legal, as long as they are UTF-8 encoded, but...
    - ...only use letters, numbers, and spaces. Avoid punctuation like "Game
      Name 2: Bad Guy's Revenge!" ... "Game Name 2" is sufficient.

    The returned path is guaranteed to end with a path separator ('\\\\' on
    Windows, '/' on most other platforms).

    Args:
        org: The name of your organization.
        app: The name of your application.

    Returns:
        A UTF-8 string of the user directory in platform-dependent
        notation. NULL if there's a problem (creating directory failed,
        etc.). This should be freed with SDL_free() when it is no longer
        needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPrefPath.
    """

    return _get_dylib_function[lib, "SDL_GetPrefPath", fn (org: Ptr[c_char, mut=False], app: Ptr[c_char, mut=False]) -> Ptr[c_char, mut=True]]()(org.unsafe_cstr_ptr(), app.unsafe_cstr_ptr())


@register_passable("trivial")
struct Folder(Indexer, Intable):
    """The type of the OS-provided default folder for a specific purpose.

    Note that the Trash folder isn't included here, because trashing files
    usually involves extra OS-specific functionality to remember the file's
    original location.

    The folders supported per platform are:

    |             | Windows | macOS/iOS | tvOS | Unix (XDG) | Haiku | Emscripten |
    | ----------- | ------- | --------- | ---- | ---------- | ----- | ---------- |
    | HOME        | X       | X         |      | X          | X     | X          |
    | DESKTOP     | X       | X         |      | X          | X     |            |
    | DOCUMENTS   | X       | X         |      | X          |       |            |
    | DOWNLOADS   | Vista+  | X         |      | X          |       |            |
    | MUSIC       | X       | X         |      | X          |       |            |
    | PICTURES    | X       | X         |      | X          |       |            |
    | PUBLICSHARE |         | X         |      | X          |       |            |
    | SAVEDGAMES  | Vista+  |           |      |            |       |            |
    | SCREENSHOTS | Vista+  |           |      |            |       |            |
    | TEMPLATES   | X       | X         |      | X          |       |            |
    | VIDEOS      | X       | X*        |      | X          |       |            |

    Note that on macOS/iOS, the Videos folder is called "Movies".

    Docs: https://wiki.libsdl.org/SDL3/SDL_Folder.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __eq__(lhs, rhs: Self) -> Bool:
        return lhs.value == rhs.value

    @always_inline("nodebug")
    fn __index__(self) -> __mlir_type.index:
        return Int(self).value

    alias FOLDER_HOME = Self(0x0)
    """The folder which contains all of the current user's data, preferences, and documents. It usually contains most of the other folders. If a requested folder does not exist, the home folder can be considered a safe fallback to store a user's documents."""
    alias FOLDER_DESKTOP = Self(0x1)
    """The folder of files that are displayed on the desktop. Note that the existence of a desktop folder does not guarantee that the system does show icons on its desktop; certain GNU/Linux distros with a graphical environment may not have desktop icons."""
    alias FOLDER_DOCUMENTS = Self(0x2)
    """User document files, possibly application-specific. This is a good place to save a user's projects."""
    alias FOLDER_DOWNLOADS = Self(0x3)
    """Standard folder for user files downloaded from the internet."""
    alias FOLDER_MUSIC = Self(0x4)
    """Music files that can be played using a standard music player (mp3, ogg...)."""
    alias FOLDER_PICTURES = Self(0x5)
    """Image files that can be displayed using a standard viewer (png, jpg...)."""
    alias FOLDER_PUBLICSHARE = Self(0x6)
    """Files that are meant to be shared with other users on the same computer."""
    alias FOLDER_SAVEDGAMES = Self(0x7)
    """Save files for games."""
    alias FOLDER_SCREENSHOTS = Self(0x8)
    """Application screenshots."""
    alias FOLDER_TEMPLATES = Self(0x9)
    """Template files to be used when the user requests the desktop environment to create a new file in a certain folder, such as "New Text File.txt".  Any file in the Templates folder can be used as a starting point for a new file."""
    alias FOLDER_VIDEOS = Self(0xA)
    """Video files that can be played using a standard video player (mp4, webm...)."""
    alias FOLDER_COUNT = Self(0xB)
    """Total number of types in this enum, not a folder type by itself."""


fn get_user_folder(folder: Folder) -> Ptr[c_char, mut=False]:
    """Finds the most suitable user folder for a specific purpose.

    Many OSes provide certain standard folders for certain purposes, such as
    storing pictures, music or videos for a certain user. This function gives
    the path for many of those special locations.

    This function is specifically for _user_ folders, which are meant for the
    user to access and manage. For application-specific folders, meant to hold
    data for the application to manage, see SDL_GetBasePath() and
    SDL_GetPrefPath().

    The returned path is guaranteed to end with a path separator ('\\\\' on
    Windows, '/' on most other platforms).

    If NULL is returned, the error may be obtained with SDL_GetError().

    Args:
        folder: The type of folder to find.

    Returns:
        Either a null-terminated C string containing the full path to the
        folder, or NULL if an error happened.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetUserFolder.
    """

    return _get_dylib_function[lib, "SDL_GetUserFolder", fn (folder: Folder) -> Ptr[c_char, mut=False]]()(folder)


@register_passable("trivial")
struct PathType(Indexer, Intable):
    """Types of filesystem entries.

    Note that there may be other sorts of items on a filesystem: devices,
    symlinks, named pipes, etc. They are currently reported as
    SDL_PATHTYPE_OTHER.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PathType.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __eq__(lhs, rhs: Self) -> Bool:
        return lhs.value == rhs.value

    @always_inline("nodebug")
    fn __index__(self) -> __mlir_type.index:
        return Int(self).value

    alias PATHTYPE_NONE = Self(0x0)
    """Path does not exist."""
    alias PATHTYPE_FILE = Self(0x1)
    """A normal file."""
    alias PATHTYPE_DIRECTORY = Self(0x2)
    """A directory."""
    alias PATHTYPE_OTHER = Self(0x3)
    """Something completely different like a device node (not a symlink, those are always followed)."""


@fieldwise_init
struct PathInfo(Copyable, Movable):
    """Information about a path on the filesystem.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PathInfo.
    """

    var type: PathType
    """The path type."""
    var size: UInt64
    """The file size in bytes."""
    var create_time: Int64
    """The time when the path was created."""
    var modify_time: Int64
    """The last time the path was modified."""
    var access_time: Int64
    """The last time the path was read."""


@register_passable("trivial")
struct GlobFlags(Intable):
    """Flags for path matching.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GlobFlags.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: UInt32):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __or__(lhs, rhs: Self) -> Self:
        return Self(lhs.value | rhs.value)

    alias GLOB_CASEINSENSITIVE = Self(1 << 0)


fn create_directory(owned path: String) raises:
    """Create a directory, and any missing parent directories.

    This reports success if `path` already exists as a directory.

    If parent directories are missing, it will also create them. Note that if
    this fails, it will not remove any parent directories it already made.

    Args:
        path: The path of the directory to create.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateDirectory.
    """

    ret = _get_dylib_function[lib, "SDL_CreateDirectory", fn (path: Ptr[c_char, mut=False]) -> Bool]()(path.unsafe_cstr_ptr())
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


@register_passable("trivial")
struct EnumerationResult(Indexer, Intable):
    """Possible results from an enumeration callback.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EnumerationResult.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    @always_inline
    fn __eq__(lhs, rhs: Self) -> Bool:
        return lhs.value == rhs.value

    @always_inline("nodebug")
    fn __index__(self) -> __mlir_type.index:
        return Int(self).value

    alias ENUM_CONTINUE = Self(0x0)
    """Value that requests that enumeration continue."""
    alias ENUM_SUCCESS = Self(0x1)
    """Value that requests that enumeration stop, successfully."""
    alias ENUM_FAILURE = Self(0x2)
    """Value that requests that enumeration stop, as a failure."""


alias EnumerateDirectoryCallback = fn (userdata: Ptr[NoneType, mut=True], dirname: Ptr[c_char, mut=False], fname: Ptr[c_char, mut=False]) -> EnumerationResult
"""Callback for directory enumeration.
    
    Enumeration of directory entries will continue until either all entries
    have been provided to the callback, or the callback has requested a stop
    through its return value.
    
    Returning SDL_ENUM_CONTINUE will let enumeration proceed, calling the
    callback with further entries. SDL_ENUM_SUCCESS and SDL_ENUM_FAILURE will
    terminate the enumeration early, and dictate the return value of the
    enumeration function itself.
    
    `dirname` is guaranteed to end with a path separator ('\\\\' on Windows, '/'
    on most other platforms).
    
    Args:
        userdata: An app-controlled pointer that is passed to the callback.
        dirname: The directory that is being enumerated.
        fname: The next entry in the enumeration.
    
    Returns:
        How the enumeration should proceed.

Docs: https://wiki.libsdl.org/SDL3/SDL_EnumerateDirectoryCallback.
"""


fn enumerate_directory(owned path: String, callback: EnumerateDirectoryCallback, userdata: Ptr[NoneType, mut=True]) raises:
    """Enumerate a directory through a callback function.

    This function provides every directory entry through an app-provided
    callback, called once for each directory entry, until all results have been
    provided or the callback returns either SDL_ENUM_SUCCESS or
    SDL_ENUM_FAILURE.

    This will return false if there was a system problem in general, or if a
    callback returns SDL_ENUM_FAILURE. A successful return means a callback
    returned SDL_ENUM_SUCCESS to halt enumeration, or all directory entries
    were enumerated.

    Args:
        path: The path of the directory to enumerate.
        callback: A function that is called for each entry in the directory.
        userdata: A pointer that is passed to `callback`.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_EnumerateDirectory.
    """

    ret = _get_dylib_function[lib, "SDL_EnumerateDirectory", fn (path: Ptr[c_char, mut=False], callback: EnumerateDirectoryCallback, userdata: Ptr[NoneType, mut=True]) -> Bool]()(path.unsafe_cstr_ptr(), callback, userdata)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn remove_path(owned path: String) raises:
    """Remove a file or an empty directory.

    Directories that are not empty will fail; this function will not recursely
    delete directory trees.

    Args:
        path: The path to remove from the filesystem.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RemovePath.
    """

    ret = _get_dylib_function[lib, "SDL_RemovePath", fn (path: Ptr[c_char, mut=False]) -> Bool]()(path.unsafe_cstr_ptr())
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn rename_path(owned oldpath: String, owned newpath: String) raises:
    """Rename a file or directory.

    If the file at `newpath` already exists, it will replaced.

    Note that this will not copy files across filesystems/drives/volumes, as
    that is a much more complicated (and possibly time-consuming) operation.

    Which is to say, if this function fails, SDL_CopyFile() to a temporary file
    in the same directory as `newpath`, then SDL_RenamePath() from the
    temporary file to `newpath` and SDL_RemovePath() on `oldpath` might work
    for files. Renaming a non-empty directory across filesystems is
    dramatically more complex, however.

    Args:
        oldpath: The old path.
        newpath: The new path.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RenamePath.
    """

    ret = _get_dylib_function[lib, "SDL_RenamePath", fn (oldpath: Ptr[c_char, mut=False], newpath: Ptr[c_char, mut=False]) -> Bool]()(oldpath.unsafe_cstr_ptr(), newpath.unsafe_cstr_ptr())
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn copy_file(owned oldpath: String, owned newpath: String) raises:
    """Copy a file.

    If the file at `newpath` already exists, it will be overwritten with the
    contents of the file at `oldpath`.

    This function will block until the copy is complete, which might be a
    significant time for large files on slow disks. On some platforms, the copy
    can be handed off to the OS itself, but on others SDL might just open both
    paths, and read from one and write to the other.

    Note that this is not an atomic operation! If something tries to read from
    `newpath` while the copy is in progress, it will see an incomplete copy of
    the data, and if the calling thread terminates (or the power goes out)
    during the copy, `newpath`'s previous contents will be gone, replaced with
    an incomplete copy of the data. To avoid this risk, it is recommended that
    the app copy to a temporary file in the same directory as `newpath`, and if
    the copy is successful, use SDL_RenamePath() to replace `newpath` with the
    temporary file. This will ensure that reads of `newpath` will either see a
    complete copy of the data, or it will see the pre-copy state of `newpath`.

    This function attempts to synchronize the newly-copied data to disk before
    returning, if the platform allows it, so that the renaming trick will not
    have a problem in a system crash or power failure, where the file could be
    renamed but the contents never made it from the system file cache to the
    physical disk.

    If the copy fails for any reason, the state of `newpath` is undefined. It
    might be half a copy, it might be the untouched data of what was already
    there, or it might be a zero-byte file, etc.

    Args:
        oldpath: The old path.
        newpath: The new path.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CopyFile.
    """

    ret = _get_dylib_function[lib, "SDL_CopyFile", fn (oldpath: Ptr[c_char, mut=False], newpath: Ptr[c_char, mut=False]) -> Bool]()(oldpath.unsafe_cstr_ptr(), newpath.unsafe_cstr_ptr())
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_path_info(owned path: String, info: Ptr[PathInfo, mut=True]) raises:
    """Get information about a filesystem path.

    Args:
        path: The path to query.
        info: A pointer filled in with information about the path, or NULL to
              check for the existence of a file.

    Raises:
        Raises if the file doesn't exist, or another
        failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetPathInfo.
    """

    ret = _get_dylib_function[lib, "SDL_GetPathInfo", fn (path: Ptr[c_char, mut=False], info: Ptr[PathInfo, mut=True]) -> Bool]()(path.unsafe_cstr_ptr(), info)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn glob_directory(owned path: String, owned pattern: String, flags: GlobFlags, count: Ptr[c_int, mut=True], out ret: Ptr[Ptr[c_char, mut=True], mut=True]) raises:
    """Enumerate a directory tree, filtered by pattern, and return a list.

    Files are filtered out if they don't match the string in `pattern`, which
    may contain wildcard characters '\\*' (match everything) and '?' (match one
    character). If pattern is NULL, no filtering is done and all results are
    returned. Subdirectories are permitted, and are specified with a path
    separator of '/'. Wildcard characters '\\*' and '?' never match a path
    separator.

    `flags` may be set to SDL_GLOB_CASEINSENSITIVE to make the pattern matching
    case-insensitive.

    The returned array is always NULL-terminated, for your iterating
    convenience, but if `count` is non-NULL, on return it will contain the
    number of items in the array, not counting the NULL terminator.

    Args:
        path: The path of the directory to enumerate.
        pattern: The pattern that files in the directory must match. Can be
                 NULL.
        flags: `SDL_GLOB_*` bitflags that affect this search.
        count: On return, will be set to the number of items in the returned
               array. Can be NULL.

    Returns:
        An array of strings on success or NULL on failure; call
        SDL_GetError() for more information. This is a single allocation
        that should be freed with SDL_free() when it is no longer needed.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GlobDirectory.
    """

    ret = _get_dylib_function[lib, "SDL_GlobDirectory", fn (path: Ptr[c_char, mut=False], pattern: Ptr[c_char, mut=False], flags: GlobFlags, count: Ptr[c_int, mut=True]) -> Ptr[Ptr[c_char, mut=True], mut=True]]()(path.unsafe_cstr_ptr(), pattern.unsafe_cstr_ptr(), flags, count)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_current_directory() -> Ptr[c_char, mut=True]:
    """Get what the system believes is the "current working directory.".

    For systems without a concept of a current working directory, this will
    still attempt to provide something reasonable.

    SDL does not provide a means to _change_ the current working directory; for
    platforms without this concept, this would cause surprises with file access
    outside of SDL.

    The returned path is guaranteed to end with a path separator ('\\\\' on
    Windows, '/' on most other platforms).

    Returns:
        A UTF-8 string of the current working directory in
        platform-dependent notation. NULL if there's a problem. This
        should be freed with SDL_free() when it is no longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCurrentDirectory.
    """

    return _get_dylib_function[lib, "SDL_GetCurrentDirectory", fn () -> Ptr[c_char, mut=True]]()()
