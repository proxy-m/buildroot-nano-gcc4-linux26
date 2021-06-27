#############################################################
#
# libxcb
#
#############################################################
LIBXCB_VERSION = 1.5
LIBXCB_SOURCE = libxcb-$(LIBXCB_VERSION).tar.bz2
LIBXCB_SITE = http://xcb.freedesktop.org/dist/

LIBXCB_INSTALL_STAGING = YES

LIBXCB_AUTORECONF = NO
LIBXCB_LIBTOOL_PATCH = NO
LIBXCB_DEPENDENCIES = host-pkgconfig libxslt pthread-stubs xcb-proto xlib_libXdmcp xlib_libXau
LIBXCB_CONF_ENV = STAGING_DIR="$(STAGING_DIR)"

#####HOST_PYTHON_VERSION=$(shell python --version 2>&1 | sed 's/Python \([0-9]\.[^\.]\).*/\1/')
HOST_PYTHON_VERSION=2.7

## TODO: FIX!!!
#HOST_PYTHON_0 := ""
#HOST_PYTHON_0 := $(shell cp -a $(TARGET_DIR)/usr/bin/python$(HOST_PYTHON_VERSION) $(TARGET_DIR)/usr/bin/python  $(STAGING_DIR)/usr/bin/)
#HOST_PYTHON_0 := $(shell cp -a $(TARGET_DIR)/usr/lib/libpython$(HOST_PYTHON_VERSION)* $(STAGING_DIR)/usr/lib/)
#HOST_PYTHON_0 := $(shell cp -a $(TARGET_DIR)/usr/lib/lib* $(STAGING_DIR)/usr/lib/)
#HOST_PYTHON_0 := $(shell cp -a $(TARGET_DIR)/usr/lib/python$(HOST_PYTHON_VERSION) $(STAGING_DIR)/usr/lib/)

HOST_PYTHON_FULL := "$(shell echo unshare -mr chroot $(STAGING_DIR) /usr/bin/python$(HOST_PYTHON_VERSION))"

LIBXCB_MAKE_OPT = XCBPROTO_PREFIX_STAGING_DIR=$(STAGING_DIR) XCBPROTO_XCBINCLUDEDIR=/usr/share/xcb PYTHON=$(HOST_PYTHON_FULL) XCBPROTO_XCBPYTHONDIR=/usr/lib/python$(HOST_PYTHON_VERSION)/site-packages
###LIBXCB_MAKE_OPT = XCBPROTO_XCBINCLUDEDIR=$(STAGING_DIR)/usr/share/xcb XSLTPROC=/usr/bin/xsltproc
#####LIBXCB_MAKE_OPT = XCBPROTO_XCBINCLUDEDIR=$(STAGING_DIR)/usr/share/xcb XSLTPROC=/bin/true XCBPROTO_XCBPYTHONDIR=/dev/null

$(eval $(call AUTOTARGETS,package/x11r7,libxcb))

