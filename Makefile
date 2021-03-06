TOOLS_DIR := tools
ARM_SDK_DIR := $(TOOLS_DIR)/gcc-arm-none-eabi-5_2-2015q4
ARM_SDK_PREFIX := $(ARM_SDK_DIR)/bin/arm-none-eabi-

ifeq ("$(wildcard $(ARM_SDK_PREFIX)gcc)","")
    $(error **ERROR** ARM-SDK is not in $(ARM_SDK_DIR))
endif

INC :=
INC += inc
INC += libs/STM32F4xx_StdPeriph_Driver/inc
INC += libs/fatfs

BUILD_DIR := build

STDPERIPH_SRC :=
STDPERIPH_SRC += stm32f4xx_adc.c
STDPERIPH_SRC += stm32f4xx_dma.c
STDPERIPH_SRC += stm32f4xx_flash.c
STDPERIPH_SRC += stm32f4xx_gpio.c
STDPERIPH_SRC += stm32f4xx_iwdg.c
STDPERIPH_SRC += stm32f4xx_pwr.c
STDPERIPH_SRC += stm32f4xx_rcc.c
STDPERIPH_SRC += stm32f4xx_sdio.c
STDPERIPH_SRC += stm32f4xx_spi.c
STDPERIPH_SRC += stm32f4xx_tim.c
STDPERIPH_SRC += stm32f4xx_usart.c

STDPERIPH_SRC := $(patsubst %,libs/STM32F4xx_StdPeriph_Driver/src/%,$(STDPERIPH_SRC))

FATFS_SRC := $(wildcard libs/fatfs/*.c)
SHARED_SRC := $(wildcard shared/*.c)
OPENLAGER_SRC := $(wildcard src/*.c)
OPENLAGER_LOADER_SRC := $(wildcard loader/*.c)

SRC := $(STDPERIPH_SRC) $(FATFS_SRC) $(SHARED_SRC) $(OPENLAGER_SRC)
OBJ := $(patsubst %.c,build/%.o,$(SRC))

BOOTLOADER_SRC := $(STDPERIPH_SRC) $(FATFS_SRC) $(SHARED_SRC) $(OPENLAGER_LOADER_SRC)
BOOTLOADER_OBJ := $(patsubst %.c,build/%.o,$(BOOTLOADER_SRC))

CC := $(ARM_SDK_PREFIX)gcc

CPPFLAGS += $(patsubst %,-I%,$(INC))
CPPFLAGS += -DSTM32F411xE -DUSE_STDPERIPH_DRIVER

CFLAGS :=
CFLAGS += -mcpu=cortex-m4 -mthumb -fdata-sections -ffunction-sections
CFLAGS += -fomit-frame-pointer -Wall

LDFLAGS := -nostartfiles -Wl,-static -lc -lgcc -Wl,--warn-common
LDFLAGS += -Wl,--fatal-warnings -Wl,--gc-sections
LDFLAGS += -Tshared/stm32f411.ld

all: build/openlager build/openloader

build/openlager: $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $@ -Tsrc/memory.ld $(LDFLAGS) 

build/openloader: $(BOOTLOADER_OBJ)
	$(CC) $(CFLAGS) $(BOOTLOADER_OBJ) -o $@ -Tloader/memory.ld $(LDFLAGS) 

clean:
	rm -rf $(BUILD_DIR)

build/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $< -o $@
