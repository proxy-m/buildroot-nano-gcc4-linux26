#############################################################
#
# xapp_xman - Manual page display program for the X Window System
#
#############################################################
XAPP_XMAN_VERSION:=1.0.3
XAPP_XMAN_SOURCE:=xman-$(XAPP_XMAN_VERSION).tar.bz2
XAPP_XMAN_SITE:=http://xorg.freedesktop.org/releases/individual/app
XAPP_XMAN_DIR:=$(BUILD_DIR)/xman-$(XAPP_XMAN_VERSION)
XAPP_XMAN_AUTORECONF = NO
XAPP_XMAN_LIBTOOL_PATCH = NO
XAPP_XMAN_INSTALL_TARGET = YES
XAPP_XMAN_DEPENDENCIES = xlib_libXaw

ifeq ($(BR2_PACKAGE_XLIB_LIBXPRINTUTIL),y)
XAPP_XMAN_CONF_OPT += --enable-xprint
endif

$(DL_DIR)/$(XAPP_XMAN_SOURCE):
	$(call DOWNLOAD,$(XAPP_XMAN_SITE),$(XAPP_XMAN_SOURCE))

$(XAPP_XMAN_DIR)/.extracted: $(DL_DIR)/$(XAPP_XMAN_SOURCE)
	$(BZCAT) $(DL_DIR)/$(XAPP_XMAN_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	touch $@

$(XAPP_XMAN_DIR)/.patched: $(XAPP_XMAN_DIR)/.extracted
	toolchain/patch-kernel.sh $(XAPP_XMAN_DIR) package/x11r7/xapp_xman/ xapp_xman\*.patch
	touch $@

$(XAPP_XMAN_DIR)/.configured: $(XAPP_XMAN_DIR)/.patched
	(cd $(XAPP_XMAN_DIR) && \
		aclocal -I. -I$(STAGING_DIR)/usr/share/aclocal --install && \
		autoconf -I$(STAGING_DIR)/usr/share/aclocal && \
		automake -ac && \
		rm -rf config.cache && \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		STAGING_DIR=$(STAGING_DIR) \
 \
 ac_cv_file__etc_man_conf=no \
 ac_cv_file__etc_man_config=no \
 ac_cv_file__etc_manpath_config=no \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--sysconfdir=/etc \
		--enable-shared \
		--disable-static \
		--disable-IPv6 \
		$(DISABLE_NLS) \
 \
	)
	touch $@

$(XAPP_XMAN_DIR)/.built: $(XAPP_XMAN_DIR)/.configured
	$(MAKE) CC=$(TARGET_CC) CXX=$(TARGET_CC) -C $(XAPP_XMAN_DIR)
	touch $@

$(XAPP_XMAN_DIR)/.installed: $(XAPP_XMAN_DIR)/.built
	$(MAKE) prefix=$(TARGET_DIR)/usr -C $(XAPP_XMAN_DIR) install-exec
	$(MAKE) prefix=$(STAGING_DIR)/usr -C $(XAPP_XMAN_DIR) install
#	toolchain/replace.sh $(STAGING_DIR)/usr/lib ".*\.la" "\(['= ]\)/usr" "\\1$(STAGING_DIR)/usr"
	find $(TARGET_DIR)/usr -name '*.la' -print -delete
	touch $@

xapp_xman-clean:
	$(MAKE) prefix=$(STAGING_DIR)/usr -C $(XAPP_XMAN_DIR) uninstall
	$(MAKE) prefix=$(TARGET_DIR)/usr -C $(XAPP_XMAN_DIR) uninstall
	-$(MAKE) -C $(XAPP_XMAN_DIR) clean
	-rm $(XAPP_XMAN_DIR)/.installed
	-rm $(XAPP_XMAN_DIR)/.built

xapp_xman-dirclean:
	rm -rf $(XAPP_XMAN_DIR)

xapp_xman-source: $(XAPP_XMAN_DIR)/.extracted
xapp_xman-patch: $(XAPP_XMAN_DIR)/.patched
xapp_xman-configure: $(XAPP_XMAN_DIR)/.configured
xapp_xman-build: $(XAPP_XMAN_DIR)/.built

xapp_xman: $(XAPP_XMAN_DIR)/.installed

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_XAPP_XMAN),y)
TARGETS+=xapp_xman
endif

# :mode=makefile:
