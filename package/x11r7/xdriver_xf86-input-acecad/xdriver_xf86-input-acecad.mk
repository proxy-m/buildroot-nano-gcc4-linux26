################################################################################
#
# xdriver_xf86-input-acecad -- Acecad Flair input driver
#
################################################################################

XDRIVER_XF86_INPUT_ACECAD_VERSION = 1.4.0
XDRIVER_XF86_INPUT_ACECAD_SOURCE = xf86-input-acecad-$(XDRIVER_XF86_INPUT_ACECAD_VERSION).tar.bz2
XDRIVER_XF86_INPUT_ACECAD_SITE = http://xorg.freedesktop.org/releases/individual/driver
XDRIVER_XF86_INPUT_ACECAD_LIBTOOL_PATCH = NO
XDRIVER_XF86_INPUT_ACECAD_AUTORECONF = NO
XDRIVER_XF86_INPUT_ACECAD_DEPENDENCIES = xserver_xorg-server xproto_inputproto xproto_randrproto xproto_xproto
XDRIVER_XF86_INPUT_ACECAD_INSTALL_TARGET_OPT = DESTDIR=$(TARGET_DIR) install

$(eval $(call AUTOTARGETS,package/x11r7,xdriver_xf86-input-acecad))
