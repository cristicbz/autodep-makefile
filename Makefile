# ==============================================================================
# Simple, generic Makefile for small C++ projects.
#
# Written by C. Cobzarenco (github.com/cristicbz) with autodependency inference
# by Scott McPeak, lifted from
# 	http://scottmcpeak.com/autodepend/autodepend.html
#
# -----------------------------------------------------------------------------
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>
# ==============================================================================

# Name of executable.
OUTPUT:=exec

# Glob source files from current dir.
SRCS:=$(wildcard *.cpp *.c *.cc *.cxx)

# Compiler and linker flags.
CXXFLAGS:=-g
LDFLAGS:=

# Release specific flags.
RELEASE_CXXFLAGS:=-O3
RELEASE_LDFLAGS:=

# Debug specific flags.
DEBUG_CXXFLAGS:=-O0
DEBUG_LDFLAGS:=


# ======================= END OF CONFIGURABLE THINGS ===========================
# Create debug & release list of object files as well as dep files.
BASEFILES:=$(basename $(SRCS))
DEBUG_OBJS:=$(addprefix build/debug/,$(addsuffix .o,$(BASEFILES)))
RELEASE_OBJS:=$(addprefix build/release/,$(addsuffix .o,$(BASEFILES)))
DEPFILES:=$(addprefix build/deps/,$(addsuffix .d,$(BASEFILES)))

# Default to release build.
all: release

# Compilation flags.
compile_commands:
	@echo 'generating compilation database...'
	@echo -n '[' > ${COMPILE_DB} ; \
	for src in ${SRCS} ; do \
	  if [ -z "$$nocomma" ]; then \
       	    nocomma=1 ; \
	  else \
	    echo ',' >> ${COMPILE_DB} ; \
	  fi ; \
	  echo '{ "directory": "'"$(shell pwd)"'",' >> ${COMPILE_DB} ; \
	  echo '  "file": "'"$(abspath $$src)"'",' >> ${COMPILE_DB} ; \
	  echo -n '  "command": "'"${CXX} ${CXXFLAGS} -c $$src"'" }' >> ${COMPILE_DB} ; \
	done ; \
	echo ']' >> ${COMPILE_DB}


# Directory targets
build/debug:
	@echo creating debug directory
	@mkdir -p build/debug build/deps

build/release:
	@echo creating release directory
	@mkdir -p build/release build/deps

# Debug route.
.PHONY: debug
debug: COMPILE_DB:=build/debug/compile_commands.json
debug: CXXFLAGS+= $(DEBUG_CXXFLAGS)
debug: LDFLAGS+= $(DEBUG_LDFLAGS)
debug: build/debug
debug: compile_commands
debug: build/debug/$(OUTPUT)

build/debug/$(OUTPUT): build/debug $(DEBUG_OBJS)
	@echo 'linking ' build/debug/$(OUTPUT)
	@$(CXX) -o build/debug/$(OUTPUT) $(DEBUG_OBJS) $(LDFLAGS)

-include $(DEPFILES)

build/debug/%.o : %.cpp
	@echo 'compiling ' $<
	@$(CXX) -c $(CXXFLAGS) $< -o $@
	@$(CXX) -MM $(CXXFLAGS) $< -o build/deps/$*.d
	@mv -f build/deps/$*.d build/deps/$*.d.tmp
	@sed -e 's|.*:|build/debug/$*.o:|' < build/deps/$*.d.tmp \
	  > build/deps/$*.d
	@sed -e 's/.*://' -e 's/\\$$//' < build/deps/$*.d.tmp | fmt -1 \
	  | sed -e 's/^ *//' -e 's/$$/:/' >> build/deps/$*.d
	@rm -f build/deps/$*.d.tmp

# Release route.
.PHONY: release
release: COMPILE_DB:=build/release/compile_commands.json
release: CXXFLAGS+= $(RELEASE_CXXFLAGS)
release: LDFLAGS+= $(RELEASE_LDFLAGS)
release: build/release
release: compile_commands
release: build/release/$(OUTPUT)

build/release/$(OUTPUT): build/release $(RELEASE_OBJS)
	@echo 'linking ' build/release/$(OUTPUT)
	@$(CXX) -o build/release/$(OUTPUT) $(RELEASE_OBJS) $(LDFLAGS)

build/release/%.o : %.cpp
	@echo 'compiling ' $<
	@$(CXX) -c $(CXXFLAGS) $< -o $@
	@$(CXX) -MM $(CXXFLAGS) $< -o build/deps/$*.d
	@mv -f build/deps/$*.d build/deps/$*.d.tmp
	@sed -e 's|.*:|build/release/$*.o:|' < build/deps/$*.d.tmp \
	  > build/deps/$*.d
	@sed -e 's/.*://' -e 's/\\$$//' < build/deps/$*.d.tmp | fmt -1 | \
	  sed -e 's/^ *//' -e 's/$$/:/' >> build/deps/$*.d
	@rm -f build/deps/$*.d.tmp

.PHONY: clean
clean:
	@echo 'removing build directory'
	@rm -rf build
