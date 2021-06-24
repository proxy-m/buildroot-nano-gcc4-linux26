#############################################################
#
# midori
#
#############################################################

MIDORI_VERSION = 0.0.18
MIDORI_SOURCE = midori-$(MIDORI_VERSION).tar.gz
MIDORI_SITE = http://software.twotoasts.de/media/midori/
MIDORI_AUTORECONF = YES
MIDORI_INSTALL_STAGING = NO
MIDORI_INSTALL_TARGET = YES

MIDORI_DEPENDENCIES = \
	host-pkgconfig \
	xserver_xorg-server \
	libsexy \
 	libgtk2 \
 	libsexy \
 	webkit \
	$(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext) \
 	$(if $(BR2_PACKAGE_LIBICONV),libiconv)
 	
$(eval $(call AUTOTARGETS,package,midori))
