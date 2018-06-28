##################################################################
#      makefile        Copyright(C) 2003-2018 Max Wu
#
# build rule of loader from MS-DOS
#
##################################################################

CC      = $(TOOL_HEAD)gcc  -m32
LD      = $(TOOL_HEAD)ld -m elf_i386
AS      = $(TOOL_HEAD)as --32
CPP     = $(TOOL_HEAD)cpp
RM      = rm

# include  makefile.cfg

LD_FLAGS    = -Ttext 0x100 --oformat binary -e lddos_start
CPP_FLAGS   = -nostdinc -I. $(CPPENV) -DA20_TEST
# CPP_FLAGS   = -nostdinc -I. $(CPPENV)

SRCS = lddos.s lib16.s
ASMS = $(addsuffix .ss, $(basename $(SRCS)))

COMS    = lddos.com
OBJS    = $(addsuffix .o, $(basename $(COMS)))

DEPS    = lib16s.h makefile

%.ss : %.s $(DEPS) $(SRCS)
	$(CPP) $(CPP_FLAGS) -o $@ $<

all: $(COMS)

$(COMS): $(OBJS)
	$(LD) $(LD_FLAGS) -o $@ $<

$(OBJS): $(ASMS)
	$(AS) $? -o $@

clean:
	$(RM) -f *.o *.ss $(OBJS) $(COMS)