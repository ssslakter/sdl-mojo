# Bindings for SDL3 in Mojo
This library generates and provides bindings for SDL3 in mojo.

# Using SDL3 in Mojo
You can take a look at the [test file](./test/test.mojo), or check out the [sdl3 documentation](https://wiki.libsdl.org/SDL3/FrontPage).

note: `sdl-mojo` is not on the Modular community channel yet.

# Generating and Building the Bindings
If you havent already, Install [pixi](https://pixi.sh/) with:

`curl -fsSL https://pixi.sh/install.sh | sh`

Then, run `pixi run build` to generate and build the bindings.

Once it's finished, run `pixi run test` to test the bindings.

# Notes
The generator attempts to turn cases of error on null, and error on false, into raising functions. 
It also turns char pointers into strings, in some cases.

Needs more testing and on different hardware. If anything breaks, please open an issue.