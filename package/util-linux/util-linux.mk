#############################################################
#
# util-linux
#
#############################################################
UTIL-LINUX_VERSION:=2.13-pre7
UTIL-LINUX_SOURCE:=util-linux-$(UTIL-LINUX_VERSION).tar.bz2
UTIL-LINUX_SITE:=$(BR2_KERNEL_MIRROR)/linux/utils/util-linux/testing
UTIL_LINUX_AUTORECONF = YES
UTIL_LINUX_INSTALL_STAGING = YES
UTIL_LINUX_DEPENDENCIES = host-pkgconfig
UTIL-LINUX_DIR:=$(BUILD_DIR)/util-linux-$(UTIL-LINUX_VERSION)
UTIL-LINUX_CAT:=$(BZCAT)
UTIL-LINUX_BINARY:=$(UTIL-LINUX_DIR)/misc-utils/chkdupexe
UTIL-LINUX_TARGET_BINARY:=$(TARGET_DIR)/usr/bin/chkdupexe

UTIL_LINUX_CONF_OPT += --disable-rpath --disable-makeinstall-chown

# schedutils isn't support for all archs
ifneq ($(BR2_i386)$(BR2_powerpc)$(BR2_x86_64)$(BR2_ia64)$(BR2_alpha),)
UTIL-LINUX_SCHED_UTILS:=--enable-schedutils
else
UTIL-LINUX_SCHED_UTILS:=--disable-schedutils
endif

# If both util-linux and busybox are selected, make certain util-linux
# wins the fight over who gets to have their utils actually installed
ifeq ($(BR2_PACKAGE_BUSYBOX),y)
UTIL_LINUX_DEPENDENCIES += busybox
endif

ifeq ($(BR2_PACKAGE_NCURSES),y)
UTIL_LINUX_DEPENDENCIES += ncurses
else
UTIL_LINUX_CONF_OPT += --without-ncurses
endif

ifeq ($(BR2_PACKAGE_GETTEXT),y)
UTIL_LINUX_DEPENDENCIES += gettext
UTIL_LINUX_MAKE_OPT += LIBS=-lintl
endif

UTIL_LINUX_INSTALL_STAGING_OPT += MKINSTALLDIRS=$(@D)/config/mkinstalldirs
UTIL_LINUX_INSTALL_TARGET_OPT += MKINSTALLDIRS=$(@D)/config/mkinstalldirs

$(DL_DIR)/$(UTIL-LINUX_SOURCE):
	$(call DOWNLOAD,$(UTIL-LINUX_SITE),$(UTIL-LINUX_SOURCE))

$(UTIL-LINUX_DIR)/.unpacked: $(DL_DIR)/$(UTIL-LINUX_SOURCE)
	$(UTIL-LINUX_CAT) $(DL_DIR)/$(UTIL-LINUX_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	toolchain/patch-kernel.sh $(UTIL-LINUX_DIR) package/util-linux/ util-linux\*.patch
	touch $(UTIL-LINUX_DIR)/.unpacked

$(UTIL-LINUX_DIR)/.configured: $(UTIL-LINUX_DIR)/.unpacked
	(cd $(UTIL-LINUX_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		$(TARGET_CONFIGURE_ARGS) \
		ac_cv_lib_blkid_blkid_known_fstype=no \
		./configure $(QUIET) \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		$(UTIL_LINUX_CONF_OPT) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_MOUNT),,--disable-mount) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_FSCK),,--disable-fsck) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_LIBMOUNT),,--disable-libmount) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_LIBUUID),,--disable-libuuid) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_UUIDD),,--disable-uuidd) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_LIBBLKID),,--disable-libblkid) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_AGETTY),,--disable-agetty) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_CRAMFS),,--disable-cramfs) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_SWITCH_ROOT),,--disable-switch_root) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_PIVOT_ROOT),,--disable-pivot_root) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_FALLOCATE),,--disable-fallocate) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_UNSHARE),,--disable-unshare) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_RENAME),,--disable-rename) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_WALL),,--disable-wall) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_PARTX),,--disable-partx) \
		--prefix=/ \
		$(if $(BR2_PACKAGE_UTIL_LINUX_ARCH),--enable-arch) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_INIT),--enable-init) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_KILL),--enable-kill) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_LAST),--enable-last) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_MESG),--enable-mesg) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_RAW),--enable-raw) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_RESET),--enable-reset) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_LOGIN_UTILS),--enable-login-utils) \
		$(if $(BR2_PACKAGE_UTIL_LINUX_WRITE),--enable-write) \
		--exec-prefix=/ \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		$(UTIL-LINUX_SCHED_UTILS) \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		ARCH=$(ARCH) \
	)
	touch $(UTIL-LINUX_DIR)/.configured

$(UTIL-LINUX_BINARY): $(UTIL-LINUX_DIR)/.configured
	$(MAKE) \
		-C $(UTIL-LINUX_DIR) \
		ARCH=$(ARCH) \
		CC="$(TARGET_CC)" \
		OPT="$(TARGET_CFLAGS)" \
		$(UTIL-LINUX_MAKE_OPT) \
		HAVE_SLANG="NO"

$(UTIL-LINUX_TARGET_BINARY): $(UTIL-LINUX_BINARY)
	$(MAKE) ARCH=$(ARCH) DESTDIR=$(TARGET_DIR) USE_TTY_GROUP=no -C $(UTIL-LINUX_DIR) install
	rm -rf $(TARGET_DIR)/share/locale $(TARGET_DIR)/usr/share/info \
		$(TARGET_DIR)/usr/share/man $(TARGET_DIR)/usr/share/doc

#If both util-linux and busybox are selected, make certain util-linux
#wins the fight over who gets to have their utils actually installed
ifeq ($(BR2_PACKAGE_BUSYBOX),y)
UTIL-LINUX_DEPENDENCIES := busybox $(UTIL-LINUX_DEPENDENCIES)
endif

util-linux: $(UTIL-LINUX_DEPENDENCIES) $(UTIL-LINUX_TARGET_BINARY)

util-linux-source: $(DL_DIR)/$(UTIL-LINUX_SOURCE)

util-linux-clean:
	#There is no working 'uninstall' target. Just skip it...
	#$(MAKE) DESTDIR=$(TARGET_DIR) -C $(UTIL-LINUX_DIR) uninstall
	-$(MAKE) -C $(UTIL-LINUX_DIR) clean

util-linux-dirclean:
	rm -rf $(UTIL-LINUX_DIR)


#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_UTIL-LINUX),y)
TARGETS+=util-linux
endif
