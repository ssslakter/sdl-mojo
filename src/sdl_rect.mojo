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

"""Rect

Some helper functions for managing rectangles and 2D points, in both
integer and floating point versions.
"""


@fieldwise_init
struct Point(ImplicitlyCopyable, Movable):
    """The structure that defines a point (using integers).

    Docs: https://wiki.libsdl.org/SDL3/SDL_Point.
    """

    var x: c_int
    var y: c_int


@fieldwise_init
struct FPoint(ImplicitlyCopyable, Movable):
    """The structure that defines a point (using floating point values).

    Docs: https://wiki.libsdl.org/SDL3/SDL_FPoint.
    """

    var x: c_float
    var y: c_float


@fieldwise_init
struct Rect(ImplicitlyCopyable, Movable):
    """A rectangle, with the origin at the upper left (using integers).

    Docs: https://wiki.libsdl.org/SDL3/SDL_Rect.
    """

    var x: c_int
    var y: c_int

    var w: c_int
    var h: c_int


@fieldwise_init
struct FRect(ImplicitlyCopyable, Movable):
    """A rectangle, with the origin at the upper left (using floating point
    values).

    Docs: https://wiki.libsdl.org/SDL3/SDL_FRect.
    """

    var x: c_float
    var y: c_float
    var w: c_float
    var h: c_float


fn has_rect_intersection(a: Ptr[Rect, mut=False], b: Ptr[Rect, mut=False]) -> Bool:
    """Determine whether two rectangles intersect.

    If either pointer is NULL the function will return false.

    Args:
        a: An SDL_Rect structure representing the first rectangle.
        b: An SDL_Rect structure representing the second rectangle.

    Returns:
        True if there is an intersection, false otherwise.

    Safety:
        It is safe to call this function from any thread.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasRectIntersection.
    """

    return _get_sdl_handle()[].get_function[fn (a: Ptr[Rect, mut=False], b: Ptr[Rect, mut=False]) -> Bool]("SDL_HasRectIntersection")(a, b)


fn get_rect_intersection(a: Ptr[Rect, mut=False], b: Ptr[Rect, mut=False], result: Ptr[Rect, mut=True]) -> Bool:
    """Calculate the intersection of two rectangles.

    If `result` is NULL then this function will return false.

    Args:
        a: An SDL_Rect structure representing the first rectangle.
        b: An SDL_Rect structure representing the second rectangle.
        result: An SDL_Rect structure filled in with the intersection of
                rectangles `A` and `B`.

    Returns:
        True if there is an intersection, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRectIntersection.
    """

    return _get_sdl_handle()[].get_function[fn (a: Ptr[Rect, mut=False], b: Ptr[Rect, mut=False], result: Ptr[Rect, mut=True]) -> Bool]("SDL_GetRectIntersection")(a, b, result)


fn get_rect_union(a: Ptr[Rect, mut=False], b: Ptr[Rect, mut=False], result: Ptr[Rect, mut=True]) raises:
    """Calculate the union of two rectangles.

    Args:
        a: An SDL_Rect structure representing the first rectangle.
        b: An SDL_Rect structure representing the second rectangle.
        result: An SDL_Rect structure filled in with the union of rectangles
                `A` and `B`.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRectUnion.
    """

    ret = _get_sdl_handle()[].get_function[fn (a: Ptr[Rect, mut=False], b: Ptr[Rect, mut=False], result: Ptr[Rect, mut=True]) -> Bool]("SDL_GetRectUnion")(a, b, result)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_rect_enclosing_points(points: Ptr[Point, mut=False], count: c_int, clip: Ptr[Rect, mut=False], result: Ptr[Rect, mut=True]) -> Bool:
    """Calculate a minimal rectangle enclosing a set of points.

    If `clip` is not NULL then only points inside of the clipping rectangle are
    considered.

    Args:
        points: An array of SDL_Point structures representing points to be
                enclosed.
        count: The number of structures in the `points` array.
        clip: An SDL_Rect used for clipping or NULL to enclose all points.
        result: An SDL_Rect structure filled in with the minimal enclosing
                rectangle.

    Returns:
        True if any points were enclosed or false if all the points were
        outside of the clipping rectangle.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRectEnclosingPoints.
    """

    return _get_sdl_handle()[].get_function[fn (points: Ptr[Point, mut=False], count: c_int, clip: Ptr[Rect, mut=False], result: Ptr[Rect, mut=True]) -> Bool]("SDL_GetRectEnclosingPoints")(points, count, clip, result)


fn get_rect_and_line_intersection(rect: Ptr[Rect, mut=False], x1: Ptr[c_int, mut=True], y1: Ptr[c_int, mut=True], x2: Ptr[c_int, mut=True], y2: Ptr[c_int, mut=True]) -> Bool:
    """Calculate the intersection of a rectangle and line segment.

    This function is used to clip a line segment to a rectangle. A line segment
    contained entirely within the rectangle or that does not intersect will
    remain unchanged. A line segment that crosses the rectangle at either or
    both ends will be clipped to the boundary of the rectangle and the new
    coordinates saved in `X1`, `Y1`, `X2`, and/or `Y2` as necessary.

    Args:
        rect: An SDL_Rect structure representing the rectangle to intersect.
        x1: A pointer to the starting X-coordinate of the line.
        y1: A pointer to the starting Y-coordinate of the line.
        x2: A pointer to the ending X-coordinate of the line.
        y2: A pointer to the ending Y-coordinate of the line.

    Returns:
        True if there is an intersection, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRectAndLineIntersection.
    """

    return _get_sdl_handle()[].get_function[fn (rect: Ptr[Rect, mut=False], x1: Ptr[c_int, mut=True], y1: Ptr[c_int, mut=True], x2: Ptr[c_int, mut=True], y2: Ptr[c_int, mut=True]) -> Bool]("SDL_GetRectAndLineIntersection")(rect, x1, y1, x2, y2)


fn has_rect_intersection_float(a: Ptr[FRect, mut=False], b: Ptr[FRect, mut=False]) -> Bool:
    """Determine whether two rectangles intersect with float precision.

    If either pointer is NULL the function will return false.

    Args:
        a: An SDL_FRect structure representing the first rectangle.
        b: An SDL_FRect structure representing the second rectangle.

    Returns:
        True if there is an intersection, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_HasRectIntersectionFloat.
    """

    return _get_sdl_handle()[].get_function[fn (a: Ptr[FRect, mut=False], b: Ptr[FRect, mut=False]) -> Bool]("SDL_HasRectIntersectionFloat")(a, b)


fn get_rect_intersection_float(a: Ptr[FRect, mut=False], b: Ptr[FRect, mut=False], result: Ptr[FRect, mut=True]) -> Bool:
    """Calculate the intersection of two rectangles with float precision.

    If `result` is NULL then this function will return false.

    Args:
        a: An SDL_FRect structure representing the first rectangle.
        b: An SDL_FRect structure representing the second rectangle.
        result: An SDL_FRect structure filled in with the intersection of
                rectangles `A` and `B`.

    Returns:
        True if there is an intersection, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRectIntersectionFloat.
    """

    return _get_sdl_handle()[].get_function[fn (a: Ptr[FRect, mut=False], b: Ptr[FRect, mut=False], result: Ptr[FRect, mut=True]) -> Bool]("SDL_GetRectIntersectionFloat")(a, b, result)


fn get_rect_union_float(a: Ptr[FRect, mut=False], b: Ptr[FRect, mut=False], result: Ptr[FRect, mut=True]) raises:
    """Calculate the union of two rectangles with float precision.

    Args:
        a: An SDL_FRect structure representing the first rectangle.
        b: An SDL_FRect structure representing the second rectangle.
        result: An SDL_FRect structure filled in with the union of rectangles
                `A` and `B`.

    Raises:
        Raises on failure; call SDL_GetError() for more
        information.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRectUnionFloat.
    """

    ret = _get_sdl_handle()[].get_function[fn (a: Ptr[FRect, mut=False], b: Ptr[FRect, mut=False], result: Ptr[FRect, mut=True]) -> Bool]("SDL_GetRectUnionFloat")(a, b, result)
    if not ret:
        raise Error(String(unsafe_from_utf8_ptr=get_error()))


fn get_rect_enclosing_points_float(points: Ptr[FPoint, mut=False], count: c_int, clip: Ptr[FRect, mut=False], result: Ptr[FRect, mut=True]) -> Bool:
    """Calculate a minimal rectangle enclosing a set of points with float
    precision.

    If `clip` is not NULL then only points inside of the clipping rectangle are
    considered.

    Args:
        points: An array of SDL_FPoint structures representing points to be
                enclosed.
        count: The number of structures in the `points` array.
        clip: An SDL_FRect used for clipping or NULL to enclose all points.
        result: An SDL_FRect structure filled in with the minimal enclosing
                rectangle.

    Returns:
        True if any points were enclosed or false if all the points were
        outside of the clipping rectangle.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRectEnclosingPointsFloat.
    """

    return _get_sdl_handle()[].get_function[fn (points: Ptr[FPoint, mut=False], count: c_int, clip: Ptr[FRect, mut=False], result: Ptr[FRect, mut=True]) -> Bool]("SDL_GetRectEnclosingPointsFloat")(points, count, clip, result)


fn get_rect_and_line_intersection_float(rect: Ptr[FRect, mut=False], x1: Ptr[c_float, mut=True], y1: Ptr[c_float, mut=True], x2: Ptr[c_float, mut=True], y2: Ptr[c_float, mut=True]) -> Bool:
    """Calculate the intersection of a rectangle and line segment with float
    precision.

    This function is used to clip a line segment to a rectangle. A line segment
    contained entirely within the rectangle or that does not intersect will
    remain unchanged. A line segment that crosses the rectangle at either or
    both ends will be clipped to the boundary of the rectangle and the new
    coordinates saved in `X1`, `Y1`, `X2`, and/or `Y2` as necessary.

    Args:
        rect: An SDL_FRect structure representing the rectangle to intersect.
        x1: A pointer to the starting X-coordinate of the line.
        y1: A pointer to the starting Y-coordinate of the line.
        x2: A pointer to the ending X-coordinate of the line.
        y2: A pointer to the ending Y-coordinate of the line.

    Returns:
        True if there is an intersection, false otherwise.

    Docs: https://wiki.libsdl.org/SDL3/SDL_GetRectAndLineIntersectionFloat.
    """

    return _get_sdl_handle()[].get_function[fn (rect: Ptr[FRect, mut=False], x1: Ptr[c_float, mut=True], y1: Ptr[c_float, mut=True], x2: Ptr[c_float, mut=True], y2: Ptr[c_float, mut=True]) -> Bool]("SDL_GetRectAndLineIntersectionFloat")(rect, x1, y1, x2, y2)
