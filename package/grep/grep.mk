#############################################################
#
# grep
#
#############################################################
GREP_VERSION:=2.5.3
GREP_SOURCE:=grep-$(GREP_VERSION).tar.bz2
GREP_SITE:=$(BR2_GNU_MIRROR)/grep
export MAKEINFO=true
GREP_CONF_OPT = --disable-perl-regexp --without-included-regex \
	$(DISABLE_NLS) $(DISABLE_LARGEFILE)

GREP_DEPENDENCIES = $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext)

$(eval $(call AUTOTARGETS,package,grep))
