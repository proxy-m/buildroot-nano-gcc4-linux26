#############################################################
#
# microperl
#
#############################################################
MICROPERL_VERSION = 5.12.4
#MICROPERL_VERSION = 5.10.1
MICROPERL_SITE = http://www.cpan.org/src/5.0
MICROPERL_SOURCE = perl-$(MICROPERL_VERSION).tar.bz2
MICROPERL_CAT:=$(BZCAT)
MICROPERL_DEPENDENCIES = host-microperl
MICROPERL_MODS_DIR = /usr/lib/perl5/$(MICROPERL_VERSION)
MICROPERL_ARCH_DIR = $(MICROPERL_MODS_DIR)/$(REAL_GNU_TARGET_NAME)
MICROPERL_MODS = $(call qstrip,$(BR2_PACKAGE_MICROPERL_MODULES))
MICROPERL_DIR=$(BUILD_DIR)/perl-$(MICROPERL_VERSION)
MICROPERL_LIBTOOL_PATCH = yes

# Minimal set of modules required for 'perl -V' to work
MICROPERL_ARCH_MODS = Config.pm Config_git.pl Config_heavy.pl
MICROPERL_BASE_MODS = strict.pm

MICROPERL_MODS += $(MICROPERL_BASE_MODS)

ifeq ($(BR2_PACKAGE_AUTOMAKE),y)
MICROPERL_MODS+=File/Basename.pm Errno.pm Config.pm IO/File.pm Symbol.pm \
	SelectSaver.pm IO/Seekable.pm IO/Handle.pm IO.pm XSLoader.pm \
	DynaLoader.pm AutoLoader.pm Carp/Heavy.pm
endif

# CGI bundle
ifeq ($(BR2_PACKAGE_MICROPERL_BUNDLE_CGI),y)
MICROPERL_MODS += constant.pm CGI CGI.pm Carp.pm Exporter.pm overload.pm \
	vars.pm warnings.pm warnings/register.pm
endif

MICROPERL_MODS += $(MICROPERL_ARCH_MODS)

$(DL_DIR)/$(MICROPERL_SOURCE):
	$(call DOWNLOAD,$(MICROPERL_SITE),$(MICROPERL_SOURCE))

$(MICROPERL_DIR)/.source: $(DL_DIR)/$(MICROPERL_SOURCE)
	$(MICROPERL_CAT) $(DL_DIR)/$(MICROPERL_SOURCE) | tar -C $(BUILD_DIR) $(TAR_OPTIONS) -
	chmod -R u+w $(MICROPERL_DIR)
	toolchain/patch-kernel.sh $(MICROPERL_DIR) package/microperl/ microperl-\*.patch
	touch $@

$(MICROPERL_DIR)/.host_configured: $(MICROPERL_DIR)/.source
	# we need to build a perl for the host just for Errno.pm
	(cd $(MICROPERL_DIR); ./Configure -Dcc="$(HOSTCC)" -de -A libs='-lm' )
	touch $@


$(MICROPERL_DIR)/.host_configured_and_fixed: $(MICROPERL_DIR)/.host_configured
	$(SED) 's/^.*<command-line>.*//g' $(MICROPERL_DIR)/Makefile || $(SED) 's/^.*<command-line>.*//g' $(MICROPERL_DIR)/makefile
	$(SED) 's/^.*<command-line>.*//g' $(MICROPERL_DIR)/x2p/Makefile || $(SED) 's/^.*<command-line>.*//g' $(MICROPERL_DIR)/x2p/makefile
	touch $@

$(MICROPERL_DIR)/.host_make: $(MICROPERL_DIR)/.host_configured_and_fixed
	$(MAKE) -C $(MICROPERL_DIR)		|| echo "An error is expected on make"
	touch $@

$(MICROPERL_DIR)/.host_make_fixed: $(MICROPERL_DIR)/.host_make
	#find $(TARGET_DIR)/$(MICROPERL_MODS_DIR) -type f -name *.t \
	#	-exec rm -f {} \;
	$(MAKE) -C $(MICROPERL_DIR) test	|| echo "An error is expected on make test"
	true
	touch $@

ifeq ($(BR2_ENDIAN),"BIG")
define MICROPERL_BIGENDIAN
	$(SED) '/^byteorder=/d' $(@D)/uconfig.sh
	echo "byteorder='4321'" >>$(@D)/uconfig.sh
endef
endif

ifeq ($(BR2_LARGEFILE),y)
define MICROPERL_LARGEFILE
	$(SED) '/^uselargefiles=/d' $(@D)/uconfig.sh
	echo "uselargefiles='define'" >>$(@D)/uconfig.sh
endef
endif

ifeq ($(BR2_USE_WCHAR),y)
define MICROPERL_WCHAR
	$(SED) '/^d_mbstowcs=/d' -e '/^d_mbtowc=/d' -e '/^d_wcstombs=/d' \
		-e '/^d_wctomb=/d' $(@D)/uconfig.sh
	echo "d_mbstowcs='define'" >>$(@D)/uconfig.sh
	echo "d_mbtowc='define'" >>$(@D)/uconfig.sh
	echo "d_wcstombs='define'" >>$(@D)/uconfig.sh
	echo "d_wctomb='define'" >>$(@D)/uconfig.sh
endef
endif

$(MICROPERL_DIR)/.configured: $(MICROPERL_DIR)/.host_make_fixed
	$(SED) '/^archlib=/d' -e '/^archlibexp=/d' -e '/^optimize=/d' \
		-e '/^archname=/d' -e '/^d_poll=/d' -e '/^i_poll=/d' \
		-e '/^osname=/d' -e '/^u32type=/d' -e '/^d_archlib=/d' \
		-e '/^d_memset=/d' -e '/^i_fcntl=/d' -e '/^useperlio=/d' \
		-e '/^need_va_copy=/d' $(@D)/uconfig.sh
	$(SED) 's/5.12/$(MICROPERL_VERSION)/' $(@D)/uconfig.sh
	echo "archlib='$(MICROPERL_ARCH_DIR)'" >>$(@D)/uconfig.sh
	echo "archlibexp='$(MICROPERL_ARCH_DIR)'" >>$(@D)/uconfig.sh
	echo "d_archlib='define'" >>$(@D)/uconfig.sh
	echo "archname='$(REAL_GNU_TARGET_NAME)'" >>$(@D)/uconfig.sh
	echo "osname='linux'" >>$(@D)/uconfig.sh
	echo "cc='$(TARGET_CC)'" >>$(@D)/uconfig.sh
	echo "ccflags='$(TARGET_CFLAGS) -ffat-lto-objects'" >>$(@D)/uconfig.sh
	echo "ldflags='$(TARGET_LDFLAGS) -ffat-lto-objects'" >>$(@D)/uconfig.sh
	echo "optimize='$(TARGET_CFLAGS)'" >>$(@D)/uconfig.sh
	echo "usecrosscompile='define'" >>$(@D)/uconfig.sh
	echo "d_memset='define'" >>$(@D)/uconfig.sh
	echo "i_fcntl='define'" >>$(@D)/uconfig.sh
	echo "useperlio='define'" >>$(@D)/uconfig.sh
	echo "u32type='unsigned int'" >>$(@D)/uconfig.sh
	echo "need_va_copy='define'" >>$(@D)/uconfig.sh
	echo "d_poll='define'" >>$(@D)/uconfig.sh
	echo "i_poll='define'" >>$(@D)/uconfig.sh
	$(SED) 's/UNKNOWN-/Buildroot $(BR2_VERSION_FULL) /' $(@D)/patchlevel.h
	$(SED) 's/local\///' $(@D)/uconfig.sh
	$(MICROPERL_BIGENDIAN)
	$(MICROPERL_LARGEFILE)
	$(MICROPERL_WCHAR)
	$(MAKE) -C $(@D) -f Makefile.micro regen_uconfig
	cp -f $(@D)/uconfig.h $(@D)/config.h
	cp -f $(@D)/uconfig.sh $(@D)/config.sh
	echo "ccname='$(TARGET_CC)'" >>$(@D)/config.sh
	echo "PERL_CONFIG_SH=true" >>$(@D)/config.sh
	cd $(@D) ; perl make_patchnum.pl || ./miniperl make_patchnum.pl ; \
	perl configpm || ./miniperl configpm
	# we need to build a perl for the host just for Errno.pm
	(cd $(MICROPERL_DIR); \
	 chmod u+wx uconfig.h uconfig.sh; ./uconfig.sh; \
	 $(SED) 's,PRIVLIB ".*,PRIVLIB "/$(MICROPERL_MODS_DIR)",' \
		 -e 's,PRIVLIB_EXP ".*,PRIVLIB_EXP "$(MICROPERL_MODS_DIR)",' \
		 -e 's,BIN ".*,BIN "/usr/bin",' \
		 ./uconfig.h; \
	)
	#(cd $(MICROPERL_DIR); \
	# chmod u+w uconfig.h; ./uconfig.sh; \
	# $(MAKE) -f $(MICROPERL_DIR)/Makefile.micro regen_uconfig; \
	#)
	#(cd $(MICROPERL_DIR); \
	# echo "ln -sf $(HOST_DIR)/usr/bin/perl miniperl; "; \
	# echo "ln -sf `which perl` miniperl; "; \
	# echo "PERL5LIB=$(TARGET_DIR)/$(MICROPERL_ARCH_DIR);"; \
	# CONFIG=uconfig.h \
	# ./miniperl make_ext.pl -Ilib LIBPERL_A=libperl.a MAKE="$(firstword $(MAKE))" --nonxs \
	# `echo Errno.pm|sed -e 's/.pm//'`; \
	#)
	touch $@

$(MICROPERL_DIR)/microperl: $(MICROPERL_DIR)/.configured
	$(MAKE) -f $(MICROPERL_DIR)/Makefile.micro CC="$(TARGET_CC)" \
		OPTIMIZE="$(TARGET_CFLAGS)" -C $(MICROPERL_DIR) CONFIG=uconfig.h
ifeq ($(BR2_PACKAGE_AUTOMAKE),y)
	#(cd $(@D); \
	# CONFIG=uconfig.h $(SHELL) ext/util/make_ext nonxs Errno MAKE="$(firstword $(MAKE))"; \
	#)
endif
	true
	touch $@

$(TARGET_DIR)/usr/bin/microperl: $(MICROPERL_DIR)/microperl
ifneq ($(MICROPERL_MODS),)
	(cd $(MICROPERL_DIR); \
	 for i in $(patsubst %,$(TARGET_DIR)/$(MICROPERL_MODS_DIR)/%,$(dir $(MICROPERL_MODS))); do \
		[ -d $$i ] || mkdir -p $$i; \
	 done; \
	 for i in $(MICROPERL_MODS); do \
	 cp -dpf $(MICROPERL_DIR)/lib/$$i $(TARGET_DIR)/$(MICROPERL_MODS_DIR)/$$i; \
	 done; \
	)
endif
	cp -dpf $(MICROPERL_DIR)/microperl $@
ifneq ($(BR2_STRIP_none),y)
	$(STRIPCMD) $(STRIP_STRIP_ALL) $@
endif
	(cd $(TARGET_DIR)/usr/bin; rm -f perl; ln -s microperl perl;)

microperl: $(TARGET_DIR)/usr/bin/microperl

microperl-source: $(DL_DIR)/$(MICROPERL_SOURCE)

microperl-unpacked: $(MICROPERL_DIR)/.source

microperl-config: $(MICROPERL_DIR)/.host_configured

microperl-host: $(MICROPERL_DIR)/.host_make

microperl-host-fixed: $(MICROPERL_DIR)/.host_make_fixed

microperl-clean:
	rm -rf $(TARGET_DIR)/usr/bin/microperl \
		$(TARGET_DIR)/$(MICROPERL_MODS_DIR) $(TARGET_DIR)/usr/bin/perl
	-rmdir $(TARGET_DIR)/usr/lib/perl$(MICROPERL_MAJ)
	-$(MAKE) -C $(MICROPERL_DIR) -f Makefile.micro clean

microperl-dirclean:
	rm -rf $(MICROPERL_DIR)

#############################################################
#
# Toplevel Makefile options
#
#############################################################
ifeq ($(BR2_PACKAGE_MICROPERL),y)
TARGETS+=microperl
endif
