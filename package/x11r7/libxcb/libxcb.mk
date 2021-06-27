#############################################################
#
# libxcb
#
#############################################################
LIBXCB_VERSION = 1.7
LIBXCB_SOURCE = libxcb-$(LIBXCB_VERSION).tar.bz2
LIBXCB_SITE = http://xcb.freedesktop.org/dist/

LIBXCB_INSTALL_STAGING = YES
LIBXCB_LIBTOOL_PATCH = NO

## TODO: FIX!!! Python on your host must be same as in buildroot. Temporary limitation.
###HOST_PYTHON_FULL := "$(shell echo unshare -mr chroot $(TMP_TMP__DIR) /usr/bin/python$(HOST_PYTHON_VERSION))"

##HOST_PYTHON_VERSION=2.7
HOST_PYTHON_VERSION=$(shell python --version 2>&1 | sed 's/Python \([0-9]\.[^\.]\).*/\1/')

LIBXCB_DEPENDENCIES = \
	libxslt pthread-stubs xcb-proto xlib_libXdmcp xlib_libXau \
	xcb-proto host-pkgconfig
LIBXCB_CONF_ENV = STAGING_DIR="$(STAGING_DIR)"
LIBXCB_MAKE_OPT = XCBPROTO_XCBINCLUDEDIR=$(STAGING_DIR)/usr/share/xcb \
	XCBPROTO_XCBPYTHONDIR=$(TARGET_DIR)/usr/lib/python$(HOST_PYTHON_VERSION)/site-packages
LIBXCB_CONF_OPT = --disable-build-docs

HOST_LIBXCB_CONF_OPT = --disable-build-docs

$(eval $(call AUTOTARGETS,package/x11r7,libxcb))
