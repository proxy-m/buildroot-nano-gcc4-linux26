#############################################################
#
# sshfs
#
#############################################################

SSHFS_VERSION:=2.2
SSHFS_SOURCE:=sshfs-fuse-$(SSHFS_VERSION).tar.gz
SSHFS_SITE=http://$(BR2_SOURCEFORGE_MIRROR).dl.sourceforge.net/sourceforge/fuse/$(SSHFS_VERSION)/sshfs-fuse
SSHFS_AUTORECONF:=NO
SSHFS_INSTALL_STAGING:=NO
SSHFS_INSTALL_TARGET:=YES

SSHFS_DEPENDENCIES = \
	libglib2 libfuse openssh \
	$(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext) \
	$(if $(BR2_ENABLE_LOCALE),,libiconv)

$(eval $(call AUTOTARGETS,package,sshfs))
