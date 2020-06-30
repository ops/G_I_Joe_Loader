#
# Makefile for G.I. Joe loader test
#
# March 2020 ops
#

PROGRAM_BASE = test
PROGRAM_SUFFIX = prg
PROGRAM := $(PROGRAM_BASE).$(PROGRAM_SUFFIX)

LIBRARY_BASE = gijoe-loader
LIBRARY_SUFFIX = lib
LIBRARY := $(LIBRARY_BASE).$(LIBRARY_SUFFIX)

CONFIG = $(PROGRAM_BASE).cfg

IMAGE := gij-loader.d64

AS := ca65
LD := ld65

target ?= vic20

ifeq ($(target),vic20)
  START_ADDR ?= 4097
endif
ifeq ($(target),c16)
  START_ADDR ?= 4097
endif
ifeq ($(target),c64)
  START_ADDR ?= 2049
endif
ifeq ($(target),c128)
  START_ADDR ?= 7169
endif

# Additional assembler flags and options.
ASFLAGS += -t $(target) -g

# Additional linker flags and options.
LDFLAGS = -C $(CONFIG) -L..

# Set OBJECTS
OBJECTS := test.o

.PHONY: image clean

$(PROGRAM): $(CONFIG) $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ -S $(START_ADDR) $(OBJECTS) $(LIBRARY)

image: $(PROGRAM)
	c1541 -format gijoe-loader,os d64 $(IMAGE)
	c1541 $(IMAGE) -write $(PROGRAM)
	c1541 $(IMAGE) -write 04
	c1541 $(IMAGE) -write 0c
	c1541 $(IMAGE) -write 1e

clean:
	$(RM) $(OBJECTS)
	$(RM) $(PROGRAM)
	$(RM) $(IMAGE)
	$(RM) *~
