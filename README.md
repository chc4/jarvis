# saboteur
## Summary
A feature-full bot based on the cambot core.

## Installation
Just clone it!

    $ git clone git://github.com/Camoy/saboteur.git

There are some dependencies that we suggest you install via LuaRocks.  Trust us, it's easier.

    $ # run these as root for proper install
    $ luarocks install luasocket
    $ luarocks install luajson
    $ luarocks install luafilesystem

LuaIRC isn't a rock (sadfaic), but can be installed like so:

    $ git clone git://github.com/doy/luairc.git && cd luairc && sudo make install

## Running
Run the main.lua file inside of the root folder.

    $ lua main.lua

## Usage
See the __cambot__ repository.

## License
saboteur is under the zlib licensed.
