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

"""Audio

Audio functionality for the SDL library.

All audio in SDL3 revolves around SDL_AudioStream. Whether you want to play
or record audio, convert it, stream it, buffer it, or mix it, you're going
to be passing it through an audio stream.

Audio streams are quite flexible; they can accept any amount of data at a
time, in any supported format, and output it as needed in any other format,
even if the data format changes on either side halfway through.

An app opens an audio device and binds any number of audio streams to it,
feeding more data to the streams as available. When the device needs more
data, it will pull it from all bound streams and mix them together for
playback.

Audio streams can also use an app-provided callback to supply data
on-demand, which maps pretty closely to the SDL2 audio model.

SDL also provides a simple .WAV loader in SDL_LoadWAV (and SDL_LoadWAV_IO
if you aren't reading from a file) as a basic means to load sound data into
your program.

## Logical audio devices

In SDL3, opening a physical device (like a SoundBlaster 16 Pro) gives you a
logical device ID that you can bind audio streams to. In almost all cases,
logical devices can be used anywhere in the API that a physical device is
normally used. However, since each device opening generates a new logical
device, different parts of the program (say, a VoIP library, or
text-to-speech framework, or maybe some other sort of mixer on top of SDL)
can have their own device opens that do not interfere with each other; each
logical device will mix its separate audio down to a single buffer, fed to
the physical device, behind the scenes. As many logical devices as you like
can come and go; SDL will only have to open the physical device at the OS
level once, and will manage all the logical devices on top of it
internally.

One other benefit of logical devices: if you don't open a specific physical
device, instead opting for the default, SDL can automatically migrate those
logical devices to different hardware as circumstances change: a user
plugged in headphones? The system default changed? SDL can transparently
migrate the logical devices to the correct physical device seamlessly and
keep playing; the app doesn't even have to know it happened if it doesn't
want to.

## Simplified audio

As a simplified model for when a single source of audio is all that's
needed, an app can use SDL_OpenAudioDeviceStream, which is a single
function to open an audio device, create an audio stream, bind that stream
to the newly-opened device, and (optionally) provide a callback for
obtaining audio data. When using this function, the primary interface is
the SDL_AudioStream and the device handle is mostly hidden away; destroying
a stream created through this function will also close the device, stream
bindings cannot be changed, etc. One other quirk of this is that the device
is started in a _paused_ state and must be explicitly resumed; this is
partially to offer a clean migration for SDL2 apps and partially because
the app might have to do more setup before playback begins; in the
non-simplified form, nothing will play until a stream is bound to a device,
so they start _unpaused_.

## Channel layouts

Audio data passing through SDL is uncompressed PCM data, interleaved. One
can provide their own decompression through an MP3, etc, decoder, but SDL
does not provide this directly. Each interleaved channel of data is meant
to be in a specific order.

Abbreviations:

- FRONT = single mono speaker
- FL = front left speaker
- FR = front right speaker
- FC = front center speaker
- BL = back left speaker
- BR = back right speaker
- SR = surround right speaker
- SL = surround left speaker
- BC = back center speaker
- LFE = low-frequency speaker

These are listed in the order they are laid out in memory, so "FL, FR"
means "the front left speaker is laid out in memory first, then the front
right, then it repeats for the next audio frame".

- 1 channel (mono) layout: FRONT
- 2 channels (stereo) layout: FL, FR
- 3 channels (2.1) layout: FL, FR, LFE
- 4 channels (quad) layout: FL, FR, BL, BR
- 5 channels (4.1) layout: FL, FR, LFE, BL, BR
- 6 channels (5.1) layout: FL, FR, FC, LFE, BL, BR (last two can also be
  SL, SR)
- 7 channels (6.1) layout: FL, FR, FC, LFE, BC, SL, SR
- 8 channels (7.1) layout: FL, FR, FC, LFE, BL, BR, SL, SR

This is the same order as DirectSound expects, but applied to all
platforms; SDL will swizzle the channels as necessary if a platform expects
something different.

SDL_AudioStream can also be provided channel maps to change this ordering
to whatever is necessary, in other audio processing scenarios.
"""


@register_passable("trivial")
struct AudioFormat(Indexer, Intable):
    """Audio format.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AudioFormat.
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
        return index(Int(self))

    alias AUDIO_UNKNOWN = Self(0x0000)
    """Unspecified audio format."""
    alias AUDIO_U8 = Self(0x0008)
    """Unsigned 8-bit samples."""
    # SDL_DEFINE_AUDIO_FORMAT(0, 0, 0, 8),
    alias AUDIO_S8 = Self(0x8008)
    """Signed 8-bit samples."""
    # SDL_DEFINE_AUDIO_FORMAT(1, 0, 0, 8),
    alias AUDIO_S16LE = Self(0x8010)
    """Signed 16-bit samples."""
    # SDL_DEFINE_AUDIO_FORMAT(1, 0, 0, 16),
    alias AUDIO_S16BE = Self(0x9010)
    """As above, but big-endian byte order."""
    # SDL_DEFINE_AUDIO_FORMAT(1, 1, 0, 16),
    alias AUDIO_S32LE = Self(0x8020)
    """32-bit integer samples."""
    # SDL_DEFINE_AUDIO_FORMAT(1, 0, 0, 32),
    alias AUDIO_S32BE = Self(0x9020)
    """As above, but big-endian byte order."""
    # SDL_DEFINE_AUDIO_FORMAT(1, 1, 0, 32),
    alias AUDIO_F32LE = Self(0x8120)
    """32-bit floating point samples."""
    # SDL_DEFINE_AUDIO_FORMAT(1, 0, 1, 32),
    alias AUDIO_F32BE = Self(0x9120)
    """As above, but big-endian byte order."""
    # SDL_DEFINE_AUDIO_FORMAT(1, 1, 1, 32),

    # These represent the current system's byteorder.
    alias AUDIO_S16 = Self.AUDIO_S16LE if is_little_endian() else Self.AUDIO_S16BE
    alias AUDIO_S32 = Self.AUDIO_S32LE if is_little_endian() else Self.AUDIO_S32BE
    alias AUDIO_F32 = Self.AUDIO_F32LE if is_little_endian() else Self.AUDIO_F32BE


@register_passable("trivial")
struct AudioDeviceID(Intable):
    """SDL Audio Device instance IDs.

    Zero is used to signify an invalid/null device.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AudioDeviceID.
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


@fieldwise_init
struct AudioSpec(Copyable, Movable):
    """Format specifier for audio data.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AudioSpec.
    """

    var format: AudioFormat
    """Audio data format."""
    var channels: c_int
    """Number of channels: 1 mono, 2 stereo, etc."""
    var freq: c_int
    """Sample rate: sample frames per second."""


@fieldwise_init
struct AudioStream(Copyable, Movable):
    """The opaque handle that represents an audio stream.

    SDL_AudioStream is an audio conversion interface.

    - It can handle resampling data in chunks without generating artifacts,
      when it doesn't have the complete buffer available.
    - It can handle incoming data in any variable size.
    - It can handle input/output format changes on the fly.
    - It can remap audio channels between inputs and outputs.
    - You push data as you have it, and pull it when you need it
    - It can also function as a basic audio data queue even if you just have
      sound that needs to pass from one place to another.
    - You can hook callbacks up to them when more data is added or requested,
      to manage data on-the-fly.

    Audio streams are the core of the SDL3 audio interface. You create one or
    more of them, bind them to an opened audio device, and feed data to them
    (or for recording, consume data from them).

    Docs: https://wiki.libsdl.org/SDL3/SDL_AudioStream.
    """

    pass


fn get_num_audio_drivers() -> c_int:
    """Use this function to get the number of built-in audio drivers.

    This function returns a hardcoded number. This never returns a negative
    value; if there are no drivers compiled into this build of SDL, this
    function returns zero. The presence of a driver in this list does not mean
    it will function, it just means SDL is capable of interacting with that
    interface. For example, a build of SDL might have esound support, but if
    there's no esound server available, SDL's esound driver would fail if used.

    By default, SDL tries all drivers, in its preferred order, until one is
    found to be usable.

    Returns:
        The number of built-in audio drivers.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumAudioDrivers.
    """

    return _get_dylib_function[lib, "SDL_GetNumAudioDrivers", fn () -> c_int]()()


fn get_audio_driver(index: c_int) -> Ptr[c_char, mut=False]:
    """Use this function to get the name of a built in audio driver.

    The list of audio drivers is given in the order that they are normally
    initialized by default; the drivers that seem more reasonable to choose
    first (as far as the SDL developers believe) are earlier in the list.

    The names of drivers are all simple, low-ASCII identifiers, like "alsa",
    "coreaudio" or "wasapi". These never have Unicode characters, and are not
    meant to be proper names.

    Args:
        index: The index of the audio driver; the value ranges from 0 to
               SDL_GetNumAudioDrivers() - 1.

    Returns:
        The name of the audio driver at the requested index, or NULL if an
        invalid index was specified.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioDriver.
    """

    return _get_dylib_function[lib, "SDL_GetAudioDriver", fn (index: c_int) -> Ptr[c_char, mut=False]]()(index)


fn get_current_audio_driver() -> Ptr[c_char, mut=False]:
    """Get the name of the current audio driver.

    The names of drivers are all simple, low-ASCII identifiers, like "alsa",
    "coreaudio" or "wasapi". These never have Unicode characters, and are not
    meant to be proper names.

    Returns:
        The name of the current audio driver or NULL if no driver has been
        initialized.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetCurrentAudioDriver.
    """

    return _get_dylib_function[lib, "SDL_GetCurrentAudioDriver", fn () -> Ptr[c_char, mut=False]]()()


fn get_audio_playback_devices(count: Ptr[c_int, mut=True]) -> Ptr[AudioDeviceID, mut=True]:
    """Get a list of currently-connected audio playback devices.

    This returns of list of available devices that play sound, perhaps to
    speakers or headphones ("playback" devices). If you want devices that
    record audio, like a microphone ("recording" devices), use
    SDL_GetAudioRecordingDevices() instead.

    This only returns a list of physical devices; it will not have any device
    IDs returned by SDL_OpenAudioDevice().

    If this function returns NULL, to signify an error, `*count` will be set to
    zero.

    Args:
        count: A pointer filled in with the number of devices returned, may
               be NULL.

    Returns:
        A 0 terminated array of device instance IDs or NULL on error; call
        SDL_GetError() for more information. This should be freed with
        SDL_free() when it is no longer needed.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioPlaybackDevices.
    """

    return _get_dylib_function[lib, "SDL_GetAudioPlaybackDevices", fn (count: Ptr[c_int, mut=True]) -> Ptr[AudioDeviceID, mut=True]]()(count)


fn get_audio_recording_devices(count: Ptr[c_int, mut=True], out ret: Ptr[AudioDeviceID, mut=True]) raises:
    """Get a list of currently-connected audio recording devices.

    This returns of list of available devices that record audio, like a
    microphone ("recording" devices). If you want devices that play sound,
    perhaps to speakers or headphones ("playback" devices), use
    SDL_GetAudioPlaybackDevices() instead.

    This only returns a list of physical devices; it will not have any device
    IDs returned by SDL_OpenAudioDevice().

    If this function returns NULL, to signify an error, `*count` will be set to
    zero.

    Args:
        count: A pointer filled in with the number of devices returned, may
               be NULL.

    Returns:
        A 0 terminated array of device instance IDs, or NULL on failure;
        call SDL_GetError() for more information. This should be freed
        with SDL_free() when it is no longer needed.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioRecordingDevices.
    """

    ret = _get_dylib_function[lib, "SDL_GetAudioRecordingDevices", fn (count: Ptr[c_int, mut=True]) -> Ptr[AudioDeviceID, mut=True]]()(count)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_audio_device_name(devid: AudioDeviceID, out ret: Ptr[c_char, mut=False]) raises:
    """Get the human-readable name of a specific audio device.

    Args:
        devid: The instance ID of the device to query.

    Returns:
        The name of the audio device, or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioDeviceName.
    """

    ret = _get_dylib_function[lib, "SDL_GetAudioDeviceName", fn (devid: AudioDeviceID) -> Ptr[c_char, mut=False]]()(devid)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_audio_device_format(devid: AudioDeviceID, spec: Ptr[AudioSpec, mut=True], sample_frames: Ptr[c_int, mut=True]) raises:
    """Get the current audio format of a specific audio device.

    For an opened device, this will report the format the device is currently
    using. If the device isn't yet opened, this will report the device's
    preferred format (or a reasonable default if this can't be determined).

    You may also specify SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK or
    SDL_AUDIO_DEVICE_DEFAULT_RECORDING here, which is useful for getting a
    reasonable recommendation before opening the system-recommended default
    device.

    You can also use this to request the current device buffer size. This is
    specified in sample frames and represents the amount of data SDL will feed
    to the physical hardware in each chunk. This can be converted to
    milliseconds of audio with the following equation:

    `ms = (int) ((((Sint64) frames) * 1000) / spec.freq);`

    Buffer size is only important if you need low-level control over the audio
    playback timing. Most apps do not need this.

    Args:
        devid: The instance ID of the device to query.
        spec: On return, will be filled with device details.
        sample_frames: Pointer to store device buffer size, in sample frames.
                       Can be NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioDeviceFormat.
    """

    ret = _get_dylib_function[lib, "SDL_GetAudioDeviceFormat", fn (devid: AudioDeviceID, spec: Ptr[AudioSpec, mut=True], sample_frames: Ptr[c_int, mut=True]) -> Bool]()(devid, spec, sample_frames)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_audio_device_channel_map(devid: AudioDeviceID, count: Ptr[c_int, mut=True]) -> Ptr[c_int, mut=True]:
    """Get the current channel map of an audio device.

    Channel maps are optional; most things do not need them, instead passing
    data in the [order that SDL expects](CategoryAudio#channel-layouts).

    Audio devices usually have no remapping applied. This is represented by
    returning NULL, and does not signify an error.

    Args:
        devid: The instance ID of the device to query.
        count: On output, set to number of channels in the map. Can be NULL.

    Returns:
        An array of the current channel mapping, with as many elements as
        the current output spec's channels, or NULL if default. This
        should be freed with SDL_free() when it is no longer needed.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioDeviceChannelMap.
    """

    return _get_dylib_function[lib, "SDL_GetAudioDeviceChannelMap", fn (devid: AudioDeviceID, count: Ptr[c_int, mut=True]) -> Ptr[c_int, mut=True]]()(devid, count)


fn open_audio_device(devid: AudioDeviceID, spec: Ptr[AudioSpec, mut=False]) -> AudioDeviceID:
    """Open a specific audio device.

    You can open both playback and recording devices through this function.
    Playback devices will take data from bound audio streams, mix it, and send
    it to the hardware. Recording devices will feed any bound audio streams
    with a copy of any incoming data.

    An opened audio device starts out with no audio streams bound. To start
    audio playing, bind a stream and supply audio data to it. Unlike SDL2,
    there is no audio callback; you only bind audio streams and make sure they
    have data flowing into them (however, you can simulate SDL2's semantics
    fairly closely by using SDL_OpenAudioDeviceStream instead of this
    function).

    If you don't care about opening a specific device, pass a `devid` of either
    `SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK` or
    `SDL_AUDIO_DEVICE_DEFAULT_RECORDING`. In this case, SDL will try to pick
    the most reasonable default, and may also switch between physical devices
    seamlessly later, if the most reasonable default changes during the
    lifetime of this opened device (user changed the default in the OS's system
    preferences, the default got unplugged so the system jumped to a new
    default, the user plugged in headphones on a mobile device, etc). Unless
    you have a good reason to choose a specific device, this is probably what
    you want.

    You may request a specific format for the audio device, but there is no
    promise the device will honor that request for several reasons. As such,
    it's only meant to be a hint as to what data your app will provide. Audio
    streams will accept data in whatever format you specify and manage
    conversion for you as appropriate. SDL_GetAudioDeviceFormat can tell you
    the preferred format for the device before opening and the actual format
    the device is using after opening.

    It's legal to open the same device ID more than once; each successful open
    will generate a new logical SDL_AudioDeviceID that is managed separately
    from others on the same physical device. This allows libraries to open a
    device separately from the main app and bind its own streams without
    conflicting.

    It is also legal to open a device ID returned by a previous call to this
    function; doing so just creates another logical device on the same physical
    device. This may be useful for making logical groupings of audio streams.

    This function returns the opened device ID on success. This is a new,
    unique SDL_AudioDeviceID that represents a logical device.

    Some backends might offer arbitrary devices (for example, a networked audio
    protocol that can connect to an arbitrary server). For these, as a change
    from SDL2, you should open a default device ID and use an SDL hint to
    specify the target if you care, or otherwise let the backend figure out a
    reasonable default. Most backends don't offer anything like this, and often
    this would be an end user setting an environment variable for their custom
    need, and not something an application should specifically manage.

    When done with an audio device, possibly at the end of the app's life, one
    should call SDL_CloseAudioDevice() on the returned device id.

    Args:
        devid: The device instance id to open, or
               SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK or
               SDL_AUDIO_DEVICE_DEFAULT_RECORDING for the most reasonable
               default device.
        spec: The requested device configuration. Can be NULL to use
              reasonable defaults.

    Returns:
        The device ID on success or 0 on failure; call SDL_GetError() for
        more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenAudioDevice.
    """

    return _get_dylib_function[lib, "SDL_OpenAudioDevice", fn (devid: AudioDeviceID, spec: Ptr[AudioSpec, mut=False]) -> AudioDeviceID]()(devid, spec)


fn is_audio_device_physical(devid: AudioDeviceID) -> Bool:
    """Determine if an audio device is physical (instead of logical).

    An SDL_AudioDeviceID that represents physical hardware is a physical
    device; there is one for each piece of hardware that SDL can see. Logical
    devices are created by calling SDL_OpenAudioDevice or
    SDL_OpenAudioDeviceStream, and while each is associated with a physical
    device, there can be any number of logical devices on one physical device.

    For the most part, logical and physical IDs are interchangeable--if you try
    to open a logical device, SDL understands to assign that effort to the
    underlying physical device, etc. However, it might be useful to know if an
    arbitrary device ID is physical or logical. This function reports which.

    This function may return either true or false for invalid device IDs.

    Args:
        devid: The device ID to query.

    Returns:
        True if devid is a physical device, false if it is logical.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IsAudioDevicePhysical.
    """

    return _get_dylib_function[lib, "SDL_IsAudioDevicePhysical", fn (devid: AudioDeviceID) -> Bool]()(devid)


fn is_audio_device_playback(devid: AudioDeviceID) -> Bool:
    """Determine if an audio device is a playback device (instead of recording).

    This function may return either true or false for invalid device IDs.

    Args:
        devid: The device ID to query.

    Returns:
        True if devid is a playback device, false if it is recording.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IsAudioDevicePlayback.
    """

    return _get_dylib_function[lib, "SDL_IsAudioDevicePlayback", fn (devid: AudioDeviceID) -> Bool]()(devid)


fn pause_audio_device(devid: AudioDeviceID) raises:
    """Use this function to pause audio playback on a specified device.

    This function pauses audio processing for a given device. Any bound audio
    streams will not progress, and no audio will be generated. Pausing one
    device does not prevent other unpaused devices from running.

    Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    has to bind a stream before any audio will flow. Pausing a paused device is
    a legal no-op.

    Pausing a device can be useful to halt all audio without unbinding all the
    audio streams. This might be useful while a game is paused, or a level is
    loading, etc.

    Physical devices can not be paused or unpaused, only logical devices
    created through SDL_OpenAudioDevice() can be.

    Args:
        devid: A device opened by SDL_OpenAudioDevice().

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PauseAudioDevice.
    """

    ret = _get_dylib_function[lib, "SDL_PauseAudioDevice", fn (devid: AudioDeviceID) -> Bool]()(devid)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn resume_audio_device(devid: AudioDeviceID) raises:
    """Use this function to unpause audio playback on a specified device.

    This function unpauses audio processing for a given device that has
    previously been paused with SDL_PauseAudioDevice(). Once unpaused, any
    bound audio streams will begin to progress again, and audio can be
    generated.

    Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    has to bind a stream before any audio will flow. Unpausing an unpaused
    device is a legal no-op.

    Physical devices can not be paused or unpaused, only logical devices
    created through SDL_OpenAudioDevice() can be.

    Args:
        devid: A device opened by SDL_OpenAudioDevice().

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ResumeAudioDevice.
    """

    ret = _get_dylib_function[lib, "SDL_ResumeAudioDevice", fn (devid: AudioDeviceID) -> Bool]()(devid)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn audio_device_paused(devid: AudioDeviceID) -> Bool:
    """Use this function to query if an audio device is paused.

    Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    has to bind a stream before any audio will flow.

    Physical devices can not be paused or unpaused, only logical devices
    created through SDL_OpenAudioDevice() can be. Physical and invalid device
    IDs will report themselves as unpaused here.

    Args:
        devid: A device opened by SDL_OpenAudioDevice().

    Returns:
        True if device is valid and paused, false otherwise.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AudioDevicePaused.
    """

    return _get_dylib_function[lib, "SDL_AudioDevicePaused", fn (devid: AudioDeviceID) -> Bool]()(devid)


fn get_audio_device_gain(devid: AudioDeviceID) -> c_float:
    """Get the gain of an audio device.

    The gain of a device is its volume; a larger gain means a louder output,
    with a gain of zero being silence.

    Audio devices default to a gain of 1.0f (no change in output).

    Physical devices may not have their gain changed, only logical devices, and
    this function will always return -1.0f when used on physical devices.

    Args:
        devid: The audio device to query.

    Returns:
        The gain of the device or -1.0f on failure; call SDL_GetError()
        for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioDeviceGain.
    """

    return _get_dylib_function[lib, "SDL_GetAudioDeviceGain", fn (devid: AudioDeviceID) -> c_float]()(devid)


fn set_audio_device_gain(devid: AudioDeviceID, gain: c_float) raises:
    """Change the gain of an audio device.

    The gain of a device is its volume; a larger gain means a louder output,
    with a gain of zero being silence.

    Audio devices default to a gain of 1.0f (no change in output).

    Physical devices may not have their gain changed, only logical devices, and
    this function will always return false when used on physical devices. While
    it might seem attractive to adjust several logical devices at once in this
    way, it would allow an app or library to interfere with another portion of
    the program's otherwise-isolated devices.

    This is applied, along with any per-audiostream gain, during playback to
    the hardware, and can be continuously changed to create various effects. On
    recording devices, this will adjust the gain before passing the data into
    an audiostream; that recording audiostream can then adjust its gain further
    when outputting the data elsewhere, if it likes, but that second gain is
    not applied until the data leaves the audiostream again.

    Args:
        devid: The audio device on which to change gain.
        gain: The gain. 1.0f is no change, 0.0f is silence.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetAudioDeviceGain.
    """

    ret = _get_dylib_function[lib, "SDL_SetAudioDeviceGain", fn (devid: AudioDeviceID, gain: c_float) -> Bool]()(devid, gain)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn close_audio_device(devid: AudioDeviceID) -> None:
    """Close a previously-opened audio device.

    The application should close open audio devices once they are no longer
    needed.

    This function may block briefly while pending audio data is played by the
    hardware, so that applications don't drop the last buffer of data they
    supplied if terminating immediately afterwards.

    Args:
        devid: An audio device id previously returned by
               SDL_OpenAudioDevice().

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CloseAudioDevice.
    """

    return _get_dylib_function[lib, "SDL_CloseAudioDevice", fn (devid: AudioDeviceID) -> None]()(devid)


fn bind_audio_streams(devid: AudioDeviceID, streams: Ptr[AudioStream, mut=True], num_streams: c_int) raises:
    """Bind a list of audio streams to an audio device.

    Audio data will flow through any bound streams. For a playback device, data
    for all bound streams will be mixed together and fed to the device. For a
    recording device, a copy of recorded data will be provided to each bound
    stream.

    Audio streams can only be bound to an open device. This operation is
    atomic--all streams bound in the same call will start processing at the
    same time, so they can stay in sync. Also: either all streams will be bound
    or none of them will be.

    It is an error to bind an already-bound stream; it must be explicitly
    unbound first.

    Binding a stream to a device will set its output format for playback
    devices, and its input format for recording devices, so they match the
    device's settings. The caller is welcome to change the other end of the
    stream's format at any time with SDL_SetAudioStreamFormat(). If the other
    end of the stream's format has never been set (the audio stream was created
    with a NULL audio spec), this function will set it to match the device
    end's format.

    Args:
        devid: An audio device to bind a stream to.
        streams: An array of audio streams to bind.
        num_streams: Number streams listed in the `streams` array.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindAudioStreams.
    """

    ret = _get_dylib_function[lib, "SDL_BindAudioStreams", fn (devid: AudioDeviceID, streams: Ptr[AudioStream, mut=True], num_streams: c_int) -> Bool]()(devid, streams, num_streams)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn bind_audio_stream(devid: AudioDeviceID, stream: Ptr[AudioStream, mut=True]) raises:
    """Bind a single audio stream to an audio device.

    This is a convenience function, equivalent to calling
    `SDL_BindAudioStreams(devid, &stream, 1)`.

    Args:
        devid: An audio device to bind a stream to.
        stream: An audio stream to bind to a device.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_BindAudioStream.
    """

    ret = _get_dylib_function[lib, "SDL_BindAudioStream", fn (devid: AudioDeviceID, stream: Ptr[AudioStream, mut=True]) -> Bool]()(devid, stream)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn unbind_audio_streams(streams: Ptr[AudioStream, mut=True], num_streams: c_int) -> None:
    """Unbind a list of audio streams from their audio devices.

    The streams being unbound do not all have to be on the same device. All
    streams on the same device will be unbound atomically (data will stop
    flowing through all unbound streams on the same device at the same time).

    Unbinding a stream that isn't bound to a device is a legal no-op.

    Args:
        streams: An array of audio streams to unbind. Can be NULL or contain
                 NULL.
        num_streams: Number streams listed in the `streams` array.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UnbindAudioStreams.
    """

    return _get_dylib_function[lib, "SDL_UnbindAudioStreams", fn (streams: Ptr[AudioStream, mut=True], num_streams: c_int) -> None]()(streams, num_streams)


fn unbind_audio_stream(stream: Ptr[AudioStream, mut=True]) -> None:
    """Unbind a single audio stream from its audio device.

    This is a convenience function, equivalent to calling
    `SDL_UnbindAudioStreams(&stream, 1)`.

    Args:
        stream: An audio stream to unbind from a device. Can be NULL.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UnbindAudioStream.
    """

    return _get_dylib_function[lib, "SDL_UnbindAudioStream", fn (stream: Ptr[AudioStream, mut=True]) -> None]()(stream)


fn get_audio_stream_device(stream: Ptr[AudioStream, mut=True]) -> AudioDeviceID:
    """Query an audio stream for its currently-bound device.

    This reports the logical audio device that an audio stream is currently bound to.

    If not bound, or invalid, this returns zero, which is not a valid device
    ID.

    Args:
        stream: The audio stream to query.

    Returns:
        The bound audio device, or 0 if not bound or invalid.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioStreamDevice.
    """

    return _get_dylib_function[lib, "SDL_GetAudioStreamDevice", fn (stream: Ptr[AudioStream, mut=True]) -> AudioDeviceID]()(stream)


fn create_audio_stream(src_spec: Ptr[AudioSpec, mut=False], dst_spec: Ptr[AudioSpec, mut=False], out ret: Ptr[AudioStream, mut=True]) raises:
    """Create a new audio stream.

    Args:
        src_spec: The format details of the input audio.
        dst_spec: The format details of the output audio.

    Returns:
        A new audio stream on success or NULL on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CreateAudioStream.
    """

    ret = _get_dylib_function[lib, "SDL_CreateAudioStream", fn (src_spec: Ptr[AudioSpec, mut=False], dst_spec: Ptr[AudioSpec, mut=False]) -> Ptr[AudioStream, mut=True]]()(src_spec, dst_spec)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_audio_stream_properties(stream: Ptr[AudioStream, mut=True]) -> PropertiesID:
    """Get the properties associated with an audio stream.

    Args:
        stream: The SDL_AudioStream to query.

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioStreamProperties.
    """

    return _get_dylib_function[lib, "SDL_GetAudioStreamProperties", fn (stream: Ptr[AudioStream, mut=True]) -> PropertiesID]()(stream)


fn get_audio_stream_format(stream: Ptr[AudioStream, mut=True], src_spec: Ptr[AudioSpec, mut=True], dst_spec: Ptr[AudioSpec, mut=True]) raises:
    """Query the current format of an audio stream.

    Args:
        stream: The SDL_AudioStream to query.
        src_spec: Where to store the input audio format; ignored if NULL.
        dst_spec: Where to store the output audio format; ignored if NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioStreamFormat.
    """

    ret = _get_dylib_function[lib, "SDL_GetAudioStreamFormat", fn (stream: Ptr[AudioStream, mut=True], src_spec: Ptr[AudioSpec, mut=True], dst_spec: Ptr[AudioSpec, mut=True]) -> Bool]()(stream, src_spec, dst_spec)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn set_audio_stream_format(stream: Ptr[AudioStream, mut=True], src_spec: Ptr[AudioSpec, mut=False], dst_spec: Ptr[AudioSpec, mut=False]) raises:
    """Change the input and output formats of an audio stream.

    Future calls to and SDL_GetAudioStreamAvailable and SDL_GetAudioStreamData
    will reflect the new format, and future calls to SDL_PutAudioStreamData
    must provide data in the new input formats.

    Data that was previously queued in the stream will still be operated on in
    the format that was current when it was added, which is to say you can put
    the end of a sound file in one format to a stream, change formats for the
    next sound file, and start putting that new data while the previous sound
    file is still queued, and everything will still play back correctly.

    If a stream is bound to a device, then the format of the side of the stream
    bound to a device cannot be changed (src_spec for recording devices,
    dst_spec for playback devices). Attempts to make a change to this side will
    be ignored, but this will not report an error. The other side's format can
    be changed.

    Args:
        stream: The stream the format is being changed.
        src_spec: The new format of the audio input; if NULL, it is not
                  changed.
        dst_spec: The new format of the audio output; if NULL, it is not
                  changed.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetAudioStreamFormat.
    """

    ret = _get_dylib_function[lib, "SDL_SetAudioStreamFormat", fn (stream: Ptr[AudioStream, mut=True], src_spec: Ptr[AudioSpec, mut=False], dst_spec: Ptr[AudioSpec, mut=False]) -> Bool]()(stream, src_spec, dst_spec)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_audio_stream_frequency_ratio(stream: Ptr[AudioStream, mut=True]) -> c_float:
    """Get the frequency ratio of an audio stream.

    Args:
        stream: The SDL_AudioStream to query.

    Returns:
        The frequency ratio of the stream or 0.0 on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioStreamFrequencyRatio.
    """

    return _get_dylib_function[lib, "SDL_GetAudioStreamFrequencyRatio", fn (stream: Ptr[AudioStream, mut=True]) -> c_float]()(stream)


fn set_audio_stream_frequency_ratio(stream: Ptr[AudioStream, mut=True], ratio: c_float) raises:
    """Change the frequency ratio of an audio stream.

    The frequency ratio is used to adjust the rate at which input data is
    consumed. Changing this effectively modifies the speed and pitch of the
    audio. A value greater than 1.0 will play the audio faster, and at a higher
    pitch. A value less than 1.0 will play the audio slower, and at a lower
    pitch.

    This is applied during SDL_GetAudioStreamData, and can be continuously
    changed to create various effects.

    Args:
        stream: The stream the frequency ratio is being changed.
        ratio: The frequency ratio. 1.0 is normal speed. Must be between 0.01
               and 100.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetAudioStreamFrequencyRatio.
    """

    ret = _get_dylib_function[lib, "SDL_SetAudioStreamFrequencyRatio", fn (stream: Ptr[AudioStream, mut=True], ratio: c_float) -> Bool]()(stream, ratio)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_audio_stream_gain(stream: Ptr[AudioStream, mut=True]) -> c_float:
    """Get the gain of an audio stream.

    The gain of a stream is its volume; a larger gain means a louder output,
    with a gain of zero being silence.

    Audio streams default to a gain of 1.0f (no change in output).

    Args:
        stream: The SDL_AudioStream to query.

    Returns:
        The gain of the stream or -1.0f on failure; call SDL_GetError()
        for more information.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioStreamGain.
    """

    return _get_dylib_function[lib, "SDL_GetAudioStreamGain", fn (stream: Ptr[AudioStream, mut=True]) -> c_float]()(stream)


fn set_audio_stream_gain(stream: Ptr[AudioStream, mut=True], gain: c_float) raises:
    """Change the gain of an audio stream.

    The gain of a stream is its volume; a larger gain means a louder output,
    with a gain of zero being silence.

    Audio streams default to a gain of 1.0f (no change in output).

    This is applied during SDL_GetAudioStreamData, and can be continuously
    changed to create various effects.

    Args:
        stream: The stream on which the gain is being changed.
        gain: The gain. 1.0f is no change, 0.0f is silence.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetAudioStreamGain.
    """

    ret = _get_dylib_function[lib, "SDL_SetAudioStreamGain", fn (stream: Ptr[AudioStream, mut=True], gain: c_float) -> Bool]()(stream, gain)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_audio_stream_input_channel_map(stream: Ptr[AudioStream, mut=True], count: Ptr[c_int, mut=True]) -> Ptr[c_int, mut=True]:
    """Get the current input channel map of an audio stream.

    Channel maps are optional; most things do not need them, instead passing
    data in the [order that SDL expects](CategoryAudio#channel-layouts).

    Audio streams default to no remapping applied. This is represented by
    returning NULL, and does not signify an error.

    Args:
        stream: The SDL_AudioStream to query.
        count: On output, set to number of channels in the map. Can be NULL.

    Returns:
        An array of the current channel mapping, with as many elements as
        the current output spec's channels, or NULL if default. This
        should be freed with SDL_free() when it is no longer needed.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioStreamInputChannelMap.
    """

    return _get_dylib_function[lib, "SDL_GetAudioStreamInputChannelMap", fn (stream: Ptr[AudioStream, mut=True], count: Ptr[c_int, mut=True]) -> Ptr[c_int, mut=True]]()(stream, count)


fn get_audio_stream_output_channel_map(stream: Ptr[AudioStream, mut=True], count: Ptr[c_int, mut=True]) -> Ptr[c_int, mut=True]:
    """Get the current output channel map of an audio stream.

    Channel maps are optional; most things do not need them, instead passing
    data in the [order that SDL expects](CategoryAudio#channel-layouts).

    Audio streams default to no remapping applied. This is represented by
    returning NULL, and does not signify an error.

    Args:
        stream: The SDL_AudioStream to query.
        count: On output, set to number of channels in the map. Can be NULL.

    Returns:
        An array of the current channel mapping, with as many elements as
        the current output spec's channels, or NULL if default. This
        should be freed with SDL_free() when it is no longer needed.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioStreamOutputChannelMap.
    """

    return _get_dylib_function[lib, "SDL_GetAudioStreamOutputChannelMap", fn (stream: Ptr[AudioStream, mut=True], count: Ptr[c_int, mut=True]) -> Ptr[c_int, mut=True]]()(stream, count)


fn set_audio_stream_input_channel_map(stream: Ptr[AudioStream, mut=True], chmap: Ptr[c_int, mut=False], count: c_int) raises:
    """Set the current input channel map of an audio stream.

    Channel maps are optional; most things do not need them, instead passing
    data in the [order that SDL expects](CategoryAudio#channel-layouts).

    The input channel map reorders data that is added to a stream via
    SDL_PutAudioStreamData. Future calls to SDL_PutAudioStreamData must provide
    data in the new channel order.

    Each item in the array represents an input channel, and its value is the
    channel that it should be remapped to. To reverse a stereo signal's left
    and right values, you'd have an array of `{ 1, 0 }`. It is legal to remap
    multiple channels to the same thing, so `{ 1, 1 }` would duplicate the
    right channel to both channels of a stereo signal. An element in the
    channel map set to -1 instead of a valid channel will mute that channel,
    setting it to a silence value.

    You cannot change the number of channels through a channel map, just
    reorder/mute them.

    Data that was previously queued in the stream will still be operated on in
    the order that was current when it was added, which is to say you can put
    the end of a sound file in one order to a stream, change orders for the
    next sound file, and start putting that new data while the previous sound
    file is still queued, and everything will still play back correctly.

    Audio streams default to no remapping applied. Passing a NULL channel map
    is legal, and turns off remapping.

    SDL will copy the channel map; the caller does not have to save this array
    after this call.

    If `count` is not equal to the current number of channels in the audio
    stream's format, this will fail. This is a safety measure to make sure a
    race condition hasn't changed the format while this call is setting the
    channel map.

    Unlike attempting to change the stream's format, the input channel map on a
    stream bound to a recording device is permitted to change at any time; any
    data added to the stream from the device after this call will have the new
    mapping, but previously-added data will still have the prior mapping.

    Args:
        stream: The SDL_AudioStream to change.
        chmap: The new channel map, NULL to reset to default.
        count: The number of channels in the map.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running. Don't change the
        stream's format to have a different number of channels from a
        a different thread at the same time, though!

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetAudioStreamInputChannelMap.
    """

    ret = _get_dylib_function[lib, "SDL_SetAudioStreamInputChannelMap", fn (stream: Ptr[AudioStream, mut=True], chmap: Ptr[c_int, mut=False], count: c_int) -> Bool]()(stream, chmap, count)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn set_audio_stream_output_channel_map(stream: Ptr[AudioStream, mut=True], chmap: Ptr[c_int, mut=False], count: c_int) raises:
    """Set the current output channel map of an audio stream.

    Channel maps are optional; most things do not need them, instead passing
    data in the [order that SDL expects](CategoryAudio#channel-layouts).

    The output channel map reorders data that leaving a stream via
    SDL_GetAudioStreamData.

    Each item in the array represents an input channel, and its value is the
    channel that it should be remapped to. To reverse a stereo signal's left
    and right values, you'd have an array of `{ 1, 0 }`. It is legal to remap
    multiple channels to the same thing, so `{ 1, 1 }` would duplicate the
    right channel to both channels of a stereo signal. An element in the
    channel map set to -1 instead of a valid channel will mute that channel,
    setting it to a silence value.

    You cannot change the number of channels through a channel map, just
    reorder/mute them.

    The output channel map can be changed at any time, as output remapping is
    applied during SDL_GetAudioStreamData.

    Audio streams default to no remapping applied. Passing a NULL channel map
    is legal, and turns off remapping.

    SDL will copy the channel map; the caller does not have to save this array
    after this call.

    If `count` is not equal to the current number of channels in the audio
    stream's format, this will fail. This is a safety measure to make sure a
    race condition hasn't changed the format while this call is setting the
    channel map.

    Unlike attempting to change the stream's format, the output channel map on
    a stream bound to a recording device is permitted to change at any time;
    any data added to the stream after this call will have the new mapping, but
    previously-added data will still have the prior mapping. When the channel
    map doesn't match the hardware's channel layout, SDL will convert the data
    before feeding it to the device for playback.

    Args:
        stream: The SDL_AudioStream to change.
        chmap: The new channel map, NULL to reset to default.
        count: The number of channels in the map.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread, as it holds
        a stream-specific mutex while running. Don't change the
        stream's format to have a different number of channels from a
        a different thread at the same time, though!

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetAudioStreamOutputChannelMap.
    """

    ret = _get_dylib_function[lib, "SDL_SetAudioStreamOutputChannelMap", fn (stream: Ptr[AudioStream, mut=True], chmap: Ptr[c_int, mut=False], count: c_int) -> Bool]()(stream, chmap, count)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn put_audio_stream_data(stream: Ptr[AudioStream, mut=True], buf: Ptr[NoneType, mut=False], len: c_int) raises:
    """Add data to the stream.

    This data must match the format/channels/samplerate specified in the latest
    call to SDL_SetAudioStreamFormat, or the format specified when creating the
    stream if it hasn't been changed.

    Note that this call simply copies the unconverted data for later. This is
    different than SDL2, where data was converted during the Put call and the
    Get call would just dequeue the previously-converted data.

    Args:
        stream: The stream the audio data is being added to.
        buf: A pointer to the audio data to add.
        len: The number of bytes to write to the stream.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread, but if the
        stream has a callback set, the caller might need to manage
        extra locking.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PutAudioStreamData.
    """

    ret = _get_dylib_function[lib, "SDL_PutAudioStreamData", fn (stream: Ptr[AudioStream, mut=True], buf: Ptr[NoneType, mut=False], len: c_int) -> Bool]()(stream, buf, len)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_audio_stream_data(stream: Ptr[AudioStream, mut=True], buf: Ptr[NoneType, mut=True], len: c_int) -> c_int:
    """Get converted/resampled data from the stream.

    The input/output data format/channels/samplerate is specified when creating
    the stream, and can be changed after creation by calling
    SDL_SetAudioStreamFormat.

    Note that any conversion and resampling necessary is done during this call,
    and SDL_PutAudioStreamData simply queues unconverted data for later. This
    is different than SDL2, where that work was done while inputting new data
    to the stream and requesting the output just copied the converted data.

    Args:
        stream: The stream the audio is being requested from.
        buf: A buffer to fill with audio data.
        len: The maximum number of bytes to fill.

    Returns:
        The number of bytes read from the stream or -1 on failure; call
        SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread, but if the
        stream has a callback set, the caller might need to manage
        extra locking.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioStreamData.
    """

    return _get_dylib_function[lib, "SDL_GetAudioStreamData", fn (stream: Ptr[AudioStream, mut=True], buf: Ptr[NoneType, mut=True], len: c_int) -> c_int]()(stream, buf, len)


fn get_audio_stream_available(stream: Ptr[AudioStream, mut=True]) -> c_int:
    """Get the number of converted/resampled bytes available.

    The stream may be buffering data behind the scenes until it has enough to
    resample correctly, so this number might be lower than what you expect, or
    even be zero. Add more data or flush the stream if you need the data now.

    If the stream has so much data that it would overflow an int, the return
    value is clamped to a maximum value, but no queued data is lost; if there
    are gigabytes of data queued, the app might need to read some of it with
    SDL_GetAudioStreamData before this function's return value is no longer
    clamped.

    Args:
        stream: The audio stream to query.

    Returns:
        The number of converted/resampled bytes available or -1 on
        failure; call SDL_GetError() for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioStreamAvailable.
    """

    return _get_dylib_function[lib, "SDL_GetAudioStreamAvailable", fn (stream: Ptr[AudioStream, mut=True]) -> c_int]()(stream)


fn get_audio_stream_queued(stream: Ptr[AudioStream, mut=True]) -> c_int:
    """Get the number of bytes currently queued.

    This is the number of bytes put into a stream as input, not the number that
    can be retrieved as output. Because of several details, it's not possible
    to calculate one number directly from the other. If you need to know how
    much usable data can be retrieved right now, you should use
    SDL_GetAudioStreamAvailable() and not this function.

    Note that audio streams can change their input format at any time, even if
    there is still data queued in a different format, so the returned byte
    count will not necessarily match the number of _sample frames_ available.
    Users of this API should be aware of format changes they make when feeding
    a stream and plan accordingly.

    Queued data is not converted until it is consumed by
    SDL_GetAudioStreamData, so this value should be representative of the exact
    data that was put into the stream.

    If the stream has so much data that it would overflow an int, the return
    value is clamped to a maximum value, but no queued data is lost; if there
    are gigabytes of data queued, the app might need to read some of it with
    SDL_GetAudioStreamData before this function's return value is no longer
    clamped.

    Args:
        stream: The audio stream to query.

    Returns:
        The number of bytes queued or -1 on failure; call SDL_GetError()
        for more information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioStreamQueued.
    """

    return _get_dylib_function[lib, "SDL_GetAudioStreamQueued", fn (stream: Ptr[AudioStream, mut=True]) -> c_int]()(stream)


fn flush_audio_stream(stream: Ptr[AudioStream, mut=True]) raises:
    """Tell the stream that you're done sending data, and anything being buffered
    should be converted/resampled and made available immediately.

    It is legal to add more data to a stream after flushing, but there may be
    audio gaps in the output. Generally this is intended to signal the end of
    input, so the complete output becomes available.

    Args:
        stream: The audio stream to flush.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_FlushAudioStream.
    """

    ret = _get_dylib_function[lib, "SDL_FlushAudioStream", fn (stream: Ptr[AudioStream, mut=True]) -> Bool]()(stream)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn clear_audio_stream(stream: Ptr[AudioStream, mut=True]) raises:
    """Clear any pending data in the stream.

    This drops any queued data, so there will be nothing to read from the
    stream until more is added.

    Args:
        stream: The audio stream to clear.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ClearAudioStream.
    """

    ret = _get_dylib_function[lib, "SDL_ClearAudioStream", fn (stream: Ptr[AudioStream, mut=True]) -> Bool]()(stream)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn pause_audio_stream_device(stream: Ptr[AudioStream, mut=True]) raises:
    """Use this function to pause audio playback on the audio device associated
    with an audio stream.

    This function pauses audio processing for a given device. Any bound audio
    streams will not progress, and no audio will be generated. Pausing one
    device does not prevent other unpaused devices from running.

    Pausing a device can be useful to halt all audio without unbinding all the
    audio streams. This might be useful while a game is paused, or a level is
    loading, etc.

    Args:
        stream: The audio stream associated with the audio device to pause.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_PauseAudioStreamDevice.
    """

    ret = _get_dylib_function[lib, "SDL_PauseAudioStreamDevice", fn (stream: Ptr[AudioStream, mut=True]) -> Bool]()(stream)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn resume_audio_stream_device(stream: Ptr[AudioStream, mut=True]) raises:
    """Use this function to unpause audio playback on the audio device associated
    with an audio stream.

    This function unpauses audio processing for a given device that has
    previously been paused. Once unpaused, any bound audio streams will begin
    to progress again, and audio can be generated.

    Remember, SDL_OpenAudioDeviceStream opens device in a paused state, so this
    function call is required for audio playback to begin on such device.

    Args:
        stream: The audio stream associated with the audio device to resume.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ResumeAudioStreamDevice.
    """

    ret = _get_dylib_function[lib, "SDL_ResumeAudioStreamDevice", fn (stream: Ptr[AudioStream, mut=True]) -> Bool]()(stream)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn audio_stream_device_paused(stream: Ptr[AudioStream, mut=True]) -> Bool:
    """Use this function to query if an audio device associated with a stream is
    paused.

    Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    has to bind a stream before any audio will flow.

    Args:
        stream: The audio stream associated with the audio device to query.

    Returns:
        True if device is valid and paused, false otherwise.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AudioStreamDevicePaused.
    """

    return _get_dylib_function[lib, "SDL_AudioStreamDevicePaused", fn (stream: Ptr[AudioStream, mut=True]) -> Bool]()(stream)


fn lock_audio_stream(stream: Ptr[AudioStream, mut=True]) raises:
    """Lock an audio stream for serialized access.

    Each SDL_AudioStream has an internal mutex it uses to protect its data
    structures from threading conflicts. This function allows an app to lock
    that mutex, which could be useful if registering callbacks on this stream.

    One does not need to lock a stream to use in it most cases, as the stream
    manages this lock internally. However, this lock is held during callbacks,
    which may run from arbitrary threads at any time, so if an app needs to
    protect shared data during those callbacks, locking the stream guarantees
    that the callback is not running while the lock is held.

    As this is just a wrapper over SDL_LockMutex for an internal lock; it has
    all the same attributes (recursive locks are allowed, etc).

    Args:
        stream: The audio stream to lock.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LockAudioStream.
    """

    ret = _get_dylib_function[lib, "SDL_LockAudioStream", fn (stream: Ptr[AudioStream, mut=True]) -> Bool]()(stream)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn unlock_audio_stream(stream: Ptr[AudioStream, mut=True]) raises:
    """Unlock an audio stream for serialized access.

    This unlocks an audio stream after a call to SDL_LockAudioStream.

    Args:
        stream: The audio stream to unlock.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        You should only call this from the same thread that
        previously called SDL_LockAudioStream.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UnlockAudioStream.
    """

    ret = _get_dylib_function[lib, "SDL_UnlockAudioStream", fn (stream: Ptr[AudioStream, mut=True]) -> Bool]()(stream)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


alias AudioStreamCallback = fn (userdata: Ptr[NoneType, mut=True], stream: Ptr[AudioStream, mut=True], additional_amount: c_int, total_amount: c_int) -> None
"""A callback that fires when data passes through an SDL_AudioStream.
    
    Apps can (optionally) register a callback with an audio stream that is
    called when data is added with SDL_PutAudioStreamData, or requested with
    SDL_GetAudioStreamData.
    
    Two values are offered here: one is the amount of additional data needed to
    satisfy the immediate request (which might be zero if the stream already
    has enough data queued) and the other is the total amount being requested.
    In a Get call triggering a Put callback, these values can be different. In
    a Put call triggering a Get callback, these values are always the same.
    
    Byte counts might be slightly overestimated due to buffering or resampling,
    and may change from call to call.
    
    This callback is not required to do anything. Generally this is useful for
    adding/reading data on demand, and the app will often put/get data as
    appropriate, but the system goes on with the data currently available to it
    if this callback does nothing.
    
    Args:
        stream: The SDL audio stream associated with this callback.
        additional_amount: The amount of data, in bytes, that is needed right
                           now.
        total_amount: The total amount of data requested, in bytes, that is
                      requested or available.
        userdata: An opaque pointer provided by the app for their personal
                  use.
    
    Safety:
        This callbacks may run from any thread, so if you need to
        protect shared data, you should use SDL_LockAudioStream to
        serialize access; this lock will be held before your callback
        is called, so your callback does not need to manage the lock
        explicitly.

Docs: https://wiki.libsdl.org/SDL3/SDL_AudioStreamCallback.
"""


fn set_audio_stream_get_callback(stream: Ptr[AudioStream, mut=True], callback: AudioStreamCallback, userdata: Ptr[NoneType, mut=True]) raises:
    """Set a callback that runs when data is requested from an audio stream.

    This callback is called _before_ data is obtained from the stream, giving
    the callback the chance to add more on-demand.

    The callback can (optionally) call SDL_PutAudioStreamData() to add more
    audio to the stream during this call; if needed, the request that triggered
    this callback will obtain the new data immediately.

    The callback's `additional_amount` argument is roughly how many bytes of
    _unconverted_ data (in the stream's input format) is needed by the caller,
    although this may overestimate a little for safety. This takes into account
    how much is already in the stream and only asks for any extra necessary to
    resolve the request, which means the callback may be asked for zero bytes,
    and a different amount on each call.

    The callback is not required to supply exact amounts; it is allowed to
    supply too much or too little or none at all. The caller will get what's
    available, up to the amount they requested, regardless of this callback's
    outcome.

    Clearing or flushing an audio stream does not call this callback.

    This function obtains the stream's lock, which means any existing callback
    (get or put) in progress will finish running before setting the new
    callback.

    Setting a NULL function turns off the callback.

    Args:
        stream: The audio stream to set the new callback on.
        callback: The new callback function to call when data is requested
                  from the stream.
        userdata: An opaque pointer provided to the callback for its own
                  personal use.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information. This only fails if `stream` is NULL.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetAudioStreamGetCallback.
    """

    ret = _get_dylib_function[lib, "SDL_SetAudioStreamGetCallback", fn (stream: Ptr[AudioStream, mut=True], callback: AudioStreamCallback, userdata: Ptr[NoneType, mut=True]) -> Bool]()(stream, callback, userdata)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn set_audio_stream_put_callback(stream: Ptr[AudioStream, mut=True], callback: AudioStreamCallback, userdata: Ptr[NoneType, mut=True]) raises:
    """Set a callback that runs when data is added to an audio stream.

    This callback is called _after_ the data is added to the stream, giving the
    callback the chance to obtain it immediately.

    The callback can (optionally) call SDL_GetAudioStreamData() to obtain audio
    from the stream during this call.

    The callback's `additional_amount` argument is how many bytes of
    _converted_ data (in the stream's output format) was provided by the
    caller, although this may underestimate a little for safety. This value
    might be less than what is currently available in the stream, if data was
    already there, and might be less than the caller provided if the stream
    needs to keep a buffer to aid in resampling. Which means the callback may
    be provided with zero bytes, and a different amount on each call.

    The callback may call SDL_GetAudioStreamAvailable to see the total amount
    currently available to read from the stream, instead of the total provided
    by the current call.

    The callback is not required to obtain all data. It is allowed to read less
    or none at all. Anything not read now simply remains in the stream for
    later access.

    Clearing or flushing an audio stream does not call this callback.

    This function obtains the stream's lock, which means any existing callback
    (get or put) in progress will finish running before setting the new
    callback.

    Setting a NULL function turns off the callback.

    Args:
        stream: The audio stream to set the new callback on.
        callback: The new callback function to call when data is added to the
                  stream.
        userdata: An opaque pointer provided to the callback for its own
                  personal use.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information. This only fails if `stream` is NULL.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetAudioStreamPutCallback.
    """

    ret = _get_dylib_function[lib, "SDL_SetAudioStreamPutCallback", fn (stream: Ptr[AudioStream, mut=True], callback: AudioStreamCallback, userdata: Ptr[NoneType, mut=True]) -> Bool]()(stream, callback, userdata)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn destroy_audio_stream(stream: Ptr[AudioStream, mut=True]) -> None:
    """Free an audio stream.

    This will release all allocated data, including any audio that is still
    queued. You do not need to manually clear the stream first.

    If this stream was bound to an audio device, it is unbound during this
    call. If this stream was created with SDL_OpenAudioDeviceStream, the audio
    device that was opened alongside this stream's creation will be closed,
    too.

    Args:
        stream: The audio stream to destroy.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DestroyAudioStream.
    """

    return _get_dylib_function[lib, "SDL_DestroyAudioStream", fn (stream: Ptr[AudioStream, mut=True]) -> None]()(stream)


fn open_audio_device_stream(devid: AudioDeviceID, spec: Ptr[AudioSpec, mut=False], callback: AudioStreamCallback, userdata: Ptr[NoneType, mut=True], out ret: Ptr[AudioStream, mut=True]) raises:
    """Convenience function for straightforward audio init for the common case.

    If all your app intends to do is provide a single source of PCM audio, this
    function allows you to do all your audio setup in a single call.

    This is also intended to be a clean means to migrate apps from SDL2.

    This function will open an audio device, create a stream and bind it.
    Unlike other methods of setup, the audio device will be closed when this
    stream is destroyed, so the app can treat the returned SDL_AudioStream as
    the only object needed to manage audio playback.

    Also unlike other functions, the audio device begins paused. This is to map
    more closely to SDL2-style behavior, since there is no extra step here to
    bind a stream to begin audio flowing. The audio device should be resumed
    with `SDL_ResumeAudioStreamDevice(stream);`

    This function works with both playback and recording devices.

    The `spec` parameter represents the app's side of the audio stream. That
    is, for recording audio, this will be the output format, and for playing
    audio, this will be the input format. If spec is NULL, the system will
    choose the format, and the app can use SDL_GetAudioStreamFormat() to obtain
    this information later.

    If you don't care about opening a specific audio device, you can (and
    probably _should_), use SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK for playback and
    SDL_AUDIO_DEVICE_DEFAULT_RECORDING for recording.

    One can optionally provide a callback function; if NULL, the app is
    expected to queue audio data for playback (or unqueue audio data if
    capturing). Otherwise, the callback will begin to fire once the device is
    unpaused.

    Destroying the returned stream with SDL_DestroyAudioStream will also close
    the audio device associated with this stream.

    Args:
        devid: An audio device to open, or SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK
               or SDL_AUDIO_DEVICE_DEFAULT_RECORDING.
        spec: The audio stream's data format. Can be NULL.
        callback: A callback where the app will provide new data for
                  playback, or receive new data for recording. Can be NULL,
                  in which case the app will need to call
                  SDL_PutAudioStreamData or SDL_GetAudioStreamData as
                  necessary.
        userdata: App-controlled pointer passed to callback. Can be NULL.
                  Ignored if callback is NULL.

    Returns:
        An audio stream on success, ready to use, or NULL on failure; call
        SDL_GetError() for more information. When done with this stream,
        call SDL_DestroyAudioStream to free resources and close the
        device.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenAudioDeviceStream.
    """

    ret = _get_dylib_function[lib, "SDL_OpenAudioDeviceStream", fn (devid: AudioDeviceID, spec: Ptr[AudioSpec, mut=False], callback: AudioStreamCallback, userdata: Ptr[NoneType, mut=True]) -> Ptr[AudioStream, mut=True]]()(devid, spec, callback, userdata)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


alias AudioPostmixCallback = fn (userdata: Ptr[NoneType, mut=True], spec: Ptr[AudioSpec, mut=False], buffer: Ptr[c_float, mut=True], buflen: c_int) -> None
"""A callback that fires when data is about to be fed to an audio device.
    
    This is useful for accessing the final mix, perhaps for writing a
    visualizer or applying a final effect to the audio data before playback.
    
    This callback should run as quickly as possible and not block for any
    significant time, as this callback delays submission of data to the audio
    device, which can cause audio playback problems.
    
    The postmix callback _must_ be able to handle any audio data format
    specified in `spec`, which can change between callbacks if the audio device
    changed. However, this only covers frequency and channel count; data is
    always provided here in SDL_AUDIO_F32 format.
    
    The postmix callback runs _after_ logical device gain and audiostream gain
    have been applied, which is to say you can make the output data louder at
    this point than the gain settings would suggest.
    
    Args:
        userdata: A pointer provided by the app through
                  SDL_SetAudioPostmixCallback, for its own use.
        spec: The current format of audio that is to be submitted to the
              audio device.
        buffer: The buffer of audio samples to be submitted. The callback can
                inspect and/or modify this data.
        buflen: The size of `buffer` in bytes.
    
    Safety:
        This will run from a background thread owned by SDL. The
        application is responsible for locking resources the callback
        touches that need to be protected.

Docs: https://wiki.libsdl.org/SDL3/SDL_AudioPostmixCallback.
"""


fn set_audio_postmix_callback(devid: AudioDeviceID, callback: AudioPostmixCallback, userdata: Ptr[NoneType, mut=True]) raises:
    """Set a callback that fires when data is about to be fed to an audio device.

    This is useful for accessing the final mix, perhaps for writing a
    visualizer or applying a final effect to the audio data before playback.

    The buffer is the final mix of all bound audio streams on an opened device;
    this callback will fire regularly for any device that is both opened and
    unpaused. If there is no new data to mix, either because no streams are
    bound to the device or all the streams are empty, this callback will still
    fire with the entire buffer set to silence.

    This callback is allowed to make changes to the data; the contents of the
    buffer after this call is what is ultimately passed along to the hardware.

    The callback is always provided the data in float format (values from -1.0f
    to 1.0f), but the number of channels or sample rate may be different than
    the format the app requested when opening the device; SDL might have had to
    manage a conversion behind the scenes, or the playback might have jumped to
    new physical hardware when a system default changed, etc. These details may
    change between calls. Accordingly, the size of the buffer might change
    between calls as well.

    This callback can run at any time, and from any thread; if you need to
    serialize access to your app's data, you should provide and use a mutex or
    other synchronization device.

    All of this to say: there are specific needs this callback can fulfill, but
    it is not the simplest interface. Apps should generally provide audio in
    their preferred format through an SDL_AudioStream and let SDL handle the
    difference.

    This function is extremely time-sensitive; the callback should do the least
    amount of work possible and return as quickly as it can. The longer the
    callback runs, the higher the risk of audio dropouts or other problems.

    This function will block until the audio device is in between iterations,
    so any existing callback that might be running will finish before this
    function sets the new callback and returns.

    Setting a NULL callback function disables any previously-set callback.

    Args:
        devid: The ID of an opened audio device.
        callback: A callback function to be called. Can be NULL.
        userdata: App-controlled pointer passed to callback. Can be NULL.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetAudioPostmixCallback.
    """

    ret = _get_dylib_function[lib, "SDL_SetAudioPostmixCallback", fn (devid: AudioDeviceID, callback: AudioPostmixCallback, userdata: Ptr[NoneType, mut=True]) -> Bool]()(devid, callback, userdata)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn load_wav_io(src: Ptr[IOStream, mut=True], closeio: Bool, spec: Ptr[AudioSpec, mut=True], audio_buf: Ptr[Ptr[UInt8, mut=True], mut=True], audio_len: Ptr[UInt32, mut=True]) raises:
    """Load the audio data of a WAVE file into memory.

    Loading a WAVE file requires `src`, `spec`, `audio_buf` and `audio_len` to
    be valid pointers. The entire data portion of the file is then loaded into
    memory and decoded if necessary.

    Supported formats are RIFF WAVE files with the formats PCM (8, 16, 24, and
    32 bits), IEEE Float (32 bits), Microsoft ADPCM and IMA ADPCM (4 bits), and
    A-law and mu-law (8 bits). Other formats are currently unsupported and
    cause an error.

    If this function succeeds, the return value is zero and the pointer to the
    audio data allocated by the function is written to `audio_buf` and its
    length in bytes to `audio_len`. The SDL_AudioSpec members `freq`,
    `channels`, and `format` are set to the values of the audio data in the
    buffer.

    It's necessary to use SDL_free() to free the audio data returned in
    `audio_buf` when it is no longer used.

    Because of the underspecification of the .WAV format, there are many
    problematic files in the wild that cause issues with strict decoders. To
    provide compatibility with these files, this decoder is lenient in regards
    to the truncation of the file, the fact chunk, and the size of the RIFF
    chunk. The hints `SDL_HINT_WAVE_RIFF_CHUNK_SIZE`,
    `SDL_HINT_WAVE_TRUNCATION`, and `SDL_HINT_WAVE_FACT_CHUNK` can be used to
    tune the behavior of the loading process.

    Any file that is invalid (due to truncation, corruption, or wrong values in
    the headers), too big, or unsupported causes an error. Additionally, any
    critical I/O error from the data source will terminate the loading process
    with an error. The function returns NULL on error and in all cases (with
    the exception of `src` being NULL), an appropriate error message will be
    set.

    It is required that the data source supports seeking.

    Example:

    ```c
    SDL_LoadWAV_IO(SDL_IOFromFile("sample.wav", "rb"), true, &spec, &buf, &len);
    ```

    Note that the SDL_LoadWAV function does this same thing for you, but in a
    less messy way:

    ```c
    SDL_LoadWAV("sample.wav", &spec, &buf, &len);
    ```

    Args:
        src: The data source for the WAVE data.
        closeio: If true, calls SDL_CloseIO() on `src` before returning, even
                 in the case of an error.
        spec: A pointer to an SDL_AudioSpec that will be set to the WAVE
              data's format details on successful return.
        audio_buf: A pointer filled with the audio data, allocated by the
                   function.
        audio_len: A pointer filled with the length of the audio data buffer
                   in bytes.

    Raises:
        True on success. `audio_buf` will be filled with a pointer to an
        allocated buffer containing the audio data, and `audio_len` is
        filled with the length of that audio buffer in bytes.

             This function returns false if the .WAV file cannot be opened,
             uses an unknown data format, or is corrupt; call SDL_GetError()
             for more information.

             When the application is done with the data returned in
             `audio_buf`, it should call SDL_free() to dispose of it.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LoadWAV_IO.
    """

    ret = _get_dylib_function[lib, "SDL_LoadWAV_IO", fn (src: Ptr[IOStream, mut=True], closeio: Bool, spec: Ptr[AudioSpec, mut=True], audio_buf: Ptr[Ptr[UInt8, mut=True], mut=True], audio_len: Ptr[UInt32, mut=True]) -> Bool]()(src, closeio, spec, audio_buf, audio_len)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn load_wav(var path: String, spec: Ptr[AudioSpec, mut=True], audio_buf: Ptr[Ptr[UInt8, mut=True], mut=True], audio_len: Ptr[UInt32, mut=True]) raises:
    """Loads a WAV from a file path.

    This is a convenience function that is effectively the same as:

    ```c
    SDL_LoadWAV_IO(SDL_IOFromFile(path, "rb"), true, spec, audio_buf, audio_len);
    ```

    Args:
        path: The file path of the WAV file to open.
        spec: A pointer to an SDL_AudioSpec that will be set to the WAVE
              data's format details on successful return.
        audio_buf: A pointer filled with the audio data, allocated by the
                   function.
        audio_len: A pointer filled with the length of the audio data buffer
                   in bytes.

    Raises:
        True on success. `audio_buf` will be filled with a pointer to an
        allocated buffer containing the audio data, and `audio_len` is
        filled with the length of that audio buffer in bytes.

             This function returns false if the .WAV file cannot be opened,
             uses an unknown data format, or is corrupt; call SDL_GetError()
             for more information.

             When the application is done with the data returned in
             `audio_buf`, it should call SDL_free() to dispose of it.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LoadWAV.
    """

    ret = _get_dylib_function[lib, "SDL_LoadWAV", fn (path: Ptr[c_char, mut=False], spec: Ptr[AudioSpec, mut=True], audio_buf: Ptr[Ptr[UInt8, mut=True], mut=True], audio_len: Ptr[UInt32, mut=True]) -> Bool]()(path.unsafe_cstr_ptr(), spec, audio_buf, audio_len)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn mix_audio(dst: Ptr[UInt8, mut=True], src: Ptr[UInt8, mut=False], format: AudioFormat, len: UInt32, volume: c_float) raises:
    """Mix audio data in a specified format.

    This takes an audio buffer `src` of `len` bytes of `format` data and mixes
    it into `dst`, performing addition, volume adjustment, and overflow
    clipping. The buffer pointed to by `dst` must also be `len` bytes of
    `format` data.

    This is provided for convenience -- you can mix your own audio data.

    Do not use this function for mixing together more than two streams of
    sample data. The output from repeated application of this function may be
    distorted by clipping, because there is no accumulator with greater range
    than the input (not to mention this being an inefficient way of doing it).

    It is a common misconception that this function is required to write audio
    data to an output stream in an audio callback. While you can do that,
    SDL_MixAudio() is really only needed when you're mixing a single audio
    stream with a volume adjustment.

    Args:
        dst: The destination for the mixed audio.
        src: The source audio buffer to be mixed.
        format: The SDL_AudioFormat structure representing the desired audio
                format.
        len: The length of the audio buffer in bytes.
        volume: Ranges from 0.0 - 1.0, and should be set to 1.0 for full
                audio volume.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_MixAudio.
    """

    ret = _get_dylib_function[lib, "SDL_MixAudio", fn (dst: Ptr[UInt8, mut=True], src: Ptr[UInt8, mut=False], format: AudioFormat, len: UInt32, volume: c_float) -> Bool]()(dst, src, format, len, volume)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn convert_audio_samples(src_spec: Ptr[AudioSpec, mut=False], src_data: Ptr[UInt8, mut=False], src_len: c_int, dst_spec: Ptr[AudioSpec, mut=False], dst_data: Ptr[Ptr[UInt8, mut=True], mut=True], dst_len: Ptr[c_int, mut=True]) raises:
    """Convert some audio data of one format to another format.

    Please note that this function is for convenience, but should not be used
    to resample audio in blocks, as it will introduce audio artifacts on the
    boundaries. You should only use this function if you are converting audio
    data in its entirety in one call. If you want to convert audio in smaller
    chunks, use an SDL_AudioStream, which is designed for this situation.

    Internally, this function creates and destroys an SDL_AudioStream on each
    use, so it's also less efficient than using one directly, if you need to
    convert multiple times.

    Args:
        src_spec: The format details of the input audio.
        src_data: The audio data to be converted.
        src_len: The len of src_data.
        dst_spec: The format details of the output audio.
        dst_data: Will be filled with a pointer to converted audio data,
                  which should be freed with SDL_free(). On error, it will be
                  NULL.
        dst_len: Will be filled with the len of dst_data.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_ConvertAudioSamples.
    """

    ret = _get_dylib_function[lib, "SDL_ConvertAudioSamples", fn (src_spec: Ptr[AudioSpec, mut=False], src_data: Ptr[UInt8, mut=False], src_len: c_int, dst_spec: Ptr[AudioSpec, mut=False], dst_data: Ptr[Ptr[UInt8, mut=True], mut=True], dst_len: Ptr[c_int, mut=True]) -> Bool]()(src_spec, src_data, src_len, dst_spec, dst_data, dst_len)
    if not ret:
        raise String(unsafe_from_utf8_ptr=get_error())


fn get_audio_format_name(format: AudioFormat) -> Ptr[c_char, mut=False]:
    """Get the human readable name of an audio format.

    Args:
        format: The audio format to query.

    Returns:
        The human readable name of the specified audio format or
        "SDL_AUDIO_UNKNOWN" if the format isn't recognized.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetAudioFormatName.
    """

    return _get_dylib_function[lib, "SDL_GetAudioFormatName", fn (format: AudioFormat) -> Ptr[c_char, mut=False]]()(format)


fn get_silence_value_for_format(format: AudioFormat) -> c_int:
    """Get the appropriate memset value for silencing an audio format.

    The value returned by this function can be used as the second argument to
    memset (or SDL_memset) to set an audio buffer in a specific format to
    silence.

    Args:
        format: The audio data format to query.

    Returns:
        A byte value that can be passed to memset.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetSilenceValueForFormat.
    """

    return _get_dylib_function[lib, "SDL_GetSilenceValueForFormat", fn (format: AudioFormat) -> c_int]()(format)
