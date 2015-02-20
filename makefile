# Standalone makefile for building fastboot on Mac OS X
# 2013-12-04 Thomas Perl <thomas.perl@jolla.com>
#
# Based on: Android.mk from android_system_core/fastboot
# Copyright (C) 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Host-based compliation + include headers
CFLAGS += -DHOST -DHAVE_CONFIG_H \
    -D_FILE_OFFSET_BITS=64 \
    -Iandroid_system_core/mkbootimg \
    -Iandroid_system_core/libsparse/include \
    -Iandroid_system_core/include \
    -Iandroid_system_extras/ext4_utils \
    -Iandroid_system_extras/f2fs_utils \
    -Iandroid_external_libselinux/include \
    -Iandroid_external_pcre \
    -Iandroid_external_pcre/dist

# Fastboot
FASTBT := android_system_core/fastboot
LOCAL_SRC_FILES += $(FASTBT)/protocol.c \
    $(FASTBT)/engine.c \
    $(FASTBT)/bootimg.c \
    $(FASTBT)/fastboot.c \
    $(FASTBT)/fs.c \
    $(FASTBT)/usb_osx.c \
    $(FASTBT)/util.c \
    $(FASTBT)/util_osx.c

LOCAL_MODULE := fastboot

# libzipfile
LZIPF := android_system_core/libzipfile
LOCAL_SRC_FILES += $(LZIPF)/centraldir.c \
   $(LZIPF)/zipfile.c
LOCAL_LDLIBS += -lz

# libext4_utils_host
LEXT4 := android_system_extras/ext4_utils
LOCAL_SRC_FILES += $(LEXT4)/make_ext4fs.c \
    $(LEXT4)/ext4fixup.c \
    $(LEXT4)/ext4_utils.c \
    $(LEXT4)/allocate.c \
    $(LEXT4)/contents.c \
    $(LEXT4)/extent.c \
    $(LEXT4)/indirect.c \
    $(LEXT4)/uuid.c \
    $(LEXT4)/sha1.c \
    $(LEXT4)/wipe.c \
    $(LEXT4)/ext4_sb.c \
    $(LEXT4)/crc16.c

# libsparse_host
LSPH := android_system_core/libsparse
LOCAL_SRC_FILES += $(LSPH)/backed_block.c \
    $(LSPH)/output_file.c \
    $(LSPH)/sparse.c \
    $(LSPH)/sparse_crc32.c \
    $(LSPH)/sparse_err.c \
    $(LSPH)/sparse_read.c

# libselinux
LSEL := android_external_libselinux
LOCAL_SRC_FILES += $(LSEL)/src/callbacks.c \
    $(LSEL)/src/check_context.c \
    $(LSEL)/src/freecon.c \
    $(LSEL)/src/init.c \
    $(LSEL)/src/label.c \
    $(LSEL)/src/label_file.c \
    $(LSEL)/src/label_android_property.c

# libpcre
PCRE := android_external_pcre
LOCAL_SRC_FILES += $(PCRE)/pcre_chartables.c \
    $(PCRE)/dist/pcre_byte_order.c \
    $(PCRE)/dist/pcre_compile.c \
    $(PCRE)/dist/pcre_config.c \
    $(PCRE)/dist/pcre_dfa_exec.c \
    $(PCRE)/dist/pcre_exec.c \
    $(PCRE)/dist/pcre_fullinfo.c \
    $(PCRE)/dist/pcre_get.c \
    $(PCRE)/dist/pcre_globals.c \
    $(PCRE)/dist/pcre_jit_compile.c \
    $(PCRE)/dist/pcre_maketables.c \
    $(PCRE)/dist/pcre_newline.c \
    $(PCRE)/dist/pcre_ord2utf8.c \
    $(PCRE)/dist/pcre_refcount.c \
    $(PCRE)/dist/pcre_string_utils.c \
    $(PCRE)/dist/pcre_study.c \
    $(PCRE)/dist/pcre_tables.c \
    $(PCRE)/dist/pcre_ucd.c \
    $(PCRE)/dist/pcre_valid_utf8.c \
    $(PCRE)/dist/pcre_version.c \
    $(PCRE)/dist/pcre_xclass.c

HOST_OS := darwin

ifeq ($(HOST_OS),linux)
  LOCAL_SRC_FILES += $(FASTBT)/usb_linux.c $(FASTBT)/util_linux.c
endif

ifeq ($(HOST_OS),darwin)
  LOCAL_SRC_FILES += $(FASTBT)/usb_osx.c $(FASTBT)/util_osx.c
  LOCAL_LDLIBS += -lpthread -framework CoreFoundation -framework IOKit \
	-framework Carbon
  CFLAGS += -DDARWIN
endif

ifeq ($(HOST_OS),windows)
  LOCAL_SRC_FILES += $(FASTBT)/usb_windows.c $(FASTBT)/util_windows.c
  EXTRA_STATIC_LIBS := AdbWinApi
  ifneq ($(strip $(USE_CYGWIN)),)
    # Pure cygwin case
    LOCAL_LDLIBS += -lpthread
    LOCAL_C_INCLUDES += /usr/include/w32api/ddk
  endif
  ifneq ($(strip $(USE_MINGW)),)
    # MinGW under Linux case
    LOCAL_LDLIBS += -lws2_32
    USE_SYSDEPS_WIN32 := 1
    LOCAL_C_INCLUDES += /usr/i586-mingw32msvc/include/ddk
  endif
  LOCAL_C_INCLUDES += development/host/windows/usb/api
endif

all: $(LOCAL_MODULE)

$(LOCAL_MODULE): $(LOCAL_SRC_FILES)
	$(CC) -o $@ $^ $(CFLAGS) $(LOCAL_LDLIBS)

clean:
	rm -f $(LOCAL_MODULE)

.PHONY: all clean
.DEFAULT: all
