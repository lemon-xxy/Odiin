PROJECT				:= odiin
TARGETS				:= nrf52840_xxaa
OUTPUT_DIRECTORY 	:= _build
DEBUG				?= 0
VENDOR_ROOT ?= vendor
SOURCE_DIR := src

# OS detection
# Detect operating system in Makefile.
# Author: He Tao
# Date: 2015-05-30
# Src: https://gist.github.com/sighingnow/deee806603ec9274fd47
OSFLAG			:=
ifeq ($(OS),Windows_NT)
	OSFLAG :=WINDOWS
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		OSFLAG :=LINUX
	endif
	ifeq ($(UNAME_S),Darwin)
		OSFLAG :=OSX
	endif
endif

# Amount of RAM to dedicate to the heap.
# lvgl suggets at least 16K, and examples
# for nRF52 have shipped with 8K.
HEAP_SIZE_BYTES := 32768
STACK_SIZE_BYTES := 32768

# File names
GIT_COMMIT_HASH != git rev-parse HEAD | head -c8
GIT_VERSION_RAW != git describe --dirty --always --tags
GIT_VERSION = $(subst -,+,$(GIT_VERSION_RAW))
GIT_COMMIT_COUNT != git rev-list HEAD --count
FILENAME_OUTPUT_MERGED_HEX := $(PROJECT)-$(GIT_VERSION).hex
FILENAME_OUTPUT_UF2 := $(PROJECT)-$(GIT_VERSION).uf2

# Bootloader Settings
BOOTLOADER_DIR := bootloader
BOOTLOADER_BOARD := odiin
BOOTLOADER_OUTFILE := uf2_bootloader.hex
BOOTLOADER_BOOT_SETTING_ADDR = 0xFF000
BOOTLOADER_BOOT_APP_VALID_VALUE = 0x00000001

$(OUTPUT_DIRECTORY)/nrf52840_xxaa.out: \
  LINKER_SCRIPT  := $(SOURCE_DIR)/link/nrf52.ld

########################################################
## Application Files
########################################################

SRC_FILES += \
  $(wildcard $(SOURCE_DIR)/*.c*) \
  $(wildcard $(SOURCE_DIR)/app/*.c*) \
  $(wildcard $(SOURCE_DIR)/app/fsm/*.c*) \
  $(wildcard $(SOURCE_DIR)/crypto/*.c*) \
  $(wildcard $(SOURCE_DIR)/display/*.c*) \
  $(wildcard $(SOURCE_DIR)/display/fonts/*.c*) \
  $(wildcard $(SOURCE_DIR)/display/images/*.c*) \
  $(wildcard $(SOURCE_DIR)/display/led/*.c*) \
  $(wildcard $(SOURCE_DIR)/display/led/effect/*.c*) \
  $(wildcard $(SOURCE_DIR)/display/screen_ui/*.c*) \
  $(wildcard $(SOURCE_DIR)/files/*.c*) \
  $(wildcard $(SOURCE_DIR)/global/*.c*) \
  $(wildcard $(SOURCE_DIR)/input/*.c*) \
  $(wildcard $(SOURCE_DIR)/nfc/*.c*) \
  $(wildcard $(SOURCE_DIR)/nfc/nfrx_extensions/*.c*) \
  $(wildcard $(SOURCE_DIR)/nfc/nxp/mifare_ultralight_c/*.c*) \
  $(wildcard $(SOURCE_DIR)/nfc/nxp/ntag21x/*.c*) \
  $(wildcard $(SOURCE_DIR)/nfc/type_2_tag/*.c*) \
  $(wildcard $(SOURCE_DIR)/platform/*.c*) \
  $(wildcard $(SOURCE_DIR)/tests/*.c*) \
  $(wildcard $(SOURCE_DIR)/timer/*.c*) \
  $(wildcard $(SOURCE_DIR)/usb/*.c*) \

INC_FOLDERS += \
  $(SOURCE_DIR) \
  $(SOURCE_DIR)/config \

########################################################
## Vendor: nRF5 SDK & Board SDK Files
########################################################

SDK_ROOT := $(VENDOR_ROOT)/nRF5_SDK
BOARD_SDK_ROOT ?= $(VENDOR_ROOT)/board

SRC_FILES += \
  $(SDK_ROOT)/components/boards/boards.c \
  $(SDK_ROOT)/components/drivers_nrf/nrf_soc_nosd/nrf_nvic.c \
  $(SDK_ROOT)/components/drivers_nrf/nrf_soc_nosd/nrf_soc.c \
  $(SDK_ROOT)/components/libraries/atomic/nrf_atomic.c \
  $(SDK_ROOT)/components/libraries/atomic/nrf_atomic.c \
  $(SDK_ROOT)/components/libraries/atomic_fifo/nrf_atfifo.c \
  $(SDK_ROOT)/components/libraries/balloc/nrf_balloc.c \
  $(SDK_ROOT)/components/libraries/block_dev/empty/nrf_block_dev_empty.c \
  $(SDK_ROOT)/components/libraries/block_dev/qspi/nrf_block_dev_qspi.c \
  $(SDK_ROOT)/components/libraries/block_dev/qspi/nrf_serial_flash_params.c \
  $(SDK_ROOT)/components/libraries/block_dev/ram/nrf_block_dev_ram.c \
  $(SDK_ROOT)/components/libraries/block_dev/sdc/nrf_block_dev_sdc.c \
  $(SDK_ROOT)/components/libraries/bsp/bsp.c \
  $(SDK_ROOT)/components/libraries/button/app_button.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_aes.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_aes_aead.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_chacha_poly_aead.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_ecc.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_ecdh.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_ecdsa.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_eddsa.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_hash.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_hmac.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_init.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_mutex.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_rng.c \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310/cc310_backend_shared.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_aead.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_aes.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_aes_shared.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_ecc.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_ecdh.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_ecdsa.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_eddsa.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_error.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_hash.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_hkdf.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_hmac.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_init.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_rng.c \
  $(SDK_ROOT)/components/libraries/crypto/nrf_crypto_shared.c \
  $(SDK_ROOT)/components/libraries/experimental_section_vars/nrf_section_iter.c \
  $(SDK_ROOT)/components/libraries/fifo/app_fifo.c \
  $(SDK_ROOT)/components/libraries/gfx/nrf_gfx.c \
  $(SDK_ROOT)/components/libraries/hardfault/hardfault_implementation.c \
  $(SDK_ROOT)/components/libraries/hardfault/nrf52/handler/hardfault_handler_gcc.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_backend_rtt.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_backend_serial.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_backend_uart.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_default_backends.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_frontend.c \
  $(SDK_ROOT)/components/libraries/log/src/nrf_log_str_formatter.c \
  $(SDK_ROOT)/components/libraries/low_power_pwm/low_power_pwm.c \
  $(SDK_ROOT)/components/libraries/memobj/nrf_memobj.c \
  $(SDK_ROOT)/components/libraries/pwr_mgmt/nrf_pwr_mgmt.c \
  $(SDK_ROOT)/components/libraries/ringbuf/nrf_ringbuf.c \
  $(SDK_ROOT)/components/libraries/scheduler/app_scheduler.c \
  $(SDK_ROOT)/components/libraries/sdcard/app_sdcard.c \
  $(SDK_ROOT)/components/libraries/sortlist/nrf_sortlist.c \
  $(SDK_ROOT)/components/libraries/strerror/nrf_strerror.c \
  $(SDK_ROOT)/components/libraries/timer/app_timer.c \
  $(SDK_ROOT)/components/libraries/uart/app_uart_fifo.c \
  $(SDK_ROOT)/components/libraries/usbd/app_usbd.c \
  $(SDK_ROOT)/components/libraries/usbd/app_usbd_core.c \
  $(SDK_ROOT)/components/libraries/usbd/app_usbd_serial_num.c \
  $(SDK_ROOT)/components/libraries/usbd/app_usbd_string_desc.c \
  $(SDK_ROOT)/components/libraries/usbd/class/msc/app_usbd_msc.c \
  $(SDK_ROOT)/components/libraries/util/app_error.c \
  $(SDK_ROOT)/components/libraries/util/app_error_weak.c \
  $(SDK_ROOT)/components/libraries/util/app_util_platform.c \
  $(SDK_ROOT)/components/libraries/util/nrf_assert.c \
  $(SDK_ROOT)/components/nfc/ndef/generic/message/nfc_ndef_msg.c \
  $(SDK_ROOT)/components/nfc/ndef/generic/record/nfc_ndef_record.c \
  $(SDK_ROOT)/components/nfc/ndef/uri/nfc_uri_msg.c \
  $(SDK_ROOT)/components/nfc/ndef/uri/nfc_uri_rec.c \
  $(SDK_ROOT)/components/nfc/platform/nfc_platform.c \
  $(SDK_ROOT)/external/fprintf/nrf_fprintf.c \
  $(SDK_ROOT)/external/fprintf/nrf_fprintf_format.c \
  $(SDK_ROOT)/external/utf_converter/utf.c \
  $(SDK_ROOT)/integration/nrfx/legacy/nrf_drv_clock.c \
  $(SDK_ROOT)/integration/nrfx/legacy/nrf_drv_power.c \
  $(SDK_ROOT)/integration/nrfx/legacy/nrf_drv_spi.c \
  $(SDK_ROOT)/integration/nrfx/legacy/nrf_drv_uart.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_clock.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_gpiote.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_nfct.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_power.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_qspi.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_rtc.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_saadc.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_spi.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_spim.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_systick.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_timer.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_uart.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_uarte.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_usbd.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/nrfx_wdt.c \
  $(SDK_ROOT)/modules/nrfx/drivers/src/prs/nrfx_prs.c \
  $(SDK_ROOT)/modules/nrfx/mdk/gcc_startup_nrf52840.S \
  $(SDK_ROOT)/modules/nrfx/mdk/system_nrf52840.c \
  $(SDK_ROOT)/modules/nrfx/soc/nrfx_atomic.c \
  $(SDK_ROOT)/modules/nrfx/soc/nrfx_atomic.c \

INC_FOLDERS += \
  $(BOARD_SDK_ROOT)/config \
  $(SDK_ROOT)/components/boards \
  $(SDK_ROOT)/components/drivers_nrf/nrf_soc_nosd \
  $(SDK_ROOT)/components/libraries/atomic \
  $(SDK_ROOT)/components/libraries/atomic_fifo \
  $(SDK_ROOT)/components/libraries/balloc \
  $(SDK_ROOT)/components/libraries/block_dev \
  $(SDK_ROOT)/components/libraries/block_dev/empty \
  $(SDK_ROOT)/components/libraries/block_dev/qspi \
  $(SDK_ROOT)/components/libraries/block_dev/ram \
  $(SDK_ROOT)/components/libraries/block_dev/sdc \
  $(SDK_ROOT)/components/libraries/bsp \
  $(SDK_ROOT)/components/libraries/button \
  $(SDK_ROOT)/components/libraries/crypto \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310 \
  $(SDK_ROOT)/components/libraries/crypto/backend/cc310_bl \
  $(SDK_ROOT)/components/libraries/crypto/backend/cifra \
  $(SDK_ROOT)/components/libraries/crypto/backend/mbedtls \
  $(SDK_ROOT)/components/libraries/crypto/backend/micro_ecc \
  $(SDK_ROOT)/components/libraries/crypto/backend/nrf_hw \
  $(SDK_ROOT)/components/libraries/crypto/backend/nrf_sw \
  $(SDK_ROOT)/components/libraries/crypto/backend/oberon \
  $(SDK_ROOT)/components/libraries/crypto/backend/optiga \
  $(SDK_ROOT)/components/libraries/delay \
  $(SDK_ROOT)/components/libraries/experimental_section_vars \
  $(SDK_ROOT)/components/libraries/fifo \
  $(SDK_ROOT)/components/libraries/fifo \
  $(SDK_ROOT)/components/libraries/gfx \
  $(SDK_ROOT)/components/libraries/hardfault \
  $(SDK_ROOT)/components/libraries/hardfault/nrf52 \
  $(SDK_ROOT)/components/libraries/log \
  $(SDK_ROOT)/components/libraries/log/src \
  $(SDK_ROOT)/components/libraries/low_power_pwm \
  $(SDK_ROOT)/components/libraries/memobj \
  $(SDK_ROOT)/components/libraries/mutex \
  $(SDK_ROOT)/components/libraries/pwr_mgmt \
  $(SDK_ROOT)/components/libraries/ringbuf \
  $(SDK_ROOT)/components/libraries/sdcard \
  $(SDK_ROOT)/components/libraries/sortlist \
  $(SDK_ROOT)/components/libraries/stack_info \
  $(SDK_ROOT)/components/libraries/strerror \
  $(SDK_ROOT)/components/libraries/timer \
  $(SDK_ROOT)/components/libraries/uart \
  $(SDK_ROOT)/components/libraries/usbd \
  $(SDK_ROOT)/components/libraries/usbd/class/msc \
  $(SDK_ROOT)/components/libraries/util \
  $(SDK_ROOT)/components/nfc/ndef/generic/message \
  $(SDK_ROOT)/components/nfc/ndef/generic/record \
  $(SDK_ROOT)/components/nfc/ndef/uri \
  $(SDK_ROOT)/components/nfc/platform \
  $(SDK_ROOT)/components/nfc/t2t_lib \
  $(SDK_ROOT)/components/toolchain/cmsis/include \
  $(SDK_ROOT)/external/fprintf \
  $(SDK_ROOT)/external/nrf_cc310/include \
  $(SDK_ROOT)/external/protothreads \
  $(SDK_ROOT)/external/protothreads/pt-1.4 \
  $(SDK_ROOT)/external/thedotfactory_fonts \
  $(SDK_ROOT)/external/utf_converter \
  $(SDK_ROOT)/integration/nrfx \
  $(SDK_ROOT)/integration/nrfx/legacy \
  $(SDK_ROOT)/modules/nrfx \
  $(SDK_ROOT)/modules/nrfx/drivers/include \
  $(SDK_ROOT)/modules/nrfx/hal \
  $(SDK_ROOT)/modules/nrfx/mdk \

########################################################
## Vendor: amiitool
########################################################

AMIITOOL_DIR := $(VENDOR_ROOT)/amiitool
AMIITOOL_SRC_DIR := $(AMIITOOL_DIR)/src

# No source files, header only library.

INC_FOLDERS += \
  $(AMIITOOL_DIR)/include \

SRC_FILES += \
  $(wildcard $(AMIITOOL_SRC_DIR)/*.c) \

########################################################
## Vendor: Cie1931
########################################################

CIE1931_DIR := $(VENDOR_ROOT)/Cie1931

# No source files, header only library.

INC_FOLDERS += \
  $(CIE1931_DIR) \

########################################################
## Vendor: cwalk
########################################################

CWALK_DIR := $(VENDOR_ROOT)/cwalk
CWALK_SRC_DIR := $(CWALK_DIR)/src

SRC_FILES += \
  $(CWALK_SRC_DIR)/cwalk.c \

INC_FOLDERS += \
  $(CWALK_DIR)/include \

########################################################
## Vendor: fatfs
########################################################

FATFS_DIR := $(VENDOR_ROOT)/fatfs

SRC_FILES += \
  $(wildcard $(FATFS_DIR)/port/*.c) \
  $(wildcard $(FATFS_DIR)/source/ff.c) \
  $(wildcard $(FATFS_DIR)/source/ffunicode.c) \

INC_FOLDERS += \
  $(FATFS_DIR)/port \
  $(FATFS_DIR)/source \

########################################################
## Vendor: IlI9341 Display Driver <not external>
########################################################

SRC_FILES += \
  $(wildcard $(VENDOR_ROOT)/display/*.c) \

INC_FOLDERS += \
  $(VENDOR_ROOT)/display \

########################################################
## Vendor: littlefs
########################################################

LITTLEFS_DIR := $(VENDOR_ROOT)/littlefs

SRC_FILES += \
  $(wildcard $(LITTLEFS_DIR)/*.c) \
  $(wildcard $(LITTLEFS_DIR)/bd/*.c) \

INC_FOLDERS += \
  $(LITTLEFS_DIR) \

########################################################
## Vendor: lvgl
########################################################

LVGL_BASE_DIR := $(VENDOR_ROOT)/lvgl
LVGL_DIR := $(LVGL_BASE_DIR)/lvgl
LVGL_SRC_DIR := $(LVGL_DIR)/src

SRC_FILES += \
  $(wildcard $(LVGL_SRC_DIR)/*.c) \
  $(wildcard $(LVGL_SRC_DIR)/lv_core/*.c) \
  $(wildcard $(LVGL_SRC_DIR)/lv_draw/*.c) \
  $(wildcard $(LVGL_SRC_DIR)/lv_font/*.c) \
  $(wildcard $(LVGL_SRC_DIR)/lv_gpu/*.c) \
  $(wildcard $(LVGL_SRC_DIR)/lv_hal/*.c) \
  $(wildcard $(LVGL_SRC_DIR)/lv_misc/*.c) \
  $(wildcard $(LVGL_SRC_DIR)/lv_themes/*.c) \
  $(wildcard $(LVGL_SRC_DIR)/lv_widgets/*.c) \

INC_FOLDERS += \
  $(LVGL_BASE_DIR) \
  $(LVGL_DIR) \

########################################################
## Vendor: TinyFSM
########################################################

TFSM_DIR := $(VENDOR_ROOT)/TinyFSM/include

# No source files, header only library.

INC_FOLDERS += \
  $(TFSM_DIR) \

########################################################
## Library Files
########################################################

# Libraries common to all targets
LIB_FILES += \
  $(SDK_ROOT)/external/nrf_cc310/lib/cortex-m4/hard-float/libnrf_cc310_0.9.13.a \


########################################################
## Compiler Flags
########################################################

# Optimization flags
OPT_FLAGS = -O3

# Flags dependant on build configuration.
ifeq ($(DEBUG),1)
  OPT_FLAGS = -O0
  # Debug flags
  APP_FLAGS = -ggdb3 # -g3 -- use for non-gdb debugging.
  APP_DEFINES = -DDEBUG -DDEBUG_NRF
  # Ask linker to produce cross references to investigate later.
  APP_LDFLAGS = -Wl,--cref
else
  APP_FLAGS = -Wduplicated-cond
  APP_DEFINES = -DRELEASE
  # strip symbol table and reloc information
  APP_LDFLAGS = -Wl,-s -Wl,-z,defs
  # Add full link time optimization as a last resort.
  # See: https://interrupt.memfault.com/blog/best-and-worst-gcc-clang-compiler-flags#-flto
  #OPT_FLAGS += -flto
endif

# Board Flags for dev platform,
# Defaulting to pitayago if we don't have one set.
DEV_PLATFORM ?= pitayago

ifeq ($(DEV_PLATFORM),pitayago)
  DEV_PLATFORM_FLAGS = -DPITAYA_GO
else ifeq ($(BOARD_PLATFORM),m2)
  DEV_PLATFORM_FLAGS = -DNRF52840_M2
else
  $(error Dev Platform $(DEV_PLATFORM) is unknown)
endif

# C flags common to all targets
CFLAGS += $(APP_FLAGS)
CFLAGS += $(OPT_FLAGS)
CFLAGS += $(APP_DEFINES)
CFLAGS += -DAPP_TIMER_V2
CFLAGS += -DAPP_TIMER_V2_RTC1_ENABLED
CFLAGS += -DBOARD_CUSTOM
CFLAGS += -DCONFIG_GPIO_AS_PINRESET
CFLAGS += $(DEV_PLATFORM_FLAGS)
CFLAGS += -DFLOAT_ABI_HARD
CFLAGS += -DGIT_HASH=$(GIT_VERSION)
CFLAGS += -DGIT_HASH_INT=0x$(GIT_COMMIT_HASH)
CFLAGS += -DGIT_COMMIT_COUNT=$(GIT_COMMIT_COUNT)
CFLAGS += -DNRF52840_XXAA
# Enable lots of warnings to catch common mistakes.
CFLAGS += -Wall -Werror -Wshadow
# Warnings I can't use because of nRF5/other libs:
# -Wundef, -Wdouble-promotion
# Prevent common global variable names
CFLAGS += -fno-common
# Emit stack usage info
CFLAGS += -fstack-usage
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mthumb -mabi=aapcs
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
# keep every function in a separate section, this allows linker to discard unused ones
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin -fshort-enums

# C++ flags common to all targets
CXXFLAGS += $(OPT_FLAGS)

# C++ specific warning enables to help control dialect
CXXFLAGS += -Wclass-memaccess
CXXFLAGS += -Wstrict-null-sentinel
CXXFLAGS += -Wzero-as-null-pointer-constant
CXXFLAGS += -Wsuggest-override

# We are using C++, but no RTTI is needed (and doesn't work anyways!)
CXXFLAGS += -fno-rtti -std=c++17

# Assembler flags common to all targets
ASMFLAGS += $(APP_FLAGS)
ASMFLAGS += -DAPP_TIMER_V2
ASMFLAGS += -DAPP_TIMER_V2_RTC1_ENABLED
ASMFLAGS += -DBOARD_CUSTOM
ASMFLAGS += -DCONFIG_GPIO_AS_PINRESET
ASMFLAGS += $(APP_DEFINES)
ASMFLAGS += $(DEV_PLATFORM_FLAGS)
ASMFLAGS += -DFLOAT_ABI_HARD
ASMFLAGS += -DGIT_HASH=$(GIT_VERSION)
ASMFLAGS += -DGIT_HASH_INT=0x$(GIT_COMMIT_HASH)
ASMFLAGS += -DGIT_COMMIT_COUNT=$(GIT_COMMIT_COUNT)
ASMFLAGS += -DNRF52840_XXAA
ASMFLAGS += -mcpu=cortex-m4
ASMFLAGS += -mthumb -mabi=aapcs
ASMFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16

# Linker flags
LDFLAGS += $(OPT_FLAGS)
LDFLAGS += -mthumb -mabi=aapcs -L$(SDK_ROOT)/modules/nrfx/mdk -T$(LINKER_SCRIPT)
LDFLAGS += -mcpu=cortex-m4
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
# let linker dump unused sections
LDFLAGS += -Wl,--gc-sections
# use newlib in nano version
LDFLAGS += --specs=nano.specs
LDFLAGS += $(APP_LDFLAGS)

nrf52840_xxaa: CFLAGS += -D__HEAP_SIZE=$(HEAP_SIZE_BYTES)
nrf52840_xxaa: CFLAGS += -D__STACK_SIZE=$(STACK_SIZE_BYTES)
nrf52840_xxaa: ASMFLAGS += -D__HEAP_SIZE=$(HEAP_SIZE_BYTES)
nrf52840_xxaa: ASMFLAGS += -D__STACK_SIZE=$(STACK_SIZE_BYTES)

# Add standard libraries at the very end of the linker input, after all objects
# that may need symbols provided by these libraries.
LIB_FILES += -lc -lnosys -lm -lstdc++

# Check to see if the bootloader already is built and is ready to be used
# Assume it's not if the bootloader is explicitly asked to be built.
ifneq ($(MAKECMDGOALS),bootloader)
  BOOTLOADER_EXISTS := $(or $(and $(wildcard $(OUTPUT_DIRECTORY)\$(BOOTLOADER_OUTFILE)),1),0)
else
  BOOTLOADER_EXISTS := 0
endif

.PHONY: default

# Default target - first one defined
default: nrf52840_xxaa

include BuildSettings.mk

# TEMPLATE_PATH is used in the common makefile.
TEMPLATE_PATH := $(SDK_ROOT)/components/toolchain/gcc
include $(TEMPLATE_PATH)/Makefile.common

$(foreach target, $(TARGETS), $(call define_target, $(target)))

.PHONY: bootloader clean_bootloader flash flash_mbr flash_bootloader merge flash_all erase release

# Build the bootloader subproject, and copy it to the output.
# If someone wants to improve the copy/rename to work on multiple platforms, be my guest.
bootloader:
ifeq ($(BOOTLOADER_EXISTS),0)
	@echo Building UF2 bootloader...
	$(MAKE) -C $(BOOTLOADER_DIR) BOARD=$(BOOTLOADER_BOARD) all
ifeq ($(OSFLAG),WINDOWS)
	@xcopy $(BOOTLOADER_DIR)\_build\build-$(BOOTLOADER_BOARD)\$(BOOTLOADER_BOARD)_bootloader*nosd.hex $(OUTPUT_DIRECTORY)\ /R /Y
	@move /y $(OUTPUT_DIRECTORY)\$(BOOTLOADER_BOARD)_bootloader-*nosd.hex $(OUTPUT_DIRECTORY)\$(BOOTLOADER_OUTFILE)
else ifeq ($(OSFLAG),OSX)
  # OSX
	@mkdir -p $(OUTPUT_DIRECTORY)/
	@cp -Rf $(BOOTLOADER_DIR)/_build/build-$(BOOTLOADER_BOARD)/$(BOOTLOADER_BOARD)_bootloader*nosd.hex $(OUTPUT_DIRECTORY)/
	@mv -f $(OUTPUT_DIRECTORY)/$(BOOTLOADER_BOARD)_bootloader-*nosd.hex $(OUTPUT_DIRECTORY)/$(BOOTLOADER_OUTFILE)
else
  # Linux
	@mkdir -p $(OUTPUT_DIRECTORY)/
	@cp -Rf $(BOOTLOADER_DIR)/_build/build-$(BOOTLOADER_BOARD)/$(BOOTLOADER_BOARD)_bootloader*nosd.hex $(OUTPUT_DIRECTORY)/
	@mv -f $(OUTPUT_DIRECTORY)/$(BOOTLOADER_BOARD)_bootloader-*nosd.hex $(OUTPUT_DIRECTORY)/$(BOOTLOADER_OUTFILE)
endif
endif

# Clean bootloader subproject
clean_bootloader:
	@echo Cleaning UF2 bootloader...
	$(MAKE) -C $(BOOTLOADER_DIR) BOARD=$(BOOTLOADER_BOARD) clean

# Flash the program, no bootloader.
flash: default
	@echo Flashing: $(OUTPUT_DIRECTORY)/nrf52840_xxaa.hex
	pyocd flash -t nrf52840 $(OUTPUT_DIRECTORY)/nrf52840_xxaa.hex

# Flash MBR
flash_mbr:
	@echo Flashing: mbr_nrf52_2.4.1_mbr.hex
	pyocd flash -t nrf52840 $(SDK_ROOT)/components/softdevice/mbr/hex/mbr_nrf52_2.4.1_mbr.hex

# Flash the UF2 bootloader, which has been merged with the MBR already.
flash_bootloader: bootloader
	@echo Flashing: UF2 bootloader...
	pyocd flash -t nrf52840 $(OUTPUT_DIRECTORY)/$(BOOTLOADER_OUTFILE)

# Merge the bootloader and the application
merge: bootloader default
	@echo Merging: $(OUTPUT_DIRECTORY)/$(FILENAME_OUTPUT_MERGED_HEX) from application and UF2 bootloader.
	mergehex -m $(OUTPUT_DIRECTORY)/$(BOOTLOADER_OUTFILE) $(OUTPUT_DIRECTORY)/nrf52840_xxaa.hex -o $(OUTPUT_DIRECTORY)/$(FILENAME_OUTPUT_MERGED_HEX)

# Flash UF2 bootloader and application, and mark the application valid by
# Poking a '1' in app valid, and 0 for the crc.
# via: https://github.com/adafruit/circuitpython/blob/main/ports/nrf/Makefile#L286
flash_all: merge
	@echo Flashing: $(OUTPUT_DIRECTORY)/$(FILENAME_OUTPUT_MERGED_HEX)
	pyocd flash -t nrf52840 $(OUTPUT_DIRECTORY)/$(FILENAME_OUTPUT_MERGED_HEX)
	pyocd cmd -t nrf52840 --command write32 $(BOOTLOADER_BOOT_SETTING_ADDR) $(BOOTLOADER_BOOT_APP_VALID_VALUE) --command reset

# Erase the chip
erase:
	pyocd erase -t nrf52840 --chip

# Create the UF2 deployable.
release: merge
	@echo Creating UF2 format file from produced hex...
	@python $(BOARD_SDK_ROOT)/tools/uf2conv.py -c -f 0xada52840 -o $(OUTPUT_DIRECTORY)/$(FILENAME_OUTPUT_UF2) $(OUTPUT_DIRECTORY)/nrf52840_xxaa.hex
	@echo ""
	@echo Generated UF2 firmware file: $(OUTPUT_DIRECTORY)/$(FILENAME_OUTPUT_UF2)

SDK_CONFIG_FILE := $(SOURCE_DIR)/config/sdk_config.h
CMSIS_CONFIG_TOOL := $(SDK_ROOT)/external_tools/cmsisconfig/CMSIS_Configuration_Wizard.jar
sdk_config:
	java -jar $(CMSIS_CONFIG_TOOL) $(SDK_CONFIG_FILE)
