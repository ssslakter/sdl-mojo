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

"""Joystick

SDL joystick support.

This is the lower-level joystick handling. If you want the simpler option,
where what each button does is well-defined, you should use the gamepad API
instead.

The term "instance_id" is the current instantiation of a joystick device in
the system, if the joystick is removed and then re-inserted then it will
get a new instance_id, instance_id's are monotonically increasing
identifiers of a joystick plugged in.

The term "player_index" is the number assigned to a player on a specific
controller. For XInput controllers this returns the XInput user index. Many
joysticks will not be able to supply this information.

SDL_GUID is used as a stable 128-bit identifier for a joystick device that
does not change over time. It identifies class of the device (a X360 wired
controller for example). This identifier is platform dependent.

In order to use these functions, SDL_Init() must have been called with the
SDL_INIT_JOYSTICK flag. This causes SDL to scan the system for joysticks,
and load appropriate drivers.

If you would like to receive joystick updates while the application is in
the background, you should set the following hint before calling
SDL_Init(): SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS
"""


@fieldwise_init
struct SDL_Joystick(Copyable, Movable):
    """The joystick structure used to identify an SDL joystick.

    This is opaque data.

    Docs: https://wiki.libsdl.org/SDL3/SDL_Joystick.
    """

    pass


@register_passable("trivial")
struct SDL_JoystickID(Intable):
    """This is a unique ID for a joystick for the time it is connected to the
    system, and is never reused for the lifetime of the application.

    If the joystick is disconnected and reconnected, it will get a new ID.

    The value 0 is an invalid ID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_JoystickID.
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


@register_passable("trivial")
struct SDL_JoystickType(Intable):
    """An enum of some common joystick types.

    In some cases, SDL can identify a low-level joystick as being a certain
    type of device, and will report it through SDL_GetJoystickType (or
    SDL_GetJoystickTypeForID).

    This is by no means a complete list of everything that can be plugged into
    a computer.

    Docs: https://wiki.libsdl.org/SDL3/SDL_JoystickType.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_JOYSTICK_TYPE_UNKNOWN = 0
    alias SDL_JOYSTICK_TYPE_GAMEPAD = 1
    alias SDL_JOYSTICK_TYPE_WHEEL = 2
    alias SDL_JOYSTICK_TYPE_ARCADE_STICK = 3
    alias SDL_JOYSTICK_TYPE_FLIGHT_STICK = 4
    alias SDL_JOYSTICK_TYPE_DANCE_PAD = 5
    alias SDL_JOYSTICK_TYPE_GUITAR = 6
    alias SDL_JOYSTICK_TYPE_DRUM_KIT = 7
    alias SDL_JOYSTICK_TYPE_ARCADE_PAD = 8
    alias SDL_JOYSTICK_TYPE_THROTTLE = 9
    alias SDL_JOYSTICK_TYPE_COUNT = 10


@register_passable("trivial")
struct SDL_JoystickConnectionState(Intable):
    """Possible connection states for a joystick device.

    This is used by SDL_GetJoystickConnectionState to report how a device is
    connected to the system.

    Docs: https://wiki.libsdl.org/SDL3/SDL_JoystickConnectionState.
    """

    var value: UInt32

    @always_inline
    fn __init__(out self, value: Int):
        self.value = value

    @always_inline
    fn __int__(self) -> Int:
        return Int(self.value)

    alias SDL_JOYSTICK_CONNECTION_INVALID = -1
    alias SDL_JOYSTICK_CONNECTION_UNKNOWN = 0
    alias SDL_JOYSTICK_CONNECTION_WIRED = 1
    alias SDL_JOYSTICK_CONNECTION_WIRELESS = 2


fn sdl_lock_joysticks() -> None:
    """Locking for atomic access to the joystick API.

    The SDL joystick functions are thread-safe, however you can lock the
    joysticks while processing to guarantee that the joystick list won't change
    and joystick and gamepad events will not be delivered.

    Docs: https://wiki.libsdl.org/SDL3/SDL_LockJoysticks.
    """

    return _get_dylib_function[lib, "SDL_LockJoysticks", fn () -> None]()()


fn sdl_unlock_joysticks() -> None:
    """Unlocking for atomic access to the joystick API.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UnlockJoysticks.
    """

    return _get_dylib_function[lib, "SDL_UnlockJoysticks", fn () -> None]()()


fn sdl_has_joystick() -> Bool:
    """Return whether a joystick is currently connected.

    Returns:
        True if a joystick is connected, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasJoystick.
    """

    return _get_dylib_function[lib, "SDL_HasJoystick", fn () -> Bool]()()


fn sdl_get_joysticks(count: Ptr[c_int, mut=True], out ret: Ptr[SDL_JoystickID, mut=True]) raises:
    """Get a list of currently connected joysticks.

    Args:
        count: A pointer filled in with the number of joysticks returned, may
               be NULL.

    Returns:
        A 0 terminated array of joystick instance IDs or NULL on failure;
        call SDL_GetError() for more information. This should be freed
        with SDL_free() when it is no longer needed.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoysticks.
    """

    ret = _get_dylib_function[lib, "SDL_GetJoysticks", fn (count: Ptr[c_int, mut=True]) -> Ptr[SDL_JoystickID, mut=True]]()(count)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_get_joystick_name_for_id(instance_id: SDL_JoystickID) -> Ptr[c_char, mut=False]:
    """Get the implementation dependent name of a joystick.

    This can be called before any joysticks are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The name of the selected joystick. If no name can be found, this
        function returns NULL; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickNameForID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickNameForID", fn (instance_id: SDL_JoystickID) -> Ptr[c_char, mut=False]]()(instance_id)


fn sdl_get_joystick_path_for_id(instance_id: SDL_JoystickID) -> Ptr[c_char, mut=False]:
    """Get the implementation dependent path of a joystick.

    This can be called before any joysticks are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The path of the selected joystick. If no path can be found, this
        function returns NULL; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickPathForID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickPathForID", fn (instance_id: SDL_JoystickID) -> Ptr[c_char, mut=False]]()(instance_id)


fn sdl_get_joystick_player_index_for_id(instance_id: SDL_JoystickID) -> c_int:
    """Get the player index of a joystick.

    This can be called before any joysticks are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The player index of a joystick, or -1 if it's not available.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickPlayerIndexForID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickPlayerIndexForID", fn (instance_id: SDL_JoystickID) -> c_int]()(instance_id)


fn sdl_get_joystick_guid_for_id(instance_id: SDL_JoystickID) -> SDL_GUID:
    """Get the implementation-dependent GUID of a joystick.

    This can be called before any joysticks are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The GUID of the selected joystick. If called with an invalid
        instance_id, this function returns a zero GUID.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickGUIDForID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickGUIDForID", fn (instance_id: SDL_JoystickID) -> SDL_GUID]()(instance_id)


fn sdl_get_joystick_vendor_for_id(instance_id: SDL_JoystickID) -> UInt16:
    """Get the USB vendor ID of a joystick, if available.

    This can be called before any joysticks are opened. If the vendor ID isn't
    available this function returns 0.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The USB vendor ID of the selected joystick. If called with an
        invalid instance_id, this function returns 0.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickVendorForID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickVendorForID", fn (instance_id: SDL_JoystickID) -> UInt16]()(instance_id)


fn sdl_get_joystick_product_for_id(instance_id: SDL_JoystickID) -> UInt16:
    """Get the USB product ID of a joystick, if available.

    This can be called before any joysticks are opened. If the product ID isn't
    available this function returns 0.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The USB product ID of the selected joystick. If called with an
        invalid instance_id, this function returns 0.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickProductForID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickProductForID", fn (instance_id: SDL_JoystickID) -> UInt16]()(instance_id)


fn sdl_get_joystick_product_version_for_id(instance_id: SDL_JoystickID) -> UInt16:
    """Get the product version of a joystick, if available.

    This can be called before any joysticks are opened. If the product version
    isn't available this function returns 0.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The product version of the selected joystick. If called with an
        invalid instance_id, this function returns 0.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickProductVersionForID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickProductVersionForID", fn (instance_id: SDL_JoystickID) -> UInt16]()(instance_id)


fn sdl_get_joystick_type_for_id(instance_id: SDL_JoystickID) -> SDL_JoystickType:
    """Get the type of a joystick, if available.

    This can be called before any joysticks are opened.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        The SDL_JoystickType of the selected joystick. If called with an
        invalid instance_id, this function returns
        `SDL_JOYSTICK_TYPE_UNKNOWN`.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickTypeForID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickTypeForID", fn (instance_id: SDL_JoystickID) -> SDL_JoystickType]()(instance_id)


fn sdl_open_joystick(instance_id: SDL_JoystickID, out ret: Ptr[SDL_Joystick, mut=True]) raises:
    """Open a joystick for use.

    The joystick subsystem must be initialized before a joystick can be opened
    for use.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        A joystick identifier or NULL on failure; call SDL_GetError() for
        more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_OpenJoystick.
    """

    ret = _get_dylib_function[lib, "SDL_OpenJoystick", fn (instance_id: SDL_JoystickID) -> Ptr[SDL_Joystick, mut=True]]()(instance_id)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_get_joystick_from_id(instance_id: SDL_JoystickID) -> Ptr[SDL_Joystick, mut=True]:
    """Get the SDL_Joystick associated with an instance ID, if it has been opened.

    Args:
        instance_id: The instance ID to get the SDL_Joystick for.

    Returns:
        An SDL_Joystick on success or NULL on failure or if it hasn't been
        opened yet; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickFromID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickFromID", fn (instance_id: SDL_JoystickID) -> Ptr[SDL_Joystick, mut=True]]()(instance_id)


fn sdl_get_joystick_from_player_index(player_index: c_int, out ret: Ptr[SDL_Joystick, mut=True]) raises:
    """Get the SDL_Joystick associated with a player index.

    Args:
        player_index: The player index to get the SDL_Joystick for.

    Returns:
        An SDL_Joystick on success or NULL on failure; call SDL_GetError()
        for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickFromPlayerIndex.
    """

    ret = _get_dylib_function[lib, "SDL_GetJoystickFromPlayerIndex", fn (player_index: c_int) -> Ptr[SDL_Joystick, mut=True]]()(player_index)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


@fieldwise_init
struct SDL_VirtualJoystickTouchpadDesc(Copyable, Movable):
    """The structure that describes a virtual joystick touchpad.

    Docs: https://wiki.libsdl.org/SDL3/SDL_VirtualJoystickTouchpadDesc.
    """

    var nfingers: UInt16
    """The number of simultaneous fingers on this touchpad."""
    var padding: ArrayHelper[UInt16, 3, mut=True].result


@fieldwise_init
struct SDL_VirtualJoystickSensorDesc(Copyable, Movable):
    """The structure that describes a virtual joystick sensor.

    Docs: https://wiki.libsdl.org/SDL3/SDL_VirtualJoystickSensorDesc.
    """

    var type: SDL_SensorType
    """The type of this sensor."""
    var rate: c_float
    """The update frequency of this sensor, may be 0.0f."""


@fieldwise_init
struct SDL_VirtualJoystickDesc(Copyable, Movable):
    """The structure that describes a virtual joystick.

    This structure should be initialized using SDL_INIT_INTERFACE(). All
    elements of this structure are optional.

    Docs: https://wiki.libsdl.org/SDL3/SDL_VirtualJoystickDesc.
    """

    var version: UInt32
    """The version of this interface."""
    var type: UInt16
    """`SDL_JoystickType`."""
    var padding: UInt16
    """Unused."""
    var vendor_id: UInt16
    """The USB vendor ID of this joystick."""
    var product_id: UInt16
    """The USB product ID of this joystick."""
    var naxes: UInt16
    """The number of axes on this joystick."""
    var nbuttons: UInt16
    """The number of buttons on this joystick."""
    var nballs: UInt16
    """The number of balls on this joystick."""
    var nhats: UInt16
    """The number of hats on this joystick."""
    var ntouchpads: UInt16
    """The number of touchpads on this joystick, requires `touchpads` to point at valid descriptions."""
    var nsensors: UInt16
    """The number of sensors on this joystick, requires `sensors` to point at valid descriptions."""
    var padding2: ArrayHelper[UInt16, 2, mut=True].result
    """Unused."""
    var button_mask: UInt32
    """A mask of which buttons are valid for this controller
                                 e.g. (1 << SDL_GAMEPAD_BUTTON_SOUTH)."""
    var axis_mask: UInt32
    """A mask of which axes are valid for this controller
                                 e.g. (1 << SDL_GAMEPAD_AXIS_LEFTX)."""
    var name: Ptr[c_char, mut=False]
    """The name of the joystick."""
    var touchpads: Ptr[SDL_VirtualJoystickTouchpadDesc, mut=False]
    """A pointer to an array of touchpad descriptions, required if `ntouchpads` is > 0."""
    var sensors: Ptr[SDL_VirtualJoystickSensorDesc, mut=False]
    """A pointer to an array of sensor descriptions, required if `nsensors` is > 0."""

    var userdata: Ptr[NoneType, mut=True]
    """User data pointer passed to callbacks."""
    var update: fn (userdata: Ptr[NoneType, mut=True]) -> None
    """Called when the joystick state should be updated."""
    var set_player_index: fn (userdata: Ptr[NoneType, mut=True], player_index: c_int) -> None
    """Called when the player index is set."""
    var rumble: fn (userdata: Ptr[NoneType, mut=True], low_frequency_rumble: UInt16, high_frequency_rumble: UInt16) -> Bool
    """Implements SDL_RumbleJoystick()."""
    var rumble_triggers: fn (userdata: Ptr[NoneType, mut=True], left_rumble: UInt16, right_rumble: UInt16) -> Bool
    """Implements SDL_RumbleJoystickTriggers()."""
    var set_led: fn (userdata: Ptr[NoneType, mut=True], red: UInt8, green: UInt8, blue: UInt8) -> Bool
    """Implements SDL_SetJoystickLED()."""
    var send_effect: fn (userdata: Ptr[NoneType, mut=True], data: Ptr[NoneType, mut=False], size: c_int) -> Bool
    """Implements SDL_SendJoystickEffect()."""
    var set_sensors_enabled: fn (userdata: Ptr[NoneType, mut=True], enabled: Bool) -> Bool
    """Implements SDL_SetGamepadSensorEnabled()."""
    var cleanup: fn (userdata: Ptr[NoneType, mut=True]) -> None
    """Cleans up the userdata when the joystick is detached."""


fn sdl_attach_virtual_joystick(desc: Ptr[SDL_VirtualJoystickDesc, mut=False]) -> SDL_JoystickID:
    """Attach a new virtual joystick.

    Args:
        desc: Joystick description, initialized using SDL_INIT_INTERFACE().

    Returns:
        The joystick instance ID, or 0 on failure; call SDL_GetError() for
        more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_AttachVirtualJoystick.
    """

    return _get_dylib_function[lib, "SDL_AttachVirtualJoystick", fn (desc: Ptr[SDL_VirtualJoystickDesc, mut=False]) -> SDL_JoystickID]()(desc)


fn sdl_detach_virtual_joystick(instance_id: SDL_JoystickID) raises:
    """Detach a virtual joystick.

    Args:
        instance_id: The joystick instance ID, previously returned from
                     SDL_AttachVirtualJoystick().

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_DetachVirtualJoystick.
    """

    ret = _get_dylib_function[lib, "SDL_DetachVirtualJoystick", fn (instance_id: SDL_JoystickID) -> Bool]()(instance_id)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_is_joystick_virtual(instance_id: SDL_JoystickID) -> Bool:
    """Query whether or not a joystick is virtual.

    Args:
        instance_id: The joystick instance ID.

    Returns:
        True if the joystick is virtual, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_IsJoystickVirtual.
    """

    return _get_dylib_function[lib, "SDL_IsJoystickVirtual", fn (instance_id: SDL_JoystickID) -> Bool]()(instance_id)


fn sdl_set_joystick_virtual_axis(joystick: Ptr[SDL_Joystick, mut=True], axis: c_int, value: Int16) raises:
    """Set the state of an axis on an opened virtual joystick.

    Please note that values set here will not be applied until the next call to
    SDL_UpdateJoysticks, which can either be called directly, or can be called
    indirectly through various other SDL APIs, including, but not limited to
    the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
    SDL_WaitEvent.

    Note that when sending trigger axes, you should scale the value to the full
    range of Sint16. For example, a trigger at rest would have the value of
    `SDL_JOYSTICK_AXIS_MIN`.

    Args:
        joystick: The virtual joystick on which to set state.
        axis: The index of the axis on the virtual joystick to update.
        value: The new value for the specified axis.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetJoystickVirtualAxis.
    """

    ret = _get_dylib_function[lib, "SDL_SetJoystickVirtualAxis", fn (joystick: Ptr[SDL_Joystick, mut=True], axis: c_int, value: Int16) -> Bool]()(joystick, axis, value)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_set_joystick_virtual_ball(joystick: Ptr[SDL_Joystick, mut=True], ball: c_int, xrel: Int16, yrel: Int16) raises:
    """Generate ball motion on an opened virtual joystick.

    Please note that values set here will not be applied until the next call to
    SDL_UpdateJoysticks, which can either be called directly, or can be called
    indirectly through various other SDL APIs, including, but not limited to
    the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
    SDL_WaitEvent.

    Args:
        joystick: The virtual joystick on which to set state.
        ball: The index of the ball on the virtual joystick to update.
        xrel: The relative motion on the X axis.
        yrel: The relative motion on the Y axis.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetJoystickVirtualBall.
    """

    ret = _get_dylib_function[lib, "SDL_SetJoystickVirtualBall", fn (joystick: Ptr[SDL_Joystick, mut=True], ball: c_int, xrel: Int16, yrel: Int16) -> Bool]()(joystick, ball, xrel, yrel)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_set_joystick_virtual_button(joystick: Ptr[SDL_Joystick, mut=True], button: c_int, down: Bool) raises:
    """Set the state of a button on an opened virtual joystick.

    Please note that values set here will not be applied until the next call to
    SDL_UpdateJoysticks, which can either be called directly, or can be called
    indirectly through various other SDL APIs, including, but not limited to
    the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
    SDL_WaitEvent.

    Args:
        joystick: The virtual joystick on which to set state.
        button: The index of the button on the virtual joystick to update.
        down: True if the button is pressed, false otherwise.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetJoystickVirtualButton.
    """

    ret = _get_dylib_function[lib, "SDL_SetJoystickVirtualButton", fn (joystick: Ptr[SDL_Joystick, mut=True], button: c_int, down: Bool) -> Bool]()(joystick, button, down)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_set_joystick_virtual_hat(joystick: Ptr[SDL_Joystick, mut=True], hat: c_int, value: UInt8) raises:
    """Set the state of a hat on an opened virtual joystick.

    Please note that values set here will not be applied until the next call to
    SDL_UpdateJoysticks, which can either be called directly, or can be called
    indirectly through various other SDL APIs, including, but not limited to
    the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
    SDL_WaitEvent.

    Args:
        joystick: The virtual joystick on which to set state.
        hat: The index of the hat on the virtual joystick to update.
        value: The new value for the specified hat.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetJoystickVirtualHat.
    """

    ret = _get_dylib_function[lib, "SDL_SetJoystickVirtualHat", fn (joystick: Ptr[SDL_Joystick, mut=True], hat: c_int, value: UInt8) -> Bool]()(joystick, hat, value)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_set_joystick_virtual_touchpad(joystick: Ptr[SDL_Joystick, mut=True], touchpad: c_int, finger: c_int, down: Bool, x: c_float, y: c_float, pressure: c_float) raises:
    """Set touchpad finger state on an opened virtual joystick.

    Please note that values set here will not be applied until the next call to
    SDL_UpdateJoysticks, which can either be called directly, or can be called
    indirectly through various other SDL APIs, including, but not limited to
    the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
    SDL_WaitEvent.

    Args:
        joystick: The virtual joystick on which to set state.
        touchpad: The index of the touchpad on the virtual joystick to
                  update.
        finger: The index of the finger on the touchpad to set.
        down: True if the finger is pressed, false if the finger is released.
        x: The x coordinate of the finger on the touchpad, normalized 0 to 1,
           with the origin in the upper left.
        y: The y coordinate of the finger on the touchpad, normalized 0 to 1,
           with the origin in the upper left.
        pressure: The pressure of the finger.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetJoystickVirtualTouchpad.
    """

    ret = _get_dylib_function[lib, "SDL_SetJoystickVirtualTouchpad", fn (joystick: Ptr[SDL_Joystick, mut=True], touchpad: c_int, finger: c_int, down: Bool, x: c_float, y: c_float, pressure: c_float) -> Bool]()(joystick, touchpad, finger, down, x, y, pressure)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_send_joystick_virtual_sensor_data(joystick: Ptr[SDL_Joystick, mut=True], type: SDL_SensorType, sensor_timestamp: UInt64, data: Ptr[c_float, mut=False], num_values: c_int) raises:
    """Send a sensor update for an opened virtual joystick.

    Please note that values set here will not be applied until the next call to
    SDL_UpdateJoysticks, which can either be called directly, or can be called
    indirectly through various other SDL APIs, including, but not limited to
    the following: SDL_PollEvent, SDL_PumpEvents, SDL_WaitEventTimeout,
    SDL_WaitEvent.

    Args:
        joystick: The virtual joystick on which to set state.
        type: The type of the sensor on the virtual joystick to update.
        sensor_timestamp: A 64-bit timestamp in nanoseconds associated with
                          the sensor reading.
        data: The data associated with the sensor reading.
        num_values: The number of values pointed to by `data`.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SendJoystickVirtualSensorData.
    """

    ret = _get_dylib_function[lib, "SDL_SendJoystickVirtualSensorData", fn (joystick: Ptr[SDL_Joystick, mut=True], type: SDL_SensorType, sensor_timestamp: UInt64, data: Ptr[c_float, mut=False], num_values: c_int) -> Bool]()(joystick, type, sensor_timestamp, data, num_values)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_get_joystick_properties(joystick: Ptr[SDL_Joystick, mut=True]) -> SDL_PropertiesID:
    """Get the properties associated with a joystick.

    The following read-only properties are provided by SDL:

    - `SDL_PROP_JOYSTICK_CAP_MONO_LED_BOOLEAN`: true if this joystick has an
      LED that has adjustable brightness
    - `SDL_PROP_JOYSTICK_CAP_RGB_LED_BOOLEAN`: true if this joystick has an LED
      that has adjustable color
    - `SDL_PROP_JOYSTICK_CAP_PLAYER_LED_BOOLEAN`: true if this joystick has a
      player LED
    - `SDL_PROP_JOYSTICK_CAP_RUMBLE_BOOLEAN`: true if this joystick has
      left/right rumble
    - `SDL_PROP_JOYSTICK_CAP_TRIGGER_RUMBLE_BOOLEAN`: true if this joystick has
      simple trigger rumble

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        A valid property ID on success or 0 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickProperties.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickProperties", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> SDL_PropertiesID]()(joystick)


fn sdl_get_joystick_name(joystick: Ptr[SDL_Joystick, mut=True]) -> Ptr[c_char, mut=False]:
    """Get the implementation dependent name of a joystick.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        The name of the selected joystick. If no name can be found, this
        function returns NULL; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickName.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickName", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> Ptr[c_char, mut=False]]()(joystick)


fn sdl_get_joystick_path(joystick: Ptr[SDL_Joystick, mut=True]) -> Ptr[c_char, mut=False]:
    """Get the implementation dependent path of a joystick.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        The path of the selected joystick. If no path can be found, this
        function returns NULL; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickPath.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickPath", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> Ptr[c_char, mut=False]]()(joystick)


fn sdl_get_joystick_player_index(joystick: Ptr[SDL_Joystick, mut=True]) -> c_int:
    """Get the player index of an opened joystick.

    For XInput controllers this returns the XInput user index. Many joysticks
    will not be able to supply this information.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        The player index, or -1 if it's not available.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickPlayerIndex.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickPlayerIndex", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> c_int]()(joystick)


fn sdl_set_joystick_player_index(joystick: Ptr[SDL_Joystick, mut=True], player_index: c_int) raises:
    """Set the player index of an opened joystick.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().
        player_index: Player index to assign to this joystick, or -1 to clear
                      the player index and turn off player LEDs.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetJoystickPlayerIndex.
    """

    ret = _get_dylib_function[lib, "SDL_SetJoystickPlayerIndex", fn (joystick: Ptr[SDL_Joystick, mut=True], player_index: c_int) -> Bool]()(joystick, player_index)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_get_joystick_guid(joystick: Ptr[SDL_Joystick, mut=True]) -> SDL_GUID:
    """Get the implementation-dependent GUID for the joystick.

    This function requires an open joystick.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        The GUID of the given joystick. If called on an invalid index,
        this function returns a zero GUID; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickGUID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickGUID", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> SDL_GUID]()(joystick)


fn sdl_get_joystick_vendor(joystick: Ptr[SDL_Joystick, mut=True]) -> UInt16:
    """Get the USB vendor ID of an opened joystick, if available.

    If the vendor ID isn't available this function returns 0.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        The USB vendor ID of the selected joystick, or 0 if unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickVendor.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickVendor", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> UInt16]()(joystick)


fn sdl_get_joystick_product(joystick: Ptr[SDL_Joystick, mut=True]) -> UInt16:
    """Get the USB product ID of an opened joystick, if available.

    If the product ID isn't available this function returns 0.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        The USB product ID of the selected joystick, or 0 if unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickProduct.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickProduct", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> UInt16]()(joystick)


fn sdl_get_joystick_product_version(joystick: Ptr[SDL_Joystick, mut=True]) -> UInt16:
    """Get the product version of an opened joystick, if available.

    If the product version isn't available this function returns 0.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        The product version of the selected joystick, or 0 if unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickProductVersion.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickProductVersion", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> UInt16]()(joystick)


fn sdl_get_joystick_firmware_version(joystick: Ptr[SDL_Joystick, mut=True]) -> UInt16:
    """Get the firmware version of an opened joystick, if available.

    If the firmware version isn't available this function returns 0.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        The firmware version of the selected joystick, or 0 if
        unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickFirmwareVersion.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickFirmwareVersion", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> UInt16]()(joystick)


fn sdl_get_joystick_serial(joystick: Ptr[SDL_Joystick, mut=True]) -> Ptr[c_char, mut=False]:
    """Get the serial number of an opened joystick, if available.

    Returns the serial number of the joystick, or NULL if it is not available.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        The serial number of the selected joystick, or NULL if
        unavailable.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickSerial.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickSerial", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> Ptr[c_char, mut=False]]()(joystick)


fn sdl_get_joystick_type(joystick: Ptr[SDL_Joystick, mut=True]) -> SDL_JoystickType:
    """Get the type of an opened joystick.

    Args:
        joystick: The SDL_Joystick obtained from SDL_OpenJoystick().

    Returns:
        The SDL_JoystickType of the selected joystick.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickType.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickType", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> SDL_JoystickType]()(joystick)


fn sdl_get_joystick_guid_info(guid: SDL_GUID, vendor: Ptr[UInt16, mut=True], product: Ptr[UInt16, mut=True], version: Ptr[UInt16, mut=True], crc16: Ptr[UInt16, mut=True]) -> None:
    """Get the device information encoded in a SDL_GUID structure.

    Args:
        guid: The SDL_GUID you wish to get info about.
        vendor: A pointer filled in with the device VID, or 0 if not
                available.
        product: A pointer filled in with the device PID, or 0 if not
                 available.
        version: A pointer filled in with the device version, or 0 if not
                 available.
        crc16: A pointer filled in with a CRC used to distinguish different
               products with the same VID/PID, or 0 if not available.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickGUIDInfo.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickGUIDInfo", fn (guid: SDL_GUID, vendor: Ptr[UInt16, mut=True], product: Ptr[UInt16, mut=True], version: Ptr[UInt16, mut=True], crc16: Ptr[UInt16, mut=True]) -> None]()(guid, vendor, product, version, crc16)


fn sdl_joystick_connected(joystick: Ptr[SDL_Joystick, mut=True]) -> Bool:
    """Get the status of a specified joystick.

    Args:
        joystick: The joystick to query.

    Returns:
        True if the joystick has been opened, false if it has not; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_JoystickConnected.
    """

    return _get_dylib_function[lib, "SDL_JoystickConnected", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> Bool]()(joystick)


fn sdl_get_joystick_id(joystick: Ptr[SDL_Joystick, mut=True]) -> SDL_JoystickID:
    """Get the instance ID of an opened joystick.

    Args:
        joystick: An SDL_Joystick structure containing joystick information.

    Returns:
        The instance ID of the specified joystick on success or 0 on
        failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickID.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickID", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> SDL_JoystickID]()(joystick)


fn sdl_get_num_joystick_axes(joystick: Ptr[SDL_Joystick, mut=True]) -> c_int:
    """Get the number of general axis controls on a joystick.

    Often, the directional pad on a game controller will either look like 4
    separate buttons or a POV hat, and not axes, but all of this is up to the
    device and platform.

    Args:
        joystick: An SDL_Joystick structure containing joystick information.

    Returns:
        The number of axis controls/number of axes on success or -1 on
        failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumJoystickAxes.
    """

    return _get_dylib_function[lib, "SDL_GetNumJoystickAxes", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> c_int]()(joystick)


fn sdl_get_num_joystick_balls(joystick: Ptr[SDL_Joystick, mut=True]) -> c_int:
    """Get the number of trackballs on a joystick.

    Joystick trackballs have only relative motion events associated with them
    and their state cannot be polled.

    Most joysticks do not have trackballs.

    Args:
        joystick: An SDL_Joystick structure containing joystick information.

    Returns:
        The number of trackballs on success or -1 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumJoystickBalls.
    """

    return _get_dylib_function[lib, "SDL_GetNumJoystickBalls", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> c_int]()(joystick)


fn sdl_get_num_joystick_hats(joystick: Ptr[SDL_Joystick, mut=True]) -> c_int:
    """Get the number of POV hats on a joystick.

    Args:
        joystick: An SDL_Joystick structure containing joystick information.

    Returns:
        The number of POV hats on success or -1 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumJoystickHats.
    """

    return _get_dylib_function[lib, "SDL_GetNumJoystickHats", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> c_int]()(joystick)


fn sdl_get_num_joystick_buttons(joystick: Ptr[SDL_Joystick, mut=True]) -> c_int:
    """Get the number of buttons on a joystick.

    Args:
        joystick: An SDL_Joystick structure containing joystick information.

    Returns:
        The number of buttons on success or -1 on failure; call
        SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetNumJoystickButtons.
    """

    return _get_dylib_function[lib, "SDL_GetNumJoystickButtons", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> c_int]()(joystick)


fn sdl_set_joystick_events_enabled(enabled: Bool) -> None:
    """Set the state of joystick event processing.

    If joystick events are disabled, you must call SDL_UpdateJoysticks()
    yourself and check the state of the joystick when you want joystick
    information.

    Args:
        enabled: Whether to process joystick events or not.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetJoystickEventsEnabled.
    """

    return _get_dylib_function[lib, "SDL_SetJoystickEventsEnabled", fn (enabled: Bool) -> None]()(enabled)


fn sdl_joystick_events_enabled() -> Bool:
    """Query the state of joystick event processing.

    If joystick events are disabled, you must call SDL_UpdateJoysticks()
    yourself and check the state of the joystick when you want joystick
    information.

    Returns:
        True if joystick events are being processed, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_JoystickEventsEnabled.
    """

    return _get_dylib_function[lib, "SDL_JoystickEventsEnabled", fn () -> Bool]()()


fn sdl_update_joysticks() -> None:
    """Update the current state of the open joysticks.

    This is called automatically by the event loop if any joystick events are
    enabled.

    Docs: https://wiki.libsdl.org/SDL3/SDL_UpdateJoysticks.
    """

    return _get_dylib_function[lib, "SDL_UpdateJoysticks", fn () -> None]()()


fn sdl_get_joystick_axis(joystick: Ptr[SDL_Joystick, mut=True], axis: c_int) -> Int16:
    """Get the current state of an axis control on a joystick.

    SDL makes no promises about what part of the joystick any given axis refers
    to. Your game should have some sort of configuration UI to let users
    specify what each axis should be bound to. Alternately, SDL's higher-level
    Game Controller API makes a great effort to apply order to this lower-level
    interface, so you know that a specific axis is the "left thumb stick," etc.

    The value returned by SDL_GetJoystickAxis() is a signed integer (-32768 to
    32767) representing the current position of the axis. It may be necessary
    to impose certain tolerances on these values to account for jitter.

    Args:
        joystick: An SDL_Joystick structure containing joystick information.
        axis: The axis to query; the axis indices start at index 0.

    Returns:
        A 16-bit signed integer representing the current position of the
        axis or 0 on failure; call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickAxis.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickAxis", fn (joystick: Ptr[SDL_Joystick, mut=True], axis: c_int) -> Int16]()(joystick, axis)


fn sdl_get_joystick_axis_initial_state(joystick: Ptr[SDL_Joystick, mut=True], axis: c_int, state: Ptr[Int16, mut=True]) -> Bool:
    """Get the initial state of an axis control on a joystick.

    The state is a value ranging from -32768 to 32767.

    The axis indices start at index 0.

    Args:
        joystick: An SDL_Joystick structure containing joystick information.
        axis: The axis to query; the axis indices start at index 0.
        state: Upon return, the initial value is supplied here.

    Returns:
        True if this axis has any initial value, or false if not.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickAxisInitialState.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickAxisInitialState", fn (joystick: Ptr[SDL_Joystick, mut=True], axis: c_int, state: Ptr[Int16, mut=True]) -> Bool]()(joystick, axis, state)


fn sdl_get_joystick_ball(joystick: Ptr[SDL_Joystick, mut=True], ball: c_int, dx: Ptr[c_int, mut=True], dy: Ptr[c_int, mut=True]) raises:
    """Get the ball axis change since the last poll.

    Trackballs can only return relative motion since the last call to
    SDL_GetJoystickBall(), these motion deltas are placed into `dx` and `dy`.

    Most joysticks do not have trackballs.

    Args:
        joystick: The SDL_Joystick to query.
        ball: The ball index to query; ball indices start at index 0.
        dx: Stores the difference in the x axis position since the last poll.
        dy: Stores the difference in the y axis position since the last poll.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickBall.
    """

    ret = _get_dylib_function[lib, "SDL_GetJoystickBall", fn (joystick: Ptr[SDL_Joystick, mut=True], ball: c_int, dx: Ptr[c_int, mut=True], dy: Ptr[c_int, mut=True]) -> Bool]()(joystick, ball, dx, dy)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_get_joystick_hat(joystick: Ptr[SDL_Joystick, mut=True], hat: c_int) -> UInt8:
    """Get the current state of a POV hat on a joystick.

    The returned value will be one of the `SDL_HAT_*` values.

    Args:
        joystick: An SDL_Joystick structure containing joystick information.
        hat: The hat index to get the state from; indices start at index 0.

    Returns:
        The current hat position.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickHat.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickHat", fn (joystick: Ptr[SDL_Joystick, mut=True], hat: c_int) -> UInt8]()(joystick, hat)


fn sdl_get_joystick_button(joystick: Ptr[SDL_Joystick, mut=True], button: c_int) -> Bool:
    """Get the current state of a button on a joystick.

    Args:
        joystick: An SDL_Joystick structure containing joystick information.
        button: The button index to get the state from; indices start at
                index 0.

    Returns:
        True if the button is pressed, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickButton.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickButton", fn (joystick: Ptr[SDL_Joystick, mut=True], button: c_int) -> Bool]()(joystick, button)


fn sdl_rumble_joystick(joystick: Ptr[SDL_Joystick, mut=True], low_frequency_rumble: UInt16, high_frequency_rumble: UInt16, duration_ms: UInt32) -> Bool:
    """Start a rumble effect.

    Each call to this function cancels any previous rumble effect, and calling
    it with 0 intensity stops any rumbling.

    This function requires you to process SDL events or call
    SDL_UpdateJoysticks() to update rumble state.

    Args:
        joystick: The joystick to vibrate.
        low_frequency_rumble: The intensity of the low frequency (left)
                              rumble motor, from 0 to 0xFFFF.
        high_frequency_rumble: The intensity of the high frequency (right)
                               rumble motor, from 0 to 0xFFFF.
        duration_ms: The duration of the rumble effect, in milliseconds.

    Returns:
        True, or false if rumble isn't supported on this joystick.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RumbleJoystick.
    """

    return _get_dylib_function[lib, "SDL_RumbleJoystick", fn (joystick: Ptr[SDL_Joystick, mut=True], low_frequency_rumble: UInt16, high_frequency_rumble: UInt16, duration_ms: UInt32) -> Bool]()(joystick, low_frequency_rumble, high_frequency_rumble, duration_ms)


fn sdl_rumble_joystick_triggers(joystick: Ptr[SDL_Joystick, mut=True], left_rumble: UInt16, right_rumble: UInt16, duration_ms: UInt32) raises:
    """Start a rumble effect in the joystick's triggers.

    Each call to this function cancels any previous trigger rumble effect, and
    calling it with 0 intensity stops any rumbling.

    Note that this is rumbling of the _triggers_ and not the game controller as
    a whole. This is currently only supported on Xbox One controllers. If you
    want the (more common) whole-controller rumble, use SDL_RumbleJoystick()
    instead.

    This function requires you to process SDL events or call
    SDL_UpdateJoysticks() to update rumble state.

    Args:
        joystick: The joystick to vibrate.
        left_rumble: The intensity of the left trigger rumble motor, from 0
                     to 0xFFFF.
        right_rumble: The intensity of the right trigger rumble motor, from 0
                      to 0xFFFF.
        duration_ms: The duration of the rumble effect, in milliseconds.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_RumbleJoystickTriggers.
    """

    ret = _get_dylib_function[lib, "SDL_RumbleJoystickTriggers", fn (joystick: Ptr[SDL_Joystick, mut=True], left_rumble: UInt16, right_rumble: UInt16, duration_ms: UInt32) -> Bool]()(joystick, left_rumble, right_rumble, duration_ms)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_set_joystick_led(joystick: Ptr[SDL_Joystick, mut=True], red: UInt8, green: UInt8, blue: UInt8) raises:
    """Update a joystick's LED color.

    An example of a joystick LED is the light on the back of a PlayStation 4's
    DualShock 4 controller.

    For joysticks with a single color LED, the maximum of the RGB values will
    be used as the LED brightness.

    Args:
        joystick: The joystick to update.
        red: The intensity of the red LED.
        green: The intensity of the green LED.
        blue: The intensity of the blue LED.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SetJoystickLED.
    """

    ret = _get_dylib_function[lib, "SDL_SetJoystickLED", fn (joystick: Ptr[SDL_Joystick, mut=True], red: UInt8, green: UInt8, blue: UInt8) -> Bool]()(joystick, red, green, blue)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_send_joystick_effect(joystick: Ptr[SDL_Joystick, mut=True], data: Ptr[NoneType, mut=False], size: c_int) raises:
    """Send a joystick specific effect packet.

    Args:
        joystick: The joystick to affect.
        data: The data to send to the joystick.
        size: The size of the data to send to the joystick.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_SendJoystickEffect.
    """

    ret = _get_dylib_function[lib, "SDL_SendJoystickEffect", fn (joystick: Ptr[SDL_Joystick, mut=True], data: Ptr[NoneType, mut=False], size: c_int) -> Bool]()(joystick, data, size)
    if not ret:
        raise String(unsafe_from_utf8_ptr=sdl_get_error())


fn sdl_close_joystick(joystick: Ptr[SDL_Joystick, mut=True]) -> None:
    """Close a joystick previously opened with SDL_OpenJoystick().

    Args:
        joystick: The joystick device to close.

    Docs: https://wiki.libsdl.org/SDL3/SDL_CloseJoystick.
    """

    return _get_dylib_function[lib, "SDL_CloseJoystick", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> None]()(joystick)


fn sdl_get_joystick_connection_state(joystick: Ptr[SDL_Joystick, mut=True]) -> SDL_JoystickConnectionState:
    """Get the connection state of a joystick.

    Args:
        joystick: The joystick to query.

    Returns:
        The connection state on success or
        `SDL_JOYSTICK_CONNECTION_INVALID` on failure; call SDL_GetError()
        for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickConnectionState.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickConnectionState", fn (joystick: Ptr[SDL_Joystick, mut=True]) -> SDL_JoystickConnectionState]()(joystick)


fn sdl_get_joystick_power_info(joystick: Ptr[SDL_Joystick, mut=True], percent: Ptr[c_int, mut=True]) -> SDL_PowerState:
    """Get the battery state of a joystick.

    You should never take a battery status as absolute truth. Batteries
    (especially failing batteries) are delicate hardware, and the values
    reported here are best estimates based on what that hardware reports. It's
    not uncommon for older batteries to lose stored power much faster than it
    reports, or completely drain when reporting it has 20 percent left, etc.

    Args:
        joystick: The joystick to query.
        percent: A pointer filled in with the percentage of battery life
                 left, between 0 and 100, or NULL to ignore. This will be
                 filled in with -1 we can't determine a value or there is no
                 battery.

    Returns:
        The current battery state or `SDL_POWERSTATE_ERROR` on failure;
        call SDL_GetError() for more information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetJoystickPowerInfo.
    """

    return _get_dylib_function[lib, "SDL_GetJoystickPowerInfo", fn (joystick: Ptr[SDL_Joystick, mut=True], percent: Ptr[c_int, mut=True]) -> SDL_PowerState]()(joystick, percent)
