#
# Makefile for G.I. Joe loader
#
# March 2020 ops
#

LIBRARY_BASE = gijoe-loader
LIBRARY_SUFFIX = lib
LIBRARY := $(LIBRARY_BASE).$(LIBRARY_SUFFIX)

AR := ar65
AS := ca65

target ?= vic20

# Archiver flags and options.
ARFLAGS = r

# Additional assembler flags and options.
ASFLAGS += -t $(target) -g

# Set OBJECTS
LIB_OBJECTS := host.o drive.o init.o

.PHONY: clean

$(LIBRARY): $(LIB_OBJECTS)
	$(AR) $(ARFLAGS) $@ $(LIB_OBJECTS)

clean:
	$(RM) $(LIB_OBJECTS)
	$(RM) $(LIBRARY)
	$(RM) *~
