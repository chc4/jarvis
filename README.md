# cambot
## Summary
Camoy's personal bot written in Lua.

## Installation
Just clone it!

    $ git clone git://github.com/Camoy/cambot.git

Also make sure that you have LuaSocket and LuaIRC installed.  I suggest installing LuaSocket via LuaRocks.

    $ luarocks install luasocket

LuaIRC can be installed like so:

    $ git clone git://github.com/doy/luairc.git && cd luairc && sudo make install

## Running
Run the main.lua file inside of the root folder.

    $ lua main.lua

## Usage
Commands can be written in any language and are included in the commands folder.  Remember to set the file to executable (`chmod 755 command`) or else cambot won't be able to run it.  As soon as a command is in that folder, it can be used by cambot without a restart.

## License
cambot is under the zlib licensed.
