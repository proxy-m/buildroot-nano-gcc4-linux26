#############################################################
#
# xcb-util
#
#############################################################
XCB_UTIL_VERSION = 0.2.5
XCB_UTIL_SOURCE = xcb-util-$(XCB_UTIL_VERSION).tar.bz2
XCB_UTIL_SITE = http://xcb.freedesktop.org/dist/
XCB_UTIL_LIBTOOL_PATCH = NO

$(eval $(call AUTOTARGETS,package/x11r7,xcb-util))

