# saboteur
## Summary
A feature-full bot based on the cambot core.

## Installation
Just clone it!

    $ git clone git://github.com/Camoy/saboteur.git

Also make sure that you have LuaSocket, LuaJSON, and LuaIRC installed.  I suggest installing LuaSocket & LuaJSON via LuaRocks.

    $ # run these as root for proper install
    $ luarocks install luasocket
    $ luarocks install luajson

LuaIRC can be installed like so:

    $ git clone git://github.com/doy/luairc.git && cd luairc && sudo make install

## Running
Run the main.lua file inside of the root folder.

    $ lua main.lua

## Usage
See the __cambot__ repository.

## License
saboteur is under the zlib licensed.
