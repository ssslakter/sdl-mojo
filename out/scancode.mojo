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
struct SDL_Scancode(Intable):
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

    alias SDL_SCANCODE_UNKNOWN = 0

    # *  \name Usage page 0x07
    #      *
    #      *  These values are from usage page 0x07 (USB keyboard page).

    alias SDL_SCANCODE_A = 4
    alias SDL_SCANCODE_B = 5
    alias SDL_SCANCODE_C = 6
    alias SDL_SCANCODE_D = 7
    alias SDL_SCANCODE_E = 8
    alias SDL_SCANCODE_F = 9
    alias SDL_SCANCODE_G = 10
    alias SDL_SCANCODE_H = 11
    alias SDL_SCANCODE_I = 12
    alias SDL_SCANCODE_J = 13
    alias SDL_SCANCODE_K = 14
    alias SDL_SCANCODE_L = 15
    alias SDL_SCANCODE_M = 16
    alias SDL_SCANCODE_N = 17
    alias SDL_SCANCODE_O = 18
    alias SDL_SCANCODE_P = 19
    alias SDL_SCANCODE_Q = 20
    alias SDL_SCANCODE_R = 21
    alias SDL_SCANCODE_S = 22
    alias SDL_SCANCODE_T = 23
    alias SDL_SCANCODE_U = 24
    alias SDL_SCANCODE_V = 25
    alias SDL_SCANCODE_W = 26
    alias SDL_SCANCODE_X = 27
    alias SDL_SCANCODE_Y = 28
    alias SDL_SCANCODE_Z = 29

    alias SDL_SCANCODE_1 = 30
    alias SDL_SCANCODE_2 = 31
    alias SDL_SCANCODE_3 = 32
    alias SDL_SCANCODE_4 = 33
    alias SDL_SCANCODE_5 = 34
    alias SDL_SCANCODE_6 = 35
    alias SDL_SCANCODE_7 = 36
    alias SDL_SCANCODE_8 = 37
    alias SDL_SCANCODE_9 = 38
    alias SDL_SCANCODE_0 = 39

    alias SDL_SCANCODE_RETURN = 40
    alias SDL_SCANCODE_ESCAPE = 41
    alias SDL_SCANCODE_BACKSPACE = 42
    alias SDL_SCANCODE_TAB = 43
    alias SDL_SCANCODE_SPACE = 44

    alias SDL_SCANCODE_MINUS = 45
    alias SDL_SCANCODE_EQUALS = 46
    alias SDL_SCANCODE_LEFTBRACKET = 47
    alias SDL_SCANCODE_RIGHTBRACKET = 48
    alias SDL_SCANCODE_BACKSLASH = 49
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
    alias SDL_SCANCODE_NONUSHASH = 50
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
    alias SDL_SCANCODE_SEMICOLON = 51
    alias SDL_SCANCODE_APOSTROPHE = 52
    alias SDL_SCANCODE_GRAVE = 53
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
    alias SDL_SCANCODE_COMMA = 54
    alias SDL_SCANCODE_PERIOD = 55
    alias SDL_SCANCODE_SLASH = 56

    alias SDL_SCANCODE_CAPSLOCK = 57

    alias SDL_SCANCODE_F1 = 58
    alias SDL_SCANCODE_F2 = 59
    alias SDL_SCANCODE_F3 = 60
    alias SDL_SCANCODE_F4 = 61
    alias SDL_SCANCODE_F5 = 62
    alias SDL_SCANCODE_F6 = 63
    alias SDL_SCANCODE_F7 = 64
    alias SDL_SCANCODE_F8 = 65
    alias SDL_SCANCODE_F9 = 66
    alias SDL_SCANCODE_F10 = 67
    alias SDL_SCANCODE_F11 = 68
    alias SDL_SCANCODE_F12 = 69

    alias SDL_SCANCODE_PRINTSCREEN = 70
    alias SDL_SCANCODE_SCROLLLOCK = 71
    alias SDL_SCANCODE_PAUSE = 72
    alias SDL_SCANCODE_INSERT = 73
    """Insert on PC, help on some Mac keyboards (but
                                       does send code 73, not 117)."""
    alias SDL_SCANCODE_HOME = 74
    alias SDL_SCANCODE_PAGEUP = 75
    alias SDL_SCANCODE_DELETE = 76
    alias SDL_SCANCODE_END = 77
    alias SDL_SCANCODE_PAGEDOWN = 78
    alias SDL_SCANCODE_RIGHT = 79
    alias SDL_SCANCODE_LEFT = 80
    alias SDL_SCANCODE_DOWN = 81
    alias SDL_SCANCODE_UP = 82

    alias SDL_SCANCODE_NUMLOCKCLEAR = 83
    """Num lock on PC, clear on Mac keyboards."""
    alias SDL_SCANCODE_KP_DIVIDE = 84
    alias SDL_SCANCODE_KP_MULTIPLY = 85
    alias SDL_SCANCODE_KP_MINUS = 86
    alias SDL_SCANCODE_KP_PLUS = 87
    alias SDL_SCANCODE_KP_ENTER = 88
    alias SDL_SCANCODE_KP_1 = 89
    alias SDL_SCANCODE_KP_2 = 90
    alias SDL_SCANCODE_KP_3 = 91
    alias SDL_SCANCODE_KP_4 = 92
    alias SDL_SCANCODE_KP_5 = 93
    alias SDL_SCANCODE_KP_6 = 94
    alias SDL_SCANCODE_KP_7 = 95
    alias SDL_SCANCODE_KP_8 = 96
    alias SDL_SCANCODE_KP_9 = 97
    alias SDL_SCANCODE_KP_0 = 98
    alias SDL_SCANCODE_KP_PERIOD = 99

    alias SDL_SCANCODE_NONUSBACKSLASH = 100
    """This is the additional key that ISO
      keyboards have over ANSI ones,
      located between left shift and Y.
      Produces GRAVE ACCENT and TILDE in a
      US or UK Mac layout, REVERSE SOLIDUS
      (backslash) and VERTICAL LINE in a
      US or UK Windows layout, and
      LESS-THAN SIGN and GREATER-THAN SIGN
      in a Swiss German, German, or French
      layout."""
    alias SDL_SCANCODE_APPLICATION = 101
    """Windows contextual menu, compose."""
    alias SDL_SCANCODE_POWER = 102
    """The USB document says this is a status flag,
      not a physical key - but some Mac keyboards
      do have a power key."""
    alias SDL_SCANCODE_KP_EQUALS = 103
    alias SDL_SCANCODE_F13 = 104
    alias SDL_SCANCODE_F14 = 105
    alias SDL_SCANCODE_F15 = 106
    alias SDL_SCANCODE_F16 = 107
    alias SDL_SCANCODE_F17 = 108
    alias SDL_SCANCODE_F18 = 109
    alias SDL_SCANCODE_F19 = 110
    alias SDL_SCANCODE_F20 = 111
    alias SDL_SCANCODE_F21 = 112
    alias SDL_SCANCODE_F22 = 113
    alias SDL_SCANCODE_F23 = 114
    alias SDL_SCANCODE_F24 = 115
    alias SDL_SCANCODE_EXECUTE = 116
    alias SDL_SCANCODE_HELP = 117
    """AL Integrated Help Center."""
    alias SDL_SCANCODE_MENU = 118
    """Menu (show menu)."""
    alias SDL_SCANCODE_SELECT = 119
    alias SDL_SCANCODE_STOP = 120
    """AC Stop."""
    alias SDL_SCANCODE_AGAIN = 121
    """AC Redo/Repeat."""
    alias SDL_SCANCODE_UNDO = 122
    """AC Undo."""
    alias SDL_SCANCODE_CUT = 123
    """AC Cut."""
    alias SDL_SCANCODE_COPY = 124
    """AC Copy."""
    alias SDL_SCANCODE_PASTE = 125
    """AC Paste."""
    alias SDL_SCANCODE_FIND = 126
    """AC Find."""
    alias SDL_SCANCODE_MUTE = 127
    alias SDL_SCANCODE_VOLUMEUP = 128
    alias SDL_SCANCODE_VOLUMEDOWN = 129
    # not sure whether there's a reason to enable these
    # SDL_SCANCODE_LOCKINGCAPSLOCK = 130,
    # SDL_SCANCODE_LOCKINGNUMLOCK = 131,
    # SDL_SCANCODE_LOCKINGSCROLLLOCK = 132,
    alias SDL_SCANCODE_KP_COMMA = 133
    alias SDL_SCANCODE_KP_EQUALSAS400 = 134

    alias SDL_SCANCODE_INTERNATIONAL1 = 135
    """Used on Asian keyboards, see
                                                footnotes in USB doc."""
    alias SDL_SCANCODE_INTERNATIONAL2 = 136
    alias SDL_SCANCODE_INTERNATIONAL3 = 137
    """Yen."""
    alias SDL_SCANCODE_INTERNATIONAL4 = 138
    alias SDL_SCANCODE_INTERNATIONAL5 = 139
    alias SDL_SCANCODE_INTERNATIONAL6 = 140
    alias SDL_SCANCODE_INTERNATIONAL7 = 141
    alias SDL_SCANCODE_INTERNATIONAL8 = 142
    alias SDL_SCANCODE_INTERNATIONAL9 = 143
    alias SDL_SCANCODE_LANG1 = 144
    """Hangul/English toggle."""
    alias SDL_SCANCODE_LANG2 = 145
    """Hanja conversion."""
    alias SDL_SCANCODE_LANG3 = 146
    """Katakana."""
    alias SDL_SCANCODE_LANG4 = 147
    """Hiragana."""
    alias SDL_SCANCODE_LANG5 = 148
    """Zenkaku/Hankaku."""
    alias SDL_SCANCODE_LANG6 = 149
    """Reserved."""
    alias SDL_SCANCODE_LANG7 = 150
    """Reserved."""
    alias SDL_SCANCODE_LANG8 = 151
    """Reserved."""
    alias SDL_SCANCODE_LANG9 = 152
    """Reserved."""

    alias SDL_SCANCODE_ALTERASE = 153
    """Erase-Eaze."""
    alias SDL_SCANCODE_SYSREQ = 154
    alias SDL_SCANCODE_CANCEL = 155
    """AC Cancel."""
    alias SDL_SCANCODE_CLEAR = 156
    alias SDL_SCANCODE_PRIOR = 157
    alias SDL_SCANCODE_RETURN2 = 158
    alias SDL_SCANCODE_SEPARATOR = 159
    alias SDL_SCANCODE_OUT = 160
    alias SDL_SCANCODE_OPER = 161
    alias SDL_SCANCODE_CLEARAGAIN = 162
    alias SDL_SCANCODE_CRSEL = 163
    alias SDL_SCANCODE_EXSEL = 164

    alias SDL_SCANCODE_KP_00 = 176
    alias SDL_SCANCODE_KP_000 = 177
    alias SDL_SCANCODE_THOUSANDSSEPARATOR = 178
    alias SDL_SCANCODE_DECIMALSEPARATOR = 179
    alias SDL_SCANCODE_CURRENCYUNIT = 180
    alias SDL_SCANCODE_CURRENCYSUBUNIT = 181
    alias SDL_SCANCODE_KP_LEFTPAREN = 182
    alias SDL_SCANCODE_KP_RIGHTPAREN = 183
    alias SDL_SCANCODE_KP_LEFTBRACE = 184
    alias SDL_SCANCODE_KP_RIGHTBRACE = 185
    alias SDL_SCANCODE_KP_TAB = 186
    alias SDL_SCANCODE_KP_BACKSPACE = 187
    alias SDL_SCANCODE_KP_A = 188
    alias SDL_SCANCODE_KP_B = 189
    alias SDL_SCANCODE_KP_C = 190
    alias SDL_SCANCODE_KP_D = 191
    alias SDL_SCANCODE_KP_E = 192
    alias SDL_SCANCODE_KP_F = 193
    alias SDL_SCANCODE_KP_XOR = 194
    alias SDL_SCANCODE_KP_POWER = 195
    alias SDL_SCANCODE_KP_PERCENT = 196
    alias SDL_SCANCODE_KP_LESS = 197
    alias SDL_SCANCODE_KP_GREATER = 198
    alias SDL_SCANCODE_KP_AMPERSAND = 199
    alias SDL_SCANCODE_KP_DBLAMPERSAND = 200
    alias SDL_SCANCODE_KP_VERTICALBAR = 201
    alias SDL_SCANCODE_KP_DBLVERTICALBAR = 202
    alias SDL_SCANCODE_KP_COLON = 203
    alias SDL_SCANCODE_KP_HASH = 204
    alias SDL_SCANCODE_KP_SPACE = 205
    alias SDL_SCANCODE_KP_AT = 206
    alias SDL_SCANCODE_KP_EXCLAM = 207
    alias SDL_SCANCODE_KP_MEMSTORE = 208
    alias SDL_SCANCODE_KP_MEMRECALL = 209
    alias SDL_SCANCODE_KP_MEMCLEAR = 210
    alias SDL_SCANCODE_KP_MEMADD = 211
    alias SDL_SCANCODE_KP_MEMSUBTRACT = 212
    alias SDL_SCANCODE_KP_MEMMULTIPLY = 213
    alias SDL_SCANCODE_KP_MEMDIVIDE = 214
    alias SDL_SCANCODE_KP_PLUSMINUS = 215
    alias SDL_SCANCODE_KP_CLEAR = 216
    alias SDL_SCANCODE_KP_CLEARENTRY = 217
    alias SDL_SCANCODE_KP_BINARY = 218
    alias SDL_SCANCODE_KP_OCTAL = 219
    alias SDL_SCANCODE_KP_DECIMAL = 220
    alias SDL_SCANCODE_KP_HEXADECIMAL = 221

    alias SDL_SCANCODE_LCTRL = 224
    alias SDL_SCANCODE_LSHIFT = 225
    alias SDL_SCANCODE_LALT = 226
    """Alt, option."""
    alias SDL_SCANCODE_LGUI = 227
    """Windows, command (apple), meta."""
    alias SDL_SCANCODE_RCTRL = 228
    alias SDL_SCANCODE_RSHIFT = 229
    alias SDL_SCANCODE_RALT = 230
    """Alt gr, option."""
    alias SDL_SCANCODE_RGUI = 231
    """Windows, command (apple), meta."""

    alias SDL_SCANCODE_MODE = 257
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

    alias SDL_SCANCODE_SLEEP = 258
    """Sleep."""
    alias SDL_SCANCODE_WAKE = 259
    """Wake."""

    alias SDL_SCANCODE_CHANNEL_INCREMENT = 260
    """Channel Increment."""
    alias SDL_SCANCODE_CHANNEL_DECREMENT = 261
    """Channel Decrement."""

    alias SDL_SCANCODE_MEDIA_PLAY = 262
    """Play."""
    alias SDL_SCANCODE_MEDIA_PAUSE = 263
    """Pause."""
    alias SDL_SCANCODE_MEDIA_RECORD = 264
    """Record."""
    alias SDL_SCANCODE_MEDIA_FAST_FORWARD = 265
    """Fast Forward."""
    alias SDL_SCANCODE_MEDIA_REWIND = 266
    """Rewind."""
    alias SDL_SCANCODE_MEDIA_NEXT_TRACK = 267
    """Next Track."""
    alias SDL_SCANCODE_MEDIA_PREVIOUS_TRACK = 268
    """Previous Track."""
    alias SDL_SCANCODE_MEDIA_STOP = 269
    """Stop."""
    alias SDL_SCANCODE_MEDIA_EJECT = 270
    """Eject."""
    alias SDL_SCANCODE_MEDIA_PLAY_PAUSE = 271
    """Play / Pause."""
    alias SDL_SCANCODE_MEDIA_SELECT = 272
    """Media Select."""

    alias SDL_SCANCODE_AC_NEW = 273
    """AC New."""
    alias SDL_SCANCODE_AC_OPEN = 274
    """AC Open."""
    alias SDL_SCANCODE_AC_CLOSE = 275
    """AC Close."""
    alias SDL_SCANCODE_AC_EXIT = 276
    """AC Exit."""
    alias SDL_SCANCODE_AC_SAVE = 277
    """AC Save."""
    alias SDL_SCANCODE_AC_PRINT = 278
    """AC Print."""
    alias SDL_SCANCODE_AC_PROPERTIES = 279
    """AC Properties."""

    alias SDL_SCANCODE_AC_SEARCH = 280
    """AC Search."""
    alias SDL_SCANCODE_AC_HOME = 281
    """AC Home."""
    alias SDL_SCANCODE_AC_BACK = 282
    """AC Back."""
    alias SDL_SCANCODE_AC_FORWARD = 283
    """AC Forward."""
    alias SDL_SCANCODE_AC_STOP = 284
    """AC Stop."""
    alias SDL_SCANCODE_AC_REFRESH = 285
    """AC Refresh."""
    alias SDL_SCANCODE_AC_BOOKMARKS = 286
    """AC Bookmarks."""

    # *  \name Mobile keys
    #      *
    #      *  These are values that are often used on mobile phones.

    alias SDL_SCANCODE_SOFTLEFT = 287
    """Usually situated below the display on phones and
                                          used as a multi-function feature key for selecting
                                          a software defined function shown on the bottom left
                                          of the display."""
    alias SDL_SCANCODE_SOFTRIGHT = 288
    """Usually situated below the display on phones and
                                           used as a multi-function feature key for selecting
                                           a software defined function shown on the bottom right
                                           of the display."""
    alias SDL_SCANCODE_CALL = 289
    """Used for accepting phone calls."""
    alias SDL_SCANCODE_ENDCALL = 290
    """Used for rejecting phone calls."""

    # Add any other keys here.

    alias SDL_SCANCODE_RESERVED = 400
    """400-500 reserved for dynamic keycodes."""

    alias SDL_SCANCODE_COUNT = 512
    """Not a key, just marks the number of scancodes for array bounds."""
