# x--------------------------------------------------------------------------x #
# | SDL3 Bindings in Mojo
# x--------------------------------------------------------------------------x #
#
# This program tests if the bindings are correct
#
# Please add more test cases and open issues if anything breaks!
#
from sdl import *
from time import monotonic
from math import sqrt

def main():
    print("press WASD to move box")
    alias screen_width = 640
    alias screen_height = 480
    sdl_init(SDL_InitFlags.SDL_INIT_VIDEO | SDL_InitFlags.SDL_INIT_AUDIO | SDL_InitFlags.SDL_INIT_EVENTS | SDL_InitFlags.SDL_INIT_JOYSTICK | SDL_InitFlags.SDL_INIT_GAMEPAD)

    var window = Ptr[SDL_Window]()
    var renderer = Ptr[SDL_Renderer]()
    sdl_create_window_and_renderer("sdl3 test", screen_width, screen_height, SDL_WindowFlags(0), Ptr(to=window), Ptr(to=renderer))

    var running = True
    var numkeys = Int32()
    var key_state = Span(_data=sdl_get_keyboard_state(Ptr(to=numkeys)), _len=Int(numkeys))
    var rect = SDL_FRect(0, 0, 100, 100)
    var thing = SDL_FRect((screen_width / Float32(2)) - 50, (screen_height / Float32(2)) - 50, 100, 100)
    var ticks = monotonic()
    var delta_time = Float32(0)

    while running:
        var event = SDL_Event(UInt32(0))
        while sdl_poll_event(Ptr(to=event)):
            if event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_QUIT:
                running = False
            elif event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_MOUSE_MOTION:
                var event_ = event[SDL_MouseMotionEvent]
                rect.x = event_.x - 50
                rect.y = event_.y - 50
            elif event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_JOYSTICK_AXIS_MOTION:
                print("SDL_EVENT_JOYSTICK_AXIS_MOTION")
            elif event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED:
                print("SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED")
            elif event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_WINDOW_MOVED:
                print("SDL_EVENT_WINDOW_MOVED")
            elif event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_AUDIO_DEVICE_ADDED:
                print("SDL_EVENT_AUDIO_DEVICE_ADDED")
            elif event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_CLIPBOARD_UPDATE:
                print("SDL_EVENT_CLIPBOARD_UPDATE")
            elif event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_DROP_TEXT:
                print("SDL_EVENT_DROP_TEXT")
            elif event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_DROP_BEGIN:
                print("SDL_EVENT_DROP_BEGIN")
            elif event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_DROP_FILE:
                print("SDL_EVENT_DROP_FILE")
            elif event[SDL_CommonEvent].type == SDL_EventType.SDL_EVENT_GAMEPAD_ADDED:
                print("SDL_EVENT_GAMEPAD_ADDED")


        var acc = SDL_FPoint(0, 0)
        if key_state[SDL_Scancode.SDL_SCANCODE_W]:
            acc.y -= 1
        if key_state[SDL_Scancode.SDL_SCANCODE_A]:
            acc.x -= 1
        if key_state[SDL_Scancode.SDL_SCANCODE_S]:
            acc.y += 1
        if key_state[SDL_Scancode.SDL_SCANCODE_D]:
            acc.x += 1
        mag = sqrt(acc.x*acc.x + acc.y*acc.y) or 1
        thing.x += (acc.x / mag) * delta_time
        thing.y += (acc.y / mag) * delta_time

        thing.x = min(max(0, thing.x), screen_width - thing.w)
        thing.y = min(max(0, thing.y), screen_height - thing.h)
        rect.x = min(max(0, rect.x), screen_width - rect.w)
        rect.y = min(max(0, rect.y), screen_height - rect.h)

        sdl_set_render_draw_color(renderer, 4, 8, 16, 100)
        sdl_render_clear(renderer)
        sdl_set_render_draw_color(renderer, 100, 50, 50, 100)
        sdl_render_fill_rect(renderer, Ptr(to=rect))
        sdl_set_render_draw_color(renderer, 50, 100, 50, 100)
        sdl_render_fill_rect(renderer, Ptr(to=thing))
        sdl_render_present(renderer)

        new_ticks = monotonic()
        delta_time = Float32()
        while delta_time < 0.01:
            new_ticks = monotonic()
            delta_time = Float32(new_ticks - ticks) / 1000000.0
        ticks = new_ticks

    sdl_quit()