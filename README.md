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
Commands can be written in any language and are included in the commands folder.  Remember to set the file to executable (`chmod 755 command`) or else jarvis won't be able to run it.  As soon as a command is in that folder, it can be used by jarvis without a restart.  Passed to that executable is first the username who owns the message and second is the message itself.

The passive.lua file returns a table where the keys are string patterns to be looked for when a user types something, and the value is a function whose return value should be something that jarvis says.  Passed to that function as arguments are the username and the message itself.

## Configuration File

Jarvis supports a JSON configuration file. The following example demonstrates
use of all the available options and their possible values.

    {
      "network": "irc.freenode.net",
      "prelude": "!",
      "log": true,

      "nick": "_jarvis",
      "channel": [ "##codelab" ],
      "admins": {
        "KnightMustard": 1,
        "dunsmoreb": 1,
        "camoy": 1,
        "Socks": 1
      }
    }

Once you have made your configuration file, go into `main.lua` and change the
following line, line seven, to the location of your configuration file.

    local CONFIG_FILE = nil

## License
jarvis is under the zlib license.
