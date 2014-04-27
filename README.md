autodep-makefile
================

When I want to play with a bit of C++ code I always hate having to tinker with
a build system to get it running when all I want is to compile two sources and
three headers with one library dependency.

This is a dumb Makefile that globs source files from the current directory and
automatically infers interfile dependencies minimising the friction that comes
with setting up a Makefile in general.

Supports debug & release out of directory builds with configurable flags.

Just drop this in a folder of a toy project, change the executable name, set
compiler & linker flags if you need to. Then 'make && build/release/<output>'
and you're done.

This is public domain, feel free to drop it in any miniproject if you want to.
