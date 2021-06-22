############################################
#
# v86d
# 
############################################

V86D_VERSION = 0.1.10
V86D_SOURCE = v86d-$(V86D_VERSION).tar.bz2
V86D_SITE = https://mirror.koddos.net/calculate-linux/source/v86d
V86D_DIR:=$(BUILD_DIR)/v86d-$(V86D_VERSION)
V86D_LICENSE = GPLv2

# The configure script autodetects the host architecture, 
# and assumes the target architecture to be the same as the host,
# so we must use the target architecture flags provided 
# by Buildroot for proper cross-compilation. The x86emu 
# configure option should be 'n' for i386, and 'y' for x86-64.

X86EMU = $(if $(BR2_i386),n,y)


######$(eval $(gentargets-package))
###$(eval $(call AUTOTARGETS,package,v86d))


V86D_BINARY:=v86d
V86D_TARGET_BINARY:=sbin/v86d

$(DL_DIR)/$(V86D_SOURCE):
	 $(call DOWNLOAD,$(V86D_SITE),$(V86D_SOURCE))

v86d-source: $(DL_DIR)/$(V86D_SOURCE)

$(V86D_DIR)/.unpacked: $(DL_DIR)/$(V86D_SOURCE)
	$(BZCAT) $(DL_DIR)/$(V86D_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	if [ -d $(V86D_DIR)/patches ]; then \
		toolchain/patch-kernel.sh $(V86D_DIR) $(V86D_DIR)/patches \*.patch; \
	fi
	$(CONFIG_UPDATE) $(V86D_DIR)
	touch $@

# v86d's configure script is not autoconf-based.
$(V86D_DIR)/.configured: $(V86D_DIR)/.unpacked
	(cd $(V86D_DIR) ; rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		./configure \
		--with-debug=n --with-klibc=n --with-x86emu=$(X86EMU))
	touch $@

# It is necessary to define __i386__ explicitly for successful compilation.
$(TARGET_DIR)/$(V86D_TARGET_BINARY): $(V86D_DIR)/.configured
	$(MAKE1) CC="$(TARGET_CC) -D__i386__ -std=gnu99 -fgnu89-inline -I$(BUILD_DIR)/linux-$(BR2_DEFAULT_KERNEL_HEADERS)/include/" LD="$(TARGET_LD)" -C $(V86D_DIR) all
	$(INSTALL) -D -m 0755 $(V86D_DIR)/v86d $(TARGET_DIR)/$(V86D_TARGET_BINARY)
	touch $@	

v86d: $(TARGET_DIR)/$(V86D_TARGET_BINARY)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_V86D),y)
TARGETS+=v86d
endif
