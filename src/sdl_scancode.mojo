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

"""Scancode

Defines keyboard scancodes.

Please refer to the Best Keyboard Practices document for details on what
this information means and how best to use it.

https://wiki.libsdl.org/SDL3/BestKeyboardPractices
"""


@register_passable("trivial")
struct Scancode(Indexer, Intable):
    """The SDL keyboard scancode representation.

    An SDL scancode is the physical representation of a key on the keyboard,
    independent of language and keyboard mapping.

    Values of this type are used to represent keyboard keys, among other places
    in the `scancode` field of the SDL_KeyboardEvent structure.

    The values in this enumeration are based on the USB usage page standard:
    https://usb.org/sites/default/files/hut1_5.pdf

    Docs: https://wiki.libsdl.org/SDL3/SDL_Scancode.
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
    fn __mlir_index__(self) -> __mlir_type.index:
        return Int(self).__mlir_index__()

    alias SCANCODE_UNKNOWN = Self(0)

    # *  \name Usage page 0x07
    #      *
    #      *  These values are from usage page 0x07 (USB keyboard page).

    alias SCANCODE_A = Self(4)
    alias SCANCODE_B = Self(5)
    alias SCANCODE_C = Self(6)
    alias SCANCODE_D = Self(7)
    alias SCANCODE_E = Self(8)
    alias SCANCODE_F = Self(9)
    alias SCANCODE_G = Self(10)
    alias SCANCODE_H = Self(11)
    alias SCANCODE_I = Self(12)
    alias SCANCODE_J = Self(13)
    alias SCANCODE_K = Self(14)
    alias SCANCODE_L = Self(15)
    alias SCANCODE_M = Self(16)
    alias SCANCODE_N = Self(17)
    alias SCANCODE_O = Self(18)
    alias SCANCODE_P = Self(19)
    alias SCANCODE_Q = Self(20)
    alias SCANCODE_R = Self(21)
    alias SCANCODE_S = Self(22)
    alias SCANCODE_T = Self(23)
    alias SCANCODE_U = Self(24)
    alias SCANCODE_V = Self(25)
    alias SCANCODE_W = Self(26)
    alias SCANCODE_X = Self(27)
    alias SCANCODE_Y = Self(28)
    alias SCANCODE_Z = Self(29)

    alias SCANCODE_1 = Self(30)
    alias SCANCODE_2 = Self(31)
    alias SCANCODE_3 = Self(32)
    alias SCANCODE_4 = Self(33)
    alias SCANCODE_5 = Self(34)
    alias SCANCODE_6 = Self(35)
    alias SCANCODE_7 = Self(36)
    alias SCANCODE_8 = Self(37)
    alias SCANCODE_9 = Self(38)
    alias SCANCODE_0 = Self(39)

    alias SCANCODE_RETURN = Self(40)
    alias SCANCODE_ESCAPE = Self(41)
    alias SCANCODE_BACKSPACE = Self(42)
    alias SCANCODE_TAB = Self(43)
    alias SCANCODE_SPACE = Self(44)

    alias SCANCODE_MINUS = Self(45)
    alias SCANCODE_EQUALS = Self(46)
    alias SCANCODE_LEFTBRACKET = Self(47)
    alias SCANCODE_RIGHTBRACKET = Self(48)
    alias SCANCODE_BACKSLASH = Self(49)
    """Located at the lower left of the return
      key on ISO keyboards and at the right end
      of the QWERTY row on ANSI keyboards.
      Produces REVERSE SOLIDUS (backslash) and
      VERTICAL LINE in a US layout, REVERSE
      SOLIDUS and VERTICAL LINE in a UK Mac
      layout, NUMBER SIGN and TILDE in a UK
      Windows layout, DOLLAR SIGN and POUND SIGN
      in a Swiss German layout, NUMBER SIGN and
      APOSTROPHE in a German layout, GRAVE
      ACCENT and POUND SIGN in a French Mac
      layout, and ASTERISK and MICRO SIGN in a
      French Windows layout."""
    alias SCANCODE_NONUSHASH = Self(50)
    """ISO USB keyboards actually use this code
      instead of 49 for the same key, but all
      OSes I've seen treat the two codes
      identically. So, as an implementor, unless
      your keyboard generates both of those
      codes and your OS treats them differently,
      you should generate SDL_SCANCODE_BACKSLASH
      instead of this code. As a user, you
      should not rely on this code because SDL
      will never generate it with most (all?)
      keyboards."""
    alias SCANCODE_SEMICOLON = Self(51)
    alias SCANCODE_APOSTROPHE = Self(52)
    alias SCANCODE_GRAVE = Self(53)
    """Located in the top left corner (on both ANSI
      and ISO keyboards). Produces GRAVE ACCENT and
      TILDE in a US Windows layout and in US and UK
      Mac layouts on ANSI keyboards, GRAVE ACCENT
      and NOT SIGN in a UK Windows layout, SECTION
      SIGN and PLUS-MINUS SIGN in US and UK Mac
      layouts on ISO keyboards, SECTION SIGN and
      DEGREE SIGN in a Swiss German layout (Mac:
      only on ISO keyboards), CIRCUMFLEX ACCENT and
      DEGREE SIGN in a German layout (Mac: only on
      ISO keyboards), SUPERSCRIPT TWO and TILDE in a
      French Windows layout, COMMERCIAL AT and
      NUMBER SIGN in a French Mac layout on ISO
      keyboards, and LESS-THAN SIGN and GREATER-THAN
      SIGN in a Swiss German, German, or French Mac
      layout on ANSI keyboards."""
    alias SCANCODE_COMMA = Self(54)
    alias SCANCODE_PERIOD = Self(55)
    alias SCANCODE_SLASH = Self(56)

    alias SCANCODE_CAPSLOCK = Self(57)

    alias SCANCODE_F1 = Self(58)
    alias SCANCODE_F2 = Self(59)
    alias SCANCODE_F3 = Self(60)
    alias SCANCODE_F4 = Self(61)
    alias SCANCODE_F5 = Self(62)
    alias SCANCODE_F6 = Self(63)
    alias SCANCODE_F7 = Self(64)
    alias SCANCODE_F8 = Self(65)
    alias SCANCODE_F9 = Self(66)
    alias SCANCODE_F10 = Self(67)
    alias SCANCODE_F11 = Self(68)
    alias SCANCODE_F12 = Self(69)

    alias SCANCODE_PRINTSCREEN = Self(70)
    alias SCANCODE_SCROLLLOCK = Self(71)
    alias SCANCODE_PAUSE = Self(72)
    alias SCANCODE_INSERT = Self(73)
    """Insert on PC, help on some Mac keyboards (but
                                       does send code 73, not 117)."""
    alias SCANCODE_HOME = Self(74)
    alias SCANCODE_PAGEUP = Self(75)
    alias SCANCODE_DELETE = Self(76)
    alias SCANCODE_END = Self(77)
    alias SCANCODE_PAGEDOWN = Self(78)
    alias SCANCODE_RIGHT = Self(79)
    alias SCANCODE_LEFT = Self(80)
    alias SCANCODE_DOWN = Self(81)
    alias SCANCODE_UP = Self(82)

    alias SCANCODE_NUMLOCKCLEAR = Self(83)
    """Num lock on PC, clear on Mac keyboards."""
    alias SCANCODE_KP_DIVIDE = Self(84)
    alias SCANCODE_KP_MULTIPLY = Self(85)
    alias SCANCODE_KP_MINUS = Self(86)
    alias SCANCODE_KP_PLUS = Self(87)
    alias SCANCODE_KP_ENTER = Self(88)
    alias SCANCODE_KP_1 = Self(89)
    alias SCANCODE_KP_2 = Self(90)
    alias SCANCODE_KP_3 = Self(91)
    alias SCANCODE_KP_4 = Self(92)
    alias SCANCODE_KP_5 = Self(93)
    alias SCANCODE_KP_6 = Self(94)
    alias SCANCODE_KP_7 = Self(95)
    alias SCANCODE_KP_8 = Self(96)
    alias SCANCODE_KP_9 = Self(97)
    alias SCANCODE_KP_0 = Self(98)
    alias SCANCODE_KP_PERIOD = Self(99)

    alias SCANCODE_NONUSBACKSLASH = Self(100)
    """This is the additional key that ISO
      keyboards have over ANSI ones,
      located between left shift and Z.
      Produces GRAVE ACCENT and TILDE in a
      US or UK Mac layout, REVERSE SOLIDUS
      (backslash) and VERTICAL LINE in a
      US or UK Windows layout, and
      LESS-THAN SIGN and GREATER-THAN SIGN
      in a Swiss German, German, or French
      layout."""
    alias SCANCODE_APPLICATION = Self(101)
    """Windows contextual menu, compose."""
    alias SCANCODE_POWER = Self(102)
    """The USB document says this is a status flag,
      not a physical key - but some Mac keyboards
      do have a power key."""
    alias SCANCODE_KP_EQUALS = Self(103)
    alias SCANCODE_F13 = Self(104)
    alias SCANCODE_F14 = Self(105)
    alias SCANCODE_F15 = Self(106)
    alias SCANCODE_F16 = Self(107)
    alias SCANCODE_F17 = Self(108)
    alias SCANCODE_F18 = Self(109)
    alias SCANCODE_F19 = Self(110)
    alias SCANCODE_F20 = Self(111)
    alias SCANCODE_F21 = Self(112)
    alias SCANCODE_F22 = Self(113)
    alias SCANCODE_F23 = Self(114)
    alias SCANCODE_F24 = Self(115)
    alias SCANCODE_EXECUTE = Self(116)
    alias SCANCODE_HELP = Self(117)
    """AL Integrated Help Center."""
    alias SCANCODE_MENU = Self(118)
    """Menu (show menu)."""
    alias SCANCODE_SELECT = Self(119)
    alias SCANCODE_STOP = Self(120)
    """AC Stop."""
    alias SCANCODE_AGAIN = Self(121)
    """AC Redo/Repeat."""
    alias SCANCODE_UNDO = Self(122)
    """AC Undo."""
    alias SCANCODE_CUT = Self(123)
    """AC Cut."""
    alias SCANCODE_COPY = Self(124)
    """AC Copy."""
    alias SCANCODE_PASTE = Self(125)
    """AC Paste."""
    alias SCANCODE_FIND = Self(126)
    """AC Find."""
    alias SCANCODE_MUTE = Self(127)
    alias SCANCODE_VOLUMEUP = Self(128)
    alias SCANCODE_VOLUMEDOWN = Self(129)
    # not sure whether there's a reason to enable these
    # SDL_SCANCODE_LOCKINGCAPSLOCK = 130,
    # SDL_SCANCODE_LOCKINGNUMLOCK = 131,
    # SDL_SCANCODE_LOCKINGSCROLLLOCK = 132,
    alias SCANCODE_KP_COMMA = Self(133)
    alias SCANCODE_KP_EQUALSAS400 = Self(134)

    alias SCANCODE_INTERNATIONAL1 = Self(135)
    """Used on Asian keyboards, see
                                                footnotes in USB doc."""
    alias SCANCODE_INTERNATIONAL2 = Self(136)
    alias SCANCODE_INTERNATIONAL3 = Self(137)
    """Yen."""
    alias SCANCODE_INTERNATIONAL4 = Self(138)
    alias SCANCODE_INTERNATIONAL5 = Self(139)
    alias SCANCODE_INTERNATIONAL6 = Self(140)
    alias SCANCODE_INTERNATIONAL7 = Self(141)
    alias SCANCODE_INTERNATIONAL8 = Self(142)
    alias SCANCODE_INTERNATIONAL9 = Self(143)
    alias SCANCODE_LANG1 = Self(144)
    """Hangul/English toggle."""
    alias SCANCODE_LANG2 = Self(145)
    """Hanja conversion."""
    alias SCANCODE_LANG3 = Self(146)
    """Katakana."""
    alias SCANCODE_LANG4 = Self(147)
    """Hiragana."""
    alias SCANCODE_LANG5 = Self(148)
    """Zenkaku/Hankaku."""
    alias SCANCODE_LANG6 = Self(149)
    """Reserved."""
    alias SCANCODE_LANG7 = Self(150)
    """Reserved."""
    alias SCANCODE_LANG8 = Self(151)
    """Reserved."""
    alias SCANCODE_LANG9 = Self(152)
    """Reserved."""

    alias SCANCODE_ALTERASE = Self(153)
    """Erase-Eaze."""
    alias SCANCODE_SYSREQ = Self(154)
    alias SCANCODE_CANCEL = Self(155)
    """AC Cancel."""
    alias SCANCODE_CLEAR = Self(156)
    alias SCANCODE_PRIOR = Self(157)
    alias SCANCODE_RETURN2 = Self(158)
    alias SCANCODE_SEPARATOR = Self(159)
    alias SCANCODE_OUT = Self(160)
    alias SCANCODE_OPER = Self(161)
    alias SCANCODE_CLEARAGAIN = Self(162)
    alias SCANCODE_CRSEL = Self(163)
    alias SCANCODE_EXSEL = Self(164)

    alias SCANCODE_KP_00 = Self(176)
    alias SCANCODE_KP_000 = Self(177)
    alias SCANCODE_THOUSANDSSEPARATOR = Self(178)
    alias SCANCODE_DECIMALSEPARATOR = Self(179)
    alias SCANCODE_CURRENCYUNIT = Self(180)
    alias SCANCODE_CURRENCYSUBUNIT = Self(181)
    alias SCANCODE_KP_LEFTPAREN = Self(182)
    alias SCANCODE_KP_RIGHTPAREN = Self(183)
    alias SCANCODE_KP_LEFTBRACE = Self(184)
    alias SCANCODE_KP_RIGHTBRACE = Self(185)
    alias SCANCODE_KP_TAB = Self(186)
    alias SCANCODE_KP_BACKSPACE = Self(187)
    alias SCANCODE_KP_A = Self(188)
    alias SCANCODE_KP_B = Self(189)
    alias SCANCODE_KP_C = Self(190)
    alias SCANCODE_KP_D = Self(191)
    alias SCANCODE_KP_E = Self(192)
    alias SCANCODE_KP_F = Self(193)
    alias SCANCODE_KP_XOR = Self(194)
    alias SCANCODE_KP_POWER = Self(195)
    alias SCANCODE_KP_PERCENT = Self(196)
    alias SCANCODE_KP_LESS = Self(197)
    alias SCANCODE_KP_GREATER = Self(198)
    alias SCANCODE_KP_AMPERSAND = Self(199)
    alias SCANCODE_KP_DBLAMPERSAND = Self(200)
    alias SCANCODE_KP_VERTICALBAR = Self(201)
    alias SCANCODE_KP_DBLVERTICALBAR = Self(202)
    alias SCANCODE_KP_COLON = Self(203)
    alias SCANCODE_KP_HASH = Self(204)
    alias SCANCODE_KP_SPACE = Self(205)
    alias SCANCODE_KP_AT = Self(206)
    alias SCANCODE_KP_EXCLAM = Self(207)
    alias SCANCODE_KP_MEMSTORE = Self(208)
    alias SCANCODE_KP_MEMRECALL = Self(209)
    alias SCANCODE_KP_MEMCLEAR = Self(210)
    alias SCANCODE_KP_MEMADD = Self(211)
    alias SCANCODE_KP_MEMSUBTRACT = Self(212)
    alias SCANCODE_KP_MEMMULTIPLY = Self(213)
    alias SCANCODE_KP_MEMDIVIDE = Self(214)
    alias SCANCODE_KP_PLUSMINUS = Self(215)
    alias SCANCODE_KP_CLEAR = Self(216)
    alias SCANCODE_KP_CLEARENTRY = Self(217)
    alias SCANCODE_KP_BINARY = Self(218)
    alias SCANCODE_KP_OCTAL = Self(219)
    alias SCANCODE_KP_DECIMAL = Self(220)
    alias SCANCODE_KP_HEXADECIMAL = Self(221)

    alias SCANCODE_LCTRL = Self(224)
    alias SCANCODE_LSHIFT = Self(225)
    alias SCANCODE_LALT = Self(226)
    """Alt, option."""
    alias SCANCODE_LGUI = Self(227)
    """Windows, command (apple), meta."""
    alias SCANCODE_RCTRL = Self(228)
    alias SCANCODE_RSHIFT = Self(229)
    alias SCANCODE_RALT = Self(230)
    """Alt gr, option."""
    alias SCANCODE_RGUI = Self(231)
    """Windows, command (apple), meta."""

    alias SCANCODE_MODE = Self(257)
    """I'm not sure if this is really not covered
      by any of the above, but since there's a
      special SDL_KMOD_MODE for it I'm adding it here."""

    # *  \name Usage page 0x0C
    #      *
    #      *  These values are mapped from usage page 0x0C (USB consumer page).
    #      *
    #      *  There are way more keys in the spec than we can represent in the
    #      *  current scancode range, so pick the ones that commonly come up in
    #      *  real world usage.

    alias SCANCODE_SLEEP = Self(258)
    """Sleep."""
    alias SCANCODE_WAKE = Self(259)
    """Wake."""

    alias SCANCODE_CHANNEL_INCREMENT = Self(260)
    """Channel Increment."""
    alias SCANCODE_CHANNEL_DECREMENT = Self(261)
    """Channel Decrement."""

    alias SCANCODE_MEDIA_PLAY = Self(262)
    """Play."""
    alias SCANCODE_MEDIA_PAUSE = Self(263)
    """Pause."""
    alias SCANCODE_MEDIA_RECORD = Self(264)
    """Record."""
    alias SCANCODE_MEDIA_FAST_FORWARD = Self(265)
    """Fast Forward."""
    alias SCANCODE_MEDIA_REWIND = Self(266)
    """Rewind."""
    alias SCANCODE_MEDIA_NEXT_TRACK = Self(267)
    """Next Track."""
    alias SCANCODE_MEDIA_PREVIOUS_TRACK = Self(268)
    """Previous Track."""
    alias SCANCODE_MEDIA_STOP = Self(269)
    """Stop."""
    alias SCANCODE_MEDIA_EJECT = Self(270)
    """Eject."""
    alias SCANCODE_MEDIA_PLAY_PAUSE = Self(271)
    """Play / Pause."""
    alias SCANCODE_MEDIA_SELECT = Self(272)
    """Media Select."""

    alias SCANCODE_AC_NEW = Self(273)
    """AC New."""
    alias SCANCODE_AC_OPEN = Self(274)
    """AC Open."""
    alias SCANCODE_AC_CLOSE = Self(275)
    """AC Close."""
    alias SCANCODE_AC_EXIT = Self(276)
    """AC Exit."""
    alias SCANCODE_AC_SAVE = Self(277)
    """AC Save."""
    alias SCANCODE_AC_PRINT = Self(278)
    """AC Print."""
    alias SCANCODE_AC_PROPERTIES = Self(279)
    """AC Properties."""

    alias SCANCODE_AC_SEARCH = Self(280)
    """AC Search."""
    alias SCANCODE_AC_HOME = Self(281)
    """AC Home."""
    alias SCANCODE_AC_BACK = Self(282)
    """AC Back."""
    alias SCANCODE_AC_FORWARD = Self(283)
    """AC Forward."""
    alias SCANCODE_AC_STOP = Self(284)
    """AC Stop."""
    alias SCANCODE_AC_REFRESH = Self(285)
    """AC Refresh."""
    alias SCANCODE_AC_BOOKMARKS = Self(286)
    """AC Bookmarks."""

    # *  \name Mobile keys
    #      *
    #      *  These are values that are often used on mobile phones.

    alias SCANCODE_SOFTLEFT = Self(287)
    """Usually situated below the display on phones and
                                          used as a multi-function feature key for selecting
                                          a software defined function shown on the bottom left
                                          of the display."""
    alias SCANCODE_SOFTRIGHT = Self(288)
    """Usually situated below the display on phones and
                                           used as a multi-function feature key for selecting
                                           a software defined function shown on the bottom right
                                           of the display."""
    alias SCANCODE_CALL = Self(289)
    """Used for accepting phone calls."""
    alias SCANCODE_ENDCALL = Self(290)
    """Used for rejecting phone calls."""

    # Add any other keys here.

    alias SCANCODE_RESERVED = Self(400)
    """400-500 reserved for dynamic keycodes."""

    alias SCANCODE_COUNT = Self(512)
    """Not a key, just marks the number of scancodes for array bounds."""
