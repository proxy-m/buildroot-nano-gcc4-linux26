#############################################################
#
# atk
#
#############################################################
ATK_VERSION = 1.30.0
ATK_SOURCE = atk-$(ATK_VERSION).tar.bz2
ATK_SITE = http://ftp.gnome.org/pub/gnome/sources/atk/1.30/
ATK_LIBTOOL_PATCH = NO
ATK_INSTALL_STAGING = YES
ATK_INSTALL_TARGET = YES
ATK_INSTALL_STAGING_OPT = DESTDIR=$(STAGING_DIR) LDFLAGS=-L$(STAGING_DIR)/usr/lib install

ATK_CONF_ENV = ac_cv_func_posix_getpwuid_r=yes \
		glib_cv_stack_grows=no glib_cv_uscore=no \
		ac_cv_func_strtod=yes ac_fsusage_space=yes \
		fu_cv_sys_stat_statfs2_bsize=yes ac_cv_func_closedir_void=no \
		ac_cv_func_getloadavg=no ac_cv_lib_util_getloadavg=no \
		ac_cv_lib_getloadavg_getloadavg=no ac_cv_func_getgroups=yes \
		ac_cv_func_getgroups_works=yes ac_cv_func_chown_works=yes \
		ac_cv_have_decl_euidaccess=no ac_cv_func_euidaccess=no \
		ac_cv_have_decl_strnlen=yes ac_cv_func_strnlen_working=yes \
		ac_cv_func_lstat_dereferences_slashed_symlink=yes ac_cv_func_lstat_empty_string_bug=no \
		ac_cv_func_stat_empty_string_bug=no vb_cv_func_rename_trailing_slash_bug=no \
		ac_cv_have_decl_nanosleep=yes jm_cv_func_nanosleep_works=yes \
		gl_cv_func_working_utimes=yes ac_cv_func_utime_null=yes \
		ac_cv_have_decl_strerror_r=yes ac_cv_func_strerror_r_char_p=no \
		jm_cv_func_svid_putenv=yes ac_cv_func_getcwd_null=yes \
		ac_cv_func_getdelim=yes ac_cv_func_mkstemp=yes \
		utils_cv_func_mkstemp_limitations=no utils_cv_func_mkdir_trailing_slash_bug=no \
		ac_cv_func_memcmp_working=yes ac_cv_have_decl_malloc=yes \
		gl_cv_func_malloc_0_nonnull=yes ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_calloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes \
		jm_cv_func_gettimeofday_clobber=no gl_cv_func_working_readdir=yes \
		jm_ac_cv_func_link_follows_symlink=no utils_cv_localtime_cache=no \
		ac_cv_struct_st_mtim_nsec=no gl_cv_func_tzset_clobber=no \
		gl_cv_func_getcwd_null=yes gl_cv_func_getcwd_path_max=yes \
		ac_cv_func_fnmatch_gnu=yes am_getline_needs_run_time_check=no \
		am_cv_func_working_getline=yes gl_cv_func_mkdir_trailing_slash_bug=no \
		gl_cv_func_mkstemp_limitations=no ac_cv_func_working_mktime=yes \
		jm_cv_func_working_re_compile_pattern=yes ac_use_included_regex=no \
		gl_cv_c_restrict=no ac_cv_prog_F77=no

ATK_CONF_OPT =  --enable-shared \
		--enable-static \
		--disable-glibtest --enable-explicit-deps=no \
		--disable-debug

ifeq ($(BR2_PACKAGE_XORG7),y)
ATK_CONF_OPT += --with-x \
		--x-includes=$(STAGING_DIR)/usr/include/X11 \
		--x-libraries=$(STAGING_DIR)/usr/lib --disable-glibtest
else
ATK_CONF_OPT += --without-x
endif

ATK_DEPENDENCIES = libglib2 host-pkgconfig

$(eval $(call AUTOTARGETS,package,atk))

# atk for the host
ATK_HOST_DIR:=$(BUILD_DIR)/atk-$(ATK_VERSION)-host

$(DL_DIR)/$(ATK_SOURCE):
	$(call DOWNLOAD,$(ATK_SITE),$(ATK_SOURCE))

$(STAMP_DIR)/host_atk_unpacked: $(DL_DIR)/$(ATK_SOURCE)
	mkdir -p $(ATK_HOST_DIR)
	$(INFLATE$(suffix $(ATK_SOURCE))) $< | \
		$(TAR) $(TAR_STRIP_COMPONENTS)=1 -C $(ATK_HOST_DIR) $(TAR_OPTIONS) -
	touch $@

$(STAMP_DIR)/host_atk_configured: $(STAMP_DIR)/host_atk_unpacked $(STAMP_DIR)/host_libglib2_installed $(STAMP_DIR)/host_pkgconfig_installed
	(cd $(ATK_HOST_DIR); rm -rf config.cache; \
		$(HOST_CONFIGURE_OPTS) \
		CFLAGS="$(HOST_CFLAGS)" \
		LDFLAGS="$(HOST_LDFLAGS)" \
		./configure $(QUIET) \
		--prefix="$(HOST_DIR)/usr" \
		--sysconfdir="$(HOST_DIR)/etc" \
		--enable-shared \
		--disable-static \
		--disable-glibtest \
	)
	touch $@

$(STAMP_DIR)/host_atk_compiled: $(STAMP_DIR)/host_atk_configured
	$(HOST_MAKE_ENV) $(MAKE) -C $(ATK_HOST_DIR)
	touch $@

$(STAMP_DIR)/host_atk_installed: $(STAMP_DIR)/host_atk_compiled
	$(HOST_MAKE_ENV) $(MAKE) -C $(ATK_HOST_DIR) install
	touch $@

host-atk: $(STAMP_DIR)/host_atk_installed

host-atk-source: atk-source

host-atk-clean:
	rm -f $(addprefix $(STAMP_DIR)/host_atk_,unpacked configured compiled installed)
	-$(MAKE) -C $(ATK_HOST_DIR) uninstall
	-$(MAKE) -C $(ATK_HOST_DIR) clean

host-atk-dirclean:
	rm -rf $(ATK_HOST_DIR)
