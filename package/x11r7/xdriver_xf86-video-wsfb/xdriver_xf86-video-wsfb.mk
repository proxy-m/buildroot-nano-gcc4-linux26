################################################################################
#
# xdriver_xf86-video-wsfb -- WSFB video driver
#
################################################################################

XDRIVER_XF86_VIDEO_WSFB_VERSION = 0.2.1
XDRIVER_XF86_VIDEO_WSFB_SOURCE = xf86-video-wsfb-$(XDRIVER_XF86_VIDEO_WSFB_VERSION).tar.bz2
XDRIVER_XF86_VIDEO_WSFB_SITE = http://xorg.freedesktop.org/releases/individual/driver
XDRIVER_XF86_VIDEO_WSFB_AUTORECONF = NO
XDRIVER_XF86_VIDEO_WSFB_LIBTOOL_PATCH = NO
XDRIVER_XF86_VIDEO_WSFB_DEPENDENCIES = xserver_xorg-server xproto_fontsproto xproto_randrproto xproto_renderproto xproto_xextproto xproto_xproto
XDRIVER_XF86_VIDEO_WSFB_INSTALL_TARGET_OPT = DESTDIR=$(TARGET_DIR) install

$(eval $(call AUTOTARGETS,package/x11r7,xdriver_xf86-video-wsfb))
