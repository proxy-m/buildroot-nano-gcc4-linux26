#############################################################
#
# libusb
#
#############################################################
LIBUSB_VERSION = 0.1.12.orig
LIBUSB_SOURCE = libusb_$(LIBUSB_VERSION).tar.gz
LIBUSB_SITE = http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/project/libusb/libusb-1.0/libusb-$(LIBUSB_VERSION)
LIBUSB_LIBTOOL_PATCH = NO
LIBUSB_INSTALL_STAGING = YES
LIBUSB_INSTALL_TARGET = YES

$(eval $(call AUTOTARGETS,package,libusb))
