#############################################################
#
# flex
#
#############################################################
FLEX_VERSION:=2.5.37
FLEX_SOURCE:=flex-$(FLEX_VERSION).tar.gz
FLEX_SITE:=http://download.sourceforge.net/project/flex
FLEX_DIR:=$(BUILD_DIR)/flex-$(FLEX_VERSION)
FLEX_INSTALL_STAGING=YES
FLEX_DEPENDENCIES = \
	$(if $(BR2_PACKAGE_GETTEXT_IF_LOCALE),gettext) m4
FLEX_CONF_ENV = ac_cv_path_M4=/usr/bin/m4
# we don't have a host-gettext/libintl
HOST_FLEX_DEPENDENCIES = host-m4

define FLEX_DISABLE_PROGRAM
	$(SED) 's/^bin_PROGRAMS.*//' $(@D)/Makefile.in
endef

# flex++ symlink is broken when flex binary is not installed
define FLEX_REMOVE_BROKEN_SYMLINK
	rm -f $(TARGET_DIR)/usr/bin/flex++
endef

# lex -> flex
define FLEX_INSTALL_LEX
cd $(TARGET_DIR)/usr/bin && ln -snf flex lex
endef

define FLEX_UNINSTALL_LEX
-rm $(TARGET_DIR)/usr/bin/lex
endef

FLEX_POST_INSTALL_HOOKS += FLEX_INSTALL_LEX
FLEX_POST_CLEAN_HOOKS += FLEX_UNINSTALL_LEX

FLEX_POST_PATCH_HOOKS += FLEX_DISABLE_PROGRAM

FLEX_POST_INSTALL_HOOKS += FLEX_REMOVE_BROKEN_SYMLINK

# libfl installation
ifeq ($(BR2_PACKAGE_FLEX_LIBFL),y)
define FLEX_INSTALL_LIBFL
install -D $(FLEX_DIR)/libfl.a $(STAGING_DIR)/usr/lib/libfl.a
endef

define FLEX_UNINSTALL_LIBFL
-rm $(STAGING_DIR)/lib/libfl.a
endef

FLEX_POST_INSTALL_HOOKS += FLEX_INSTALL_LIBFL
FLEX_POST_CLEAN_HOOKS += FLEX_UNINSTALL_LIBFL
endif

$(eval $(call AUTOTARGETS,package,flex))
$(eval $(call AUTOTARGETS,package,flex,host))
