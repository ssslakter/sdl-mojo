# x--------------------------------------------------------------------------x #
# | SDL3 Bindings in Mojo
# x--------------------------------------------------------------------------x #

"""SDL3 Bindings in Mojo"""

from .audio import *
from .blendmode import *
from .camera import *
from .clipboard import *
from .error import *
from .events import *
from .filesystem import *
from .gamepad import *
from .gpu import *
from .guid import *
from .haptic import *
from .hints import *
from .init import *
from .iostream import *
from .joystick import *
from .keyboard import *
from .keycode import *
from .mouse import *
from .pen import *
from .pixels import *
from .power import *
from .properties import *
from .rect import *
from .render import *
from .scancode import *
from .sensor import *
from .storage import *
from .surface import *
from .time import *
from .timer import *
from .touch import *
from .version import *
from .video import *


alias Ptr = stdlib.memory.UnsafePointer


from sys import os_is_linux, os_is_macos, is_little_endian, is_big_endian
from sys.ffi import _Global, _OwnedDLHandle, _get_dylib_function, c_char, c_uchar, c_int, c_uint, c_short, c_ushort, c_long, c_long_long, c_size_t, c_ssize_t, c_float, c_double

alias lib = _Global["SDL", _OwnedDLHandle, _init_sdl_handle]()


fn _init_sdl_handle() -> _OwnedDLHandle:
    try:

        @parameter
        if os_is_macos():
            return _OwnedDLHandle(".magic/envs/default/lib/libSDL3.dylib")
        elif os_is_linux():
            return _OwnedDLHandle(".magic/envs/default/lib/libSDL3.so")
        else:
            constrained[False, "OS is not supported"]()
            return _uninit[_OwnedDLHandle]()
    except:
        print("no sdl")
        return _uninit[_OwnedDLHandle]()


@always_inline
fn _uninit[T: AnyType](out value: T):
    """Returns uninitialized data."""
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(value))


struct ArrayHelper[type: Copyable & Movable, size: Int, *, mut: Bool = True]:
    alias result = Ptr[InlineArray[type, size], mut=mut]
