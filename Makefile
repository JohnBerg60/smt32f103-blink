# Makefile for the STM32F103 Bootloader
#
# John Berg @ netbasenext.nl
#

PROJECT = firmware

# Project Structure
SRCDIR = src
BINDIR = bin
OBJDIR = obj
INCDIR = include
COMDIR = common

# Project target
CPU = cortex-m3

# Sources
SRC = $(wildcard $(SRCDIR)/*.c) # $(wildcard $(COMDIR)/src/*.c)
ASM = $(wildcard $(SRCDIR)/*.s) # $(wildcard $(COMDIR)/src/*.s)

#defines
DEFINE = -DSTM32F103xB

# Include directories
INCLUDE  = -I$(INCDIR) -I$(COMDIR)/include -I$(COMDIR)/cmsis

# Linker
LSCRIPT = STM32F103xB.ld

# C/C++ Flags
CCOMMONFLAGS = -Wall -Os -fno-common -mthumb -mcpu=$(CPU) --specs=nosys.specs --specs=nano.specs -g

# C Flags
GCFLAGS  = -std=c11  -Wa,-ahlms=$(addprefix $(OBJDIR)/,$(notdir $(<:.c=.lst)))
GCFLAGS += $(CCOMMONFLAGS) $(INCLUDE) $(DEFINE) 
LDFLAGS += -T$(LSCRIPT) -mthumb -mcpu=$(CPU) --specs=nosys.specs --specs=nano.specs -Wl,-Map,$(BINDIR)/$(PROJECT).map -Wl,--gc-sections
ASFLAGS += -mcpu=$(CPU)

# Tools
CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
AR = arm-none-eabi-ar
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size --format=SysV -x
OBJDUMP = arm-none-eabi-objdump

RM = rm -rf

## Build process

OBJ := $(addprefix $(OBJDIR)/,$(notdir $(SRC:.c=.o)))
OBJ += $(addprefix $(OBJDIR)/,$(notdir $(ASM:.s=.o)))


all:: $(BINDIR)/$(PROJECT).bin $(BINDIR)/$(PROJECT).hex

Build: $(BINDIR)/$(PROJECT).bin

macros:
	$(CC) $(GCFLAGS) -dM -E - < /dev/null

cleanBuild: clean

clean:
	$(RM) $(BINDIR)
	$(RM) $(OBJDIR)

size:
	$(SIZE) $(BINDIR)/$(PROJECT).elf

# Compilation

$(BINDIR)/$(PROJECT).hex: $(BINDIR)/$(PROJECT).elf
	$(OBJCOPY) -O ihex $(BINDIR)/$(PROJECT).elf $(BINDIR)/$(PROJECT).hex

$(BINDIR)/$(PROJECT).bin: $(BINDIR)/$(PROJECT).elf
	$(OBJCOPY) -O binary $(BINDIR)/$(PROJECT).elf $(BINDIR)/$(PROJECT).bin

$(BINDIR)/$(PROJECT).elf: $(OBJ) $(LSCRIPT)
	@mkdir -p $(dir $@)
	$(CC) $(OBJ) $(LDFLAGS) -o $(BINDIR)/$(PROJECT).elf
	$(OBJDUMP) -D $(BINDIR)/$(PROJECT).elf > $(BINDIR)/$(PROJECT).lst
	$(SIZE) $(BINDIR)/$(PROJECT).elf

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(GCFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<


$(OBJDIR)/%.o: $(COMDIR)/src/%.c
	@mkdir -p $(dir $@)
	$(CC) $(GCFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(COMDIR)/src/%.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

$(OBJ): Makefile

