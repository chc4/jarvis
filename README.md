# jarvis
## Summary
A feature-full Lua IRC bot.

## Installation
Just clone it!

    $ git clone git://github.com/Camoy/jarvis.git

There are some dependencies that we suggest you install via LuaRocks.  Trust us, it's easier.

    $ # run these as root for proper install
    $ luarocks install luasocket
    $ luarocks install luajson
    $ luarocks install luafilesystem

LuaIRC isn't a rock (sadfaic), but can be installed like so:

    $ # remember to run make install as root
    $ git clone git://github.com/doy/luairc.git && cd luairc && make install

## Running
Run the main.lua file inside of the root folder.

    $ lua main.lua

## Usage
Commands are written in Lua and are included in the commands folder.

The passive.lua file returns a table where the keys are string patterns to be looked for when a user types something, and the value is a function whose return value should be something that jarvis says.  Passed to that function as arguments are the username and the message itself.

## Configuration File
Jarvis supports a Lua configuration file. The provided `config.lua` demonstrates
use of all the available options and their possible values.

Once you have made your configuration file, go into `main.lua` and change the
following line, to the location of your configuration file.

    local CONFIG = "PATH.lua"

## Authors
Jarvis is primarily maintained by camoy.  Thanks to others who have contributed to its development.

* KnightMustard
* dunsmoreb
* chc4
* JustAPerson
* Nasuga

## License
Copyright (C) 2013 Jarvis Authors

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.
