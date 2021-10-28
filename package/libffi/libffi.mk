################################################################################
#
# libffi
#
################################################################################

LIBFFI_VERSION = 3.0.10
LIBFFI_SITE = ftp://sourceware.org/pub/libffi
LIBFFI_LIBTOOL_PATCH = NO
LIBFFI_INSTALL_STAGING = YES
LIBFFI_AUTORECONF = YES


# Move the headers to the usual location, and adjust the .pc file
# accordingly
define LIBFFI_MOVE_HEADERS
	mv $(1)/usr/lib/libffi-$(LIBFFI_VERSION)/include/*.h $(1)/usr/include/
	sed -i '/^includedir.*/d' \
        $(1)/usr/lib/pkgconfig/libffi.pc
	rm -rf $(1)/usr/lib/libffi-*
endef

LIBFFI_MOVE_STAGING_HEADERS = $(call LIBFFI_MOVE_HEADERS,$(STAGING_DIR))
LIBFFI_POST_INSTALL_STAGING_HOOKS += LIBFFI_MOVE_STAGING_HEADERS

HOST_LIBFFI_MOVE_HOST_HEADERS = $(call LIBFFI_MOVE_HEADERS,$(HOST_DIR))
HOST_LIBFFI_POST_INSTALL_HOOKS += HOST_LIBFFI_MOVE_HOST_HEADERS

# Similar for target headers
define LIBFFI_MOVE_TARGET_HEADERS
	install -d $(TARGET_DIR)/usr/include/
	mv $(TARGET_DIR)/usr/lib/libffi-*/include/*.h $(TARGET_DIR)/usr/include/
	sed -i '/^includedir.*/d' $(TARGET_DIR)/usr/lib/pkgconfig/libffi.pc
	rm -rf $(TARGET_DIR)/usr/lib/libffi-*
endef

LIBFFI_POST_INSTALL_TARGET_HOOKS += LIBFFI_MOVE_TARGET_HEADERS

$(eval $(call AUTOTARGETS,package,libffi))
