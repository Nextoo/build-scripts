#!/usr/bin/env ruby20
require_relative '../lib/nextoo/package'
require_relative '../lib/nextoo/header'
require_relative '../lib/nextoo/manifest'
gem "minitest"
require 'minitest/autorun'
require 'minitest/pride'

class TestManifestMerge < Minitest::Test
	def setup
		@test_new_header = <<-END.gsub(/^\t{3}/, '').strip
			ACCEPT_KEYWORDS: amd64
			ACCEPT_LICENSE: *
			ACCEPT_PROPERTIES: *
			ACCEPT_RESTRICT: *
			CBUILD: x86_64-pc-linux-gnu
			CHOST: x86_64-pc-linux-gnu
			CONFIG_PROTECT: /etc /usr/share/gnupg/qualified.txt
			CONFIG_PROTECT_MASK: /etc/ca-certificates.conf /etc/env.d /etc/fonts/fonts.conf /etc/gconf /etc/gentoo-release /etc/sandbox.d /etc/terminfo
			FEATURES: assume-digests binpkg-logs buildpkg config-protect-if-modified distlocks ebuild-locks fixlafiles getbinpkg merge-sync news parallel-fetch preserve-libs protect-owned sandbox sfperms splitdebug strict unknown-features-warn unmerge-logs unmerge-orphans userfetch userpriv usersandbox usersync
			GENTOO_MIRRORS: http://gentoo.closest.myvwan.com/gentoo
			IUSE_IMPLICIT: prefix
			PACKAGES: 1110
			PROFILE: /var/lib/layman/nextoo/profiles/0.0.1/default/linux/amd64/desktop/kde
			TIMESTAMP: 1389646578
			USE: 1stclassmsg X a52 aac aacs abi_x86_64 acl acpi alsa alsa_cards_ali5451 alsa_cards_als4000 alsa_cards_atiixp alsa_cards_atiixp-modem alsa_cards_bt87x alsa_cards_ca0106 alsa_cards_cmipci alsa_cards_emu10k1x alsa_cards_ens1370 alsa_cards_ens1371 alsa_cards_es1938 alsa_cards_es1968 alsa_cards_fm801 alsa_cards_hda-intel alsa_cards_intel8x0 alsa_cards_intel8x0m alsa_cards_maestro3 alsa_cards_trident alsa_cards_usb-audio alsa_cards_via82xx alsa_cards_via82xx-modem alsa_cards_ymfpci amd64 android apache2_modules_actions apache2_modules_alias apache2_modules_auth_basic apache2_modules_authn_alias apache2_modules_authn_anon apache2_modules_authn_core apache2_modules_authn_dbm apache2_modules_authn_default apache2_modules_authn_file apache2_modules_authz_core apache2_modules_authz_dbm apache2_modules_authz_default apache2_modules_authz_groupfile apache2_modules_authz_host apache2_modules_authz_owner apache2_modules_authz_user apache2_modules_autoindex apache2_modules_cache apache2_modules_cgi apache2_modules_cgid apache2_modules_dav apache2_modules_dav_fs apache2_modules_dav_lock apache2_modules_deflate apache2_modules_dir apache2_modules_disk_cache apache2_modules_env apache2_modules_expires apache2_modules_ext_filter apache2_modules_file_cache apache2_modules_filter apache2_modules_headers apache2_modules_include apache2_modules_info apache2_modules_log_config apache2_modules_logio apache2_modules_mem_cache apache2_modules_mime apache2_modules_mime_magic apache2_modules_negotiation apache2_modules_rewrite apache2_modules_setenvif apache2_modules_socache_shmcb apache2_modules_speling apache2_modules_status apache2_modules_unique_id apache2_modules_unixd apache2_modules_userdir apache2_modules_usertrack apache2_modules_vhost_alias apng atmo autoipd avahi bash-completion berkdb bindist bitforce bluetooth bluray branding btrfs bzip2 c++0x cairo calligra_features_author calligra_features_braindump calligra_features_flow calligra_features_karbon calligra_features_kexi calligra_features_krita calligra_features_plan calligra_features_sheets calligra_features_stage calligra_features_tables calligra_features_words cameras_ptp2 cdda cddb cdr cgi cli cmake collectd_plugins_df collectd_plugins_interface collectd_plugins_irq collectd_plugins_load collectd_plugins_memory collectd_plugins_rrdtool collectd_plugins_swap collectd_plugins_syslog consolekit cracklib crypt cryptsetup cups cxx dbus declarative dirac dot dri dts dvd dvdr elibc_glibc emboss encode exif fam fat firefox flac fontconfig fortran gd gdbm gif gimp git gles gles1 gles2 glew gpm gpsd_protocols_aivdm gpsd_protocols_ashtech gpsd_protocols_earthmate gpsd_protocols_evermore gpsd_protocols_fv18 gpsd_protocols_garmin gpsd_protocols_garmintxt gpsd_protocols_gpsclock gpsd_protocols_itrax gpsd_protocols_mtk3301 gpsd_protocols_navcom gpsd_protocols_nmea gpsd_protocols_ntrip gpsd_protocols_oceanserver gpsd_protocols_oldstyle gpsd_protocols_oncore gpsd_protocols_rtcm104v2 gpsd_protocols_rtcm104v3 gpsd_protocols_sirf gpsd_protocols_superstar2 gpsd_protocols_timing gpsd_protocols_tnt gpsd_protocols_tripmate gpsd_protocols_tsip gpsd_protocols_ublox gpsd_protocols_ubx gtk gudev hfs hwdb iconv icu input_devices_evdev input_devices_keyboard input_devices_mouse ipv6 java jpeg jpeg2k kate kde kerberos kernel_linux kipi lcd_devices_bayrad lcd_devices_cfontz lcd_devices_cfontz633 lcd_devices_glk lcd_devices_hd44780 lcd_devices_lb216 lcd_devices_lcdm001 lcd_devices_mtxorb lcd_devices_ncurses lcd_devices_text lcms ldap libass libnotify libreoffice_extensions_presenter-console libreoffice_extensions_presenter-minimizer libsamplerate mad mdadm mdnsresponder-compat minizip mmx mng modules mp3 mp4 mpeg mtp mudflap multilib multimedia musepack ncurses nfsv41 nls nptl nsplugin ntfs ocr office_implementation_libreoffice ogg okteta openal opengl openmp pam pango pcre pdf pdo perl phonon php_targets_php5-5 plasma png policykit postgres postscript ppds pulseaudio python python_single_target_python2_7 python_targets_python2_7 python_targets_python3_3 qml qt3support qt4 qthelp rar rbd rdesktop readline
			USE_EXPAND: ABI_MIPS ABI_X86 ALSA_CARDS APACHE2_MODULES APACHE2_MPMS CALLIGRA_FEATURES CAMERAS COLLECTD_PLUGINS CROSSCOMPILE_OPTS CURL_SSL DRACUT_MODULES DVB_CARDS ELIBC ENLIGHTENMENT_MODULES FCDSL_CARDS FFTOOLS FOO2ZJS_DEVICES FRITZCAPI_CARDS GPSD_PROTOCOLS GRUB_PLATFORMS INPUT_DEVICES KERNEL LCD_DEVICES LIBREOFFICE_EXTENSIONS LINGUAS LIRC_DEVICES MONKEYD_PLUGINS NETBEANS_MODULES NGINX_MODULES_HTTP NGINX_MODULES_MAIL OFED_DRIVERS OFFICE_IMPLEMENTATION OPENMPI_FABRICS OPENMPI_OFED_FEATURES OPENMPI_RM PHP_TARGETS PYTHON_SINGLE_TARGET PYTHON_TARGETS QEMU_SOFTMMU_TARGETS QEMU_USER_TARGETS RUBY_TARGETS SANE_BACKENDS USERLAND VIDEO_CARDS VOICEMAIL_STORAGE XFCE_PLUGINS XTABLES_ADDONS
			USE_EXPAND_HIDDEN: ABI_MIPS CROSSCOMPILE_OPTS ELIBC KERNEL USERLAND
			USE_EXPAND_IMPLICIT: ARCH ELIBC KERNEL USERLAND
			USE_EXPAND_UNPREFIXED: ARCH
			USE_EXPAND_VALUES_ARCH: alpha amd64 amd64-fbsd amd64-linux arm arm-linux hppa hppa-hpux ia64 ia64-hpux ia64-linux m68k m68k-mint mips ppc ppc64 ppc64-linux ppc-aix ppc-macos ppc-openbsd s390 sh sparc sparc64-freebsd sparc64-solaris sparc-fbsd sparc-solaris x64-freebsd x64-macos x64-openbsd x64-solaris x86 x86-cygwin x86-fbsd x86-freebsd x86-interix x86-linux x86-macos x86-netbsd x86-openbsd x86-solaris x86-winnt
			USE_EXPAND_VALUES_ELIBC: AIX Cygwin Darwin FreeBSD glibc HPUX Interix mintlib musl NetBSD OpenBSD SunOS uclibc Winnt
			USE_EXPAND_VALUES_KERNEL: AIX Cygwin Darwin FreeBSD freemint HPUX Interix linux NetBSD OpenBSD SunOS Winnt
			USE_EXPAND_VALUES_USERLAND: BSD GNU
			VERSION: 0
			REPO: gentoo
			END

		@test_old_header = <<-END.gsub(/^\t{3}/, '').strip
			ACCEPT_KEYWORDS: amd64
			ACCEPT_LICENSE: *
			ACCEPT_PROPERTIES: *
			ACCEPT_RESTRICT: *
			CBUILD: x86_64-pc-linux-gnu
			CHOST: x86_64-pc-linux-gnu
			CONFIG_PROTECT: /etc /usr/share/gnupg/qualified.txt
			CONFIG_PROTECT_MASK: /etc/ca-certificates.conf /etc/env.d /etc/fonts/fonts.conf /etc/gconf /etc/gentoo-release /etc/sandbox.d /etc/terminfo
			FEATURES: assume-digests binpkg-logs buildpkg config-protect-if-modified distlocks ebuild-locks fixlafiles getbinpkg merge-sync news parallel-fetch preserve-libs protect-owned sandbox sfperms splitdebug strict unknown-features-warn unmerge-logs unmerge-orphans userfetch userpriv usersandbox usersync
			GENTOO_MIRRORS: http://gentoo.closest.myvwan.com/gentoo
			IUSE_IMPLICIT: prefix
			PACKAGES: 1110
			PROFILE: /var/lib/layman/nextoo/profiles/0.0.1/default/linux/amd64/desktop/kde
			TIMESTAMP: 1389611111
			USE: 1stclassmsg X a52 aac aacs abi_x86_64 acl acpi
			USE_EXPAND: ABI_MIPS ABI_X86 ALSA_CARDS APACHE2_MODULES APACHE2_MPMS CALLIGRA_FEATURES CAMERAS COLLECTD_PLUGINS CROSSCOMPILE_OPTS CURL_SSL DRACUT_MODULES DVB_CARDS ELIBC ENLIGHTENMENT_MODULES FCDSL_CARDS FFTOOLS FOO2ZJS_DEVICES FRITZCAPI_CARDS GPSD_PROTOCOLS GRUB_PLATFORMS INPUT_DEVICES KERNEL LCD_DEVICES LIBREOFFICE_EXTENSIONS LINGUAS LIRC_DEVICES MONKEYD_PLUGINS NETBEANS_MODULES NGINX_MODULES_HTTP NGINX_MODULES_MAIL OFED_DRIVERS OFFICE_IMPLEMENTATION OPENMPI_FABRICS OPENMPI_OFED_FEATURES OPENMPI_RM PHP_TARGETS PYTHON_SINGLE_TARGET PYTHON_TARGETS QEMU_SOFTMMU_TARGETS QEMU_USER_TARGETS RUBY_TARGETS SANE_BACKENDS USERLAND VIDEO_CARDS VOICEMAIL_STORAGE XFCE_PLUGINS XTABLES_ADDONS
			USE_EXPAND_HIDDEN: ABI_MIPS CROSSCOMPILE_OPTS ELIBC KERNEL USERLAND
			USE_EXPAND_IMPLICIT: ARCH ELIBC KERNEL USERLAND
			USE_EXPAND_UNPREFIXED: ARCH
			USE_EXPAND_VALUES_ARCH: alpha amd64 amd64-fbsd amd64-linux arm arm-linux hppa hppa-hpux ia64 ia64-hpux ia64-linux m68k m68k-mint mips ppc ppc64 ppc64-linux ppc-aix ppc-macos ppc-openbsd s390 sh sparc sparc64-freebsd sparc64-solaris sparc-fbsd sparc-solaris x64-freebsd x64-macos x64-openbsd x64-solaris x86 x86-cygwin x86-fbsd x86-freebsd x86-interix x86-linux x86-macos x86-netbsd x86-openbsd x86-solaris x86-winnt
			USE_EXPAND_VALUES_ELIBC: AIX Cygwin Darwin FreeBSD glibc HPUX Interix mintlib musl NetBSD OpenBSD SunOS uclibc Winnt
			USE_EXPAND_VALUES_KERNEL: AIX Cygwin Darwin FreeBSD freemint HPUX Interix linux NetBSD OpenBSD SunOS Winnt
			USE_EXPAND_VALUES_USERLAND: BSD GNU
			VERSION: 0
			REPO: gentoo
		END
			
		@uri_header = <<-END.gsub(/^\t{3}/, '').strip
			ACCEPT_KEYWORDS: amd64
			ACCEPT_LICENSE: *
			ACCEPT_PROPERTIES: *
			ACCEPT_RESTRICT: *
			CBUILD: x86_64-pc-linux-gnu
			CHOST: x86_64-pc-linux-gnu
			CONFIG_PROTECT: /etc /usr/share/gnupg/qualified.txt
			CONFIG_PROTECT_MASK: /etc/ca-certificates.conf /etc/env.d /etc/fonts/fonts.conf /etc/gconf /etc/gentoo-release /etc/sandbox.d /etc/terminfo
			FEATURES: assume-digests binpkg-logs buildpkg config-protect-if-modified distlocks ebuild-locks fixlafiles getbinpkg merge-sync news parallel-fetch preserve-libs protect-owned sandbox sfperms splitdebug strict unknown-features-warn unmerge-logs unmerge-orphans userfetch userpriv usersandbox usersync
			GENTOO_MIRRORS: http://gentoo.closest.myvwan.com/gentoo
			IUSE_IMPLICIT: prefix
			PACKAGES: 1110
			PROFILE: /var/lib/layman/nextoo/profiles/0.0.1/default/linux/amd64/desktop/kde
			TIMESTAMP: 1389646578
			USE: 1stclassmsg X a52 aac aacs abi_x86_64 acl acpi alsa alsa_cards_ali5451 alsa_cards_als4000 alsa_cards_atiixp alsa_cards_atiixp-modem alsa_cards_bt87x alsa_cards_ca0106 alsa_cards_cmipci alsa_cards_emu10k1x alsa_cards_ens1370 alsa_cards_ens1371 alsa_cards_es1938 alsa_cards_es1968 alsa_cards_fm801 alsa_cards_hda-intel alsa_cards_intel8x0 alsa_cards_intel8x0m alsa_cards_maestro3 alsa_cards_trident alsa_cards_usb-audio alsa_cards_via82xx alsa_cards_via82xx-modem alsa_cards_ymfpci amd64 android apache2_modules_actions apache2_modules_alias apache2_modules_auth_basic apache2_modules_authn_alias apache2_modules_authn_anon apache2_modules_authn_core apache2_modules_authn_dbm apache2_modules_authn_default apache2_modules_authn_file apache2_modules_authz_core apache2_modules_authz_dbm apache2_modules_authz_default apache2_modules_authz_groupfile apache2_modules_authz_host apache2_modules_authz_owner apache2_modules_authz_user apache2_modules_autoindex apache2_modules_cache apache2_modules_cgi apache2_modules_cgid apache2_modules_dav apache2_modules_dav_fs apache2_modules_dav_lock apache2_modules_deflate apache2_modules_dir apache2_modules_disk_cache apache2_modules_env apache2_modules_expires apache2_modules_ext_filter apache2_modules_file_cache apache2_modules_filter apache2_modules_headers apache2_modules_include apache2_modules_info apache2_modules_log_config apache2_modules_logio apache2_modules_mem_cache apache2_modules_mime apache2_modules_mime_magic apache2_modules_negotiation apache2_modules_rewrite apache2_modules_setenvif apache2_modules_socache_shmcb apache2_modules_speling apache2_modules_status apache2_modules_unique_id apache2_modules_unixd apache2_modules_userdir apache2_modules_usertrack apache2_modules_vhost_alias apng atmo autoipd avahi bash-completion berkdb bindist bitforce bluetooth bluray branding btrfs bzip2 c++0x cairo calligra_features_author calligra_features_braindump calligra_features_flow calligra_features_karbon calligra_features_kexi calligra_features_krita calligra_features_plan calligra_features_sheets calligra_features_stage calligra_features_tables calligra_features_words cameras_ptp2 cdda cddb cdr cgi cli cmake collectd_plugins_df collectd_plugins_interface collectd_plugins_irq collectd_plugins_load collectd_plugins_memory collectd_plugins_rrdtool collectd_plugins_swap collectd_plugins_syslog consolekit cracklib crypt cryptsetup cups cxx dbus declarative dirac dot dri dts dvd dvdr elibc_glibc emboss encode exif fam fat firefox flac fontconfig fortran gd gdbm gif gimp git gles gles1 gles2 glew gpm gpsd_protocols_aivdm gpsd_protocols_ashtech gpsd_protocols_earthmate gpsd_protocols_evermore gpsd_protocols_fv18 gpsd_protocols_garmin gpsd_protocols_garmintxt gpsd_protocols_gpsclock gpsd_protocols_itrax gpsd_protocols_mtk3301 gpsd_protocols_navcom gpsd_protocols_nmea gpsd_protocols_ntrip gpsd_protocols_oceanserver gpsd_protocols_oldstyle gpsd_protocols_oncore gpsd_protocols_rtcm104v2 gpsd_protocols_rtcm104v3 gpsd_protocols_sirf gpsd_protocols_superstar2 gpsd_protocols_timing gpsd_protocols_tnt gpsd_protocols_tripmate gpsd_protocols_tsip gpsd_protocols_ublox gpsd_protocols_ubx gtk gudev hfs hwdb iconv icu input_devices_evdev input_devices_keyboard input_devices_mouse ipv6 java jpeg jpeg2k kate kde kerberos kernel_linux kipi lcd_devices_bayrad lcd_devices_cfontz lcd_devices_cfontz633 lcd_devices_glk lcd_devices_hd44780 lcd_devices_lb216 lcd_devices_lcdm001 lcd_devices_mtxorb lcd_devices_ncurses lcd_devices_text lcms ldap libass libnotify libreoffice_extensions_presenter-console libreoffice_extensions_presenter-minimizer libsamplerate mad mdadm mdnsresponder-compat minizip mmx mng modules mp3 mp4 mpeg mtp mudflap multilib multimedia musepack ncurses nfsv41 nls nptl nsplugin ntfs ocr office_implementation_libreoffice ogg okteta openal opengl openmp pam pango pcre pdf pdo perl phonon php_targets_php5-5 plasma png policykit postgres postscript ppds pulseaudio python python_single_target_python2_7 python_targets_python2_7 python_targets_python3_3 qml qt3support qt4 qthelp rar rbd rdesktop readline
			USE_EXPAND: ABI_MIPS ABI_X86 ALSA_CARDS APACHE2_MODULES APACHE2_MPMS CALLIGRA_FEATURES CAMERAS COLLECTD_PLUGINS CROSSCOMPILE_OPTS CURL_SSL DRACUT_MODULES DVB_CARDS ELIBC ENLIGHTENMENT_MODULES FCDSL_CARDS FFTOOLS FOO2ZJS_DEVICES FRITZCAPI_CARDS GPSD_PROTOCOLS GRUB_PLATFORMS INPUT_DEVICES KERNEL LCD_DEVICES LIBREOFFICE_EXTENSIONS LINGUAS LIRC_DEVICES MONKEYD_PLUGINS NETBEANS_MODULES NGINX_MODULES_HTTP NGINX_MODULES_MAIL OFED_DRIVERS OFFICE_IMPLEMENTATION OPENMPI_FABRICS OPENMPI_OFED_FEATURES OPENMPI_RM PHP_TARGETS PYTHON_SINGLE_TARGET PYTHON_TARGETS QEMU_SOFTMMU_TARGETS QEMU_USER_TARGETS RUBY_TARGETS SANE_BACKENDS USERLAND VIDEO_CARDS VOICEMAIL_STORAGE XFCE_PLUGINS XTABLES_ADDONS
			USE_EXPAND_HIDDEN: ABI_MIPS CROSSCOMPILE_OPTS ELIBC KERNEL USERLAND
			USE_EXPAND_IMPLICIT: ARCH ELIBC KERNEL USERLAND
			USE_EXPAND_UNPREFIXED: ARCH
			USE_EXPAND_VALUES_ARCH: alpha amd64 amd64-fbsd amd64-linux arm arm-linux hppa hppa-hpux ia64 ia64-hpux ia64-linux m68k m68k-mint mips ppc ppc64 ppc64-linux ppc-aix ppc-macos ppc-openbsd s390 sh sparc sparc64-freebsd sparc64-solaris sparc-fbsd sparc-solaris x64-freebsd x64-macos x64-openbsd x64-solaris x86 x86-cygwin x86-fbsd x86-freebsd x86-interix x86-linux x86-macos x86-netbsd x86-openbsd x86-solaris x86-winnt
			USE_EXPAND_VALUES_ELIBC: AIX Cygwin Darwin FreeBSD glibc HPUX Interix mintlib musl NetBSD OpenBSD SunOS uclibc Winnt
			USE_EXPAND_VALUES_KERNEL: AIX Cygwin Darwin FreeBSD freemint HPUX Interix linux NetBSD OpenBSD SunOS Winnt
			USE_EXPAND_VALUES_USERLAND: BSD GNU
			VERSION: 0
			REPO: gentoo
			URI: file:///build/nextoo/awesome.package
			END
		
		@app_admin_eselect_blas_string = <<-END.gsub(/^\t{3}/, '').strip
			BUILD_TIME: 1382864482
			CPV: app-admin/eselect-blas-0.1
			DEFINED_PHASES: install
			DEPEND: >=app-admin/eselect-1.0.5
			DESC: BLAS module for eselect
			KEYWORDS: alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sparc x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris
			LICENSE: GPL-2
			MD5: 111a8d143dc1c066e8eb8eb3331cc0bb
			MTIME: 1382864482
			RDEPEND: >=app-admin/eselect-1.0.5
			SHA1: 11df7cdbf95fb79ee99d8a9a430adbc5fd61a6d7
			SIZE: 7140
			END
		
		@app_admin_eselect_blas_name = "app-admin/eselect-blas-0.1"
		
		@app_admin_eselect_fontconfig_string = <<-END.gsub(/^\t{3}/, '').strip
			BUILD_TIME: 1382862068
			CPV: app-admin/eselect-fontconfig-1.1
			DEFINED_PHASES: install
			DESC: An eselect module to manage /etc/fonts/conf.d symlinks.
			KEYWORDS: ~alpha amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris
			LICENSE: GPL-2
			MD5: a541bf375d7a516e1c2dec824fa32522
			MTIME: 1382862068
			RDEPEND: >=app-admin/eselect-1.2.3 >=media-libs/fontconfig-2.4
			SHA1: edaaddaac583a31e7cf267cf77999b30bb7c2157
			SIZE: 7336
			END
		
		@app_admin_eselect_fontconfig_name = "app-admin/eselect-fontconfig-1.1"
		
		@app_admin_eselect_lib_bin_symlink_string = <<-END.gsub(/^\t{3}/, '').strip
			BUILD_TIME: 1389616920
			CPV: app-admin/eselect-lib-bin-symlink-0.1.1
			DEFINED_PHASES: compile configure install prepare test
			DESC: An eselect library to manage executable symlinks
			EAPI: 5
			KEYWORDS: alpha amd64 arm hppa ia64 ~m68k ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris
			LICENSE: GPL-2
			MD5: 722df5a8805f74539fbe7e5b75d1d828
			MTIME: 1389616921
			RDEPEND: app-admin/eselect
			SHA1: 5dd4fa761792fcffb1f34839cc5b55fc822d8407
			SIZE: 29258
			END
		
		@app_admin_eselect_lib_bin_symlink_name = "app-admin/eselect-lib-bin-symlink-0.1.1"
		
		@app_admin_eselect_mesa_string = <<-END.gsub(/^\t{3}/, '').strip
			BUILD_TIME: 1382861499
			CPV: app-admin/eselect-mesa-0.0.10
			DEFINED_PHASES: install postinst
			DESC: Utility to change the Mesa OpenGL driver being used
			EAPI: 3
			KEYWORDS: alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~arm-linux ~x86-linux ~sparc-solaris ~x86-solaris
			LICENSE: GPL-2
			MD5: 86d84078feb5bf03a15af3f73d22ca17
			MTIME: 1382861498
			RDEPEND: >=app-admin/eselect-1.2.4 >=app-shells/bash-4
			SHA1: 2fb9a3c40f672f126b447d516fb480849b57791e
			SIZE: 7591
			END
			
		@app_admin_eselect_mpg123_string = <<-END.gsub(/^\t{3}/, '').strip
			BUILD_TIME: 1389339846
			CPV: app-admin/eselect-mpg123-0.1
			DEFINED_PHASES: install
			DEPEND: >=app-admin/eselect-lib-bin-symlink-0.1.1 !<media-sound/mpg123-1.14.4-r1
			DESC: Manage /usr/bin/mpg123 symlink
			EAPI: 5
			KEYWORDS: alpha amd64 arm hppa ia64 ~mips ppc ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos
			LICENSE: GPL-2
			MD5: 6423facdfe61bf0468a6c60ff8d076a0
			MTIME: 1389339846
			RDEPEND: >=app-admin/eselect-lib-bin-symlink-0.1.1 !<media-sound/mpg123-1.14.4-r1
			SHA1: 1ef5159a2ad8d453df1af0390e5503d359f14e1a
			SIZE: 6880
			END
			
		@mini_manifest = @test_old_header + "\n\n" + @app_admin_eselect_blas_string + "\n\n" + @app_admin_eselect_fontconfig_string + "\n\n" + @app_admin_eselect_lib_bin_symlink_string
		@mini_manifest_count = 3
		
		@mini_manifest_b = @test_new_header + "\n\n" + @app_admin_eselect_mesa_string + "\n\n" + @app_admin_eselect_mpg123_string + "\n\n" + @app_admin_eselect_lib_bin_symlink_string
		
		@mini_manifest_merged = @test_new_header + "\n\n" + @app_admin_eselect_blas_string + "\n\n" + @app_admin_eselect_fontconfig_string + "\n\n" + @app_admin_eselect_lib_bin_symlink_string + "\n\n" + @app_admin_eselect_mesa_string + "\n\n" + @app_admin_eselect_mpg123_string
		@mini_manifest_merged_with_old_header = @test_old_header + "\n\n" + @app_admin_eselect_blas_string + "\n\n" + @app_admin_eselect_fontconfig_string + "\n\n" + @app_admin_eselect_lib_bin_symlink_string + "\n\n" + @app_admin_eselect_mesa_string + "\n\n" + @app_admin_eselect_mpg123_string
	end
	
	###########################################################################
	# Package Tests
	###########################################################################
	
	def test_that_package_can_be_retrieved_as_string
		package = Package.new(@app_admin_eselect_blas_string)
		assert_equal @app_admin_eselect_blas_string, package.to_s
	end
	
	def test_that_name_can_be_accessed
		package = Package.new(@app_admin_eselect_blas_string)
		assert_equal @app_admin_eselect_blas_name, package.name
	end
	
	def test_that_name_cannot_be_set
		package = Package.new(@app_admin_eselect_blas_string)
		assert_raises(NoMethodError) { package.name = "New Name" }
	end

	def test_that_empty_package_returns_empty_string
		package = Package.new ''
		assert_empty package.to_s
	end
	
	###########################################################################
	# Header Tests
	###########################################################################
	
	def test_that_header_can_be_retrieved_as_string
		header = Header.new(@test_new_header)
		assert_equal @test_new_header, header.to_s
	end

	def test_that_empty_header_returns_empty_string
		header = Header.new ''
		assert_empty header.to_s
	end
	
	###########################################################################
	# Manifest Tests
	###########################################################################
	
	def test_that_creating_a_manifest_counts_packages
		man = Manifest.new @mini_manifest
		assert_equal @mini_manifest_count, man.package_count
	end
	
	def test_that_file_contents_can_be_parsed_into_packages_hash
		man = Manifest.new @mini_manifest
		
		assert_equal @app_admin_eselect_blas_string, man.packages[@app_admin_eselect_blas_name].to_s
		assert_equal @app_admin_eselect_fontconfig_string, man.packages[@app_admin_eselect_fontconfig_name].to_s
		assert_equal @app_admin_eselect_lib_bin_symlink_string, man.packages[@app_admin_eselect_lib_bin_symlink_name].to_s
	end
	
	def test_that_a_manifest_can_be_return_string
		man = Manifest.new @mini_manifest
		assert_equal @mini_manifest, man.to_s
	end
	
	def test_that_manifests_can_be_merged
		man_a = Manifest.new @mini_manifest
		man_b = Manifest.new @mini_manifest_b
		
		man_a.merge_in(man_b)
		
		assert_equal @mini_manifest_merged, man_a.to_s
	end

	def test_that_the_old_manifest_header_can_be_kept
		man_a = Manifest.new @mini_manifest
		man_b = Manifest.new @mini_manifest_b

		man_a.merge_in(man_b, false)

		assert_equal @mini_manifest_merged_with_old_header, man_a.to_s
	end
	
	def test_setting_header_uri
		man = Manifest.new @test_new_header
		man.header.set_header_uri 'file:///build/nextoo/awesome.package'
		
		assert_equal @uri_header, man.to_s
	end
	
	def test_handle_empty_manifest
		empty_man = Manifest.new ''
		assert_equal '', empty_man.to_s
	end
		
end