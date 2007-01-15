AC_DEFUN([AC_PROG_CC_PIE], [
	AC_CACHE_CHECK([whether ${CC-cc} accepts -fPIE], ac_cv_prog_cc_pie, [
		echo 'void f(){}' > conftest.c
		if test -z "`${CC-cc} -fPIE -pie -c conftest.c 2>&1`"; then
			ac_cv_prog_cc_pie=yes
		else
			ac_cv_prog_cc_pie=no
		fi
		rm -rf conftest*
	])
])

AC_DEFUN([AC_FUNC_PPOLL], [
	AC_CHECK_FUNC(ppoll, dummy=yes, AC_DEFINE(NEED_PPOLL, 1, [Define to 1 if you need the ppoll() function.]))
])

AC_DEFUN([AC_INIT_BLUEZ], [
	AC_PREFIX_DEFAULT(/usr/local)

	if (test "${CFLAGS}" = ""); then
		CFLAGS="-Wall -O2"
	fi

	if (test "${prefix}" = "NONE"); then
		dnl no prefix and no sysconfdir, so default to /etc
		if (test "$sysconfdir" = '${prefix}/etc'); then
			AC_SUBST([sysconfdir], ['/etc'])
		fi

		dnl no prefix and no localstatedir, so default to /var
		if (test "$localstatedir" = '${prefix}/var'); then
			AC_SUBST([localstatedir], ['/var'])
		fi

		dnl no prefix and no libexecdir, so default to /lib
		if (test "$libexecdir" = '${exec_prefix}/libexec'); then
			AC_SUBST([libexecdir], ['/lib'])
		fi

		dnl no prefix and no mandir, so use ${prefix}/share/man as default
		if (test "$mandir" = '${prefix}/man'); then
			AC_SUBST([mandir], ['${prefix}/share/man'])
		fi

		prefix="${ac_default_prefix}"
	fi

	if (test "${libdir}" = '${exec_prefix}/lib'); then
		libdir="${prefix}/lib"
	fi

	if (test "$sysconfdir" = '${prefix}/etc'); then
		configdir="${prefix}/etc/bluetooth"
	else
		configdir="${sysconfdir}/bluetooth"
	fi

	if (test "$localstatedir" = '${prefix}/var'); then
		storagedir="${prefix}/var/lib/bluetooth"
	else
		storagedir="${localstatedir}/lib/bluetooth"
	fi

	AC_DEFINE_UNQUOTED(CONFIGDIR, "${configdir}", [Directory for the configuration files])
	AC_DEFINE_UNQUOTED(STORAGEDIR, "${storagedir}", [Directory for the storage files])
])

AC_DEFUN([AC_PATH_BLUEZ], [
	PKG_CHECK_MODULES(BLUEZ, bluez, dummy=yes, AC_MSG_ERROR(Bluetooth library is required))
	AC_SUBST(BLUEZ_CFLAGS)
	AC_SUBST(BLUEZ_LIBS)
])

AC_DEFUN([AC_PATH_DBUS], [
	PKG_CHECK_MODULES(DBUS, dbus-1 > 0.35, dummy=yes, AC_MSG_ERROR(dbus > 0.35 is required))
	PKG_CHECK_EXISTS(dbus-1 < 0.95, DBUS_CFLAGS="$DBUS_CFLAGS -DDBUS_API_SUBJECT_TO_CHANGE")
	AC_SUBST(DBUS_CFLAGS)
	AC_SUBST(DBUS_LIBS)
])

AC_DEFUN([AC_PATH_GLIB], [
	PKG_CHECK_MODULES(GLIB, glib-2.0, glib_found=yes, glib_found=no)
	AC_SUBST(GLIB_CFLAGS)
	AC_SUBST(GLIB_LIBS)
])

AC_DEFUN([AC_PATH_OPENOBEX], [
	PKG_CHECK_MODULES(OPENOBEX, openobex > 1.1, openobex_found=yes, openobex_found=no)
	AC_SUBST(OPENOBEX_CFLAGS)
	AC_SUBST(OPENOBEX_LIBS)
])

AC_DEFUN([AC_PATH_OPENSYNC], [
	PKG_CHECK_MODULES(OPENSYNC, glib-2.0 opensync-1.0 osengine-1.0, opensync_found=yes, opensync_found=no)
	AC_SUBST(OPENSYNC_CFLAGS)
	AC_SUBST(OPENSYNC_LIBS)
])

AC_DEFUN([AC_PATH_GSTREAMER], [
	PKG_CHECK_MODULES(GSTREAMER, gstreamer-0.10, gstreamer_found=yes, gstreamer_found=no)
	AC_SUBST(GSTREAMER_CFLAGS)
	AC_SUBST(GSTREAMER_LIBS)
])

AC_DEFUN([AC_PATH_ALSA], [
	PKG_CHECK_MODULES(ALSA, alsa, alsa_found=yes, alsa_found=no)
	AC_SUBST(ALSA_CFLAGS)
	AC_SUBST(ALSA_LIBS)
])

AC_DEFUN([AC_PATH_USB], [
	PKG_CHECK_MODULES(USB, libusb, usb_found=yes, usb_found=no)
	AC_SUBST(USB_CFLAGS)
	AC_SUBST(USB_LIBS)
	AC_CHECK_LIB(usb, usb_get_busses, dummy=yes,
		AC_DEFINE(NEED_USB_GET_BUSSES, 1, [Define to 1 if you need the usb_get_busses() function.]))
	AC_CHECK_LIB(usb, usb_interrupt_read, dummy=yes,
		AC_DEFINE(NEED_USB_INTERRUPT_READ, 1, [Define to 1 if you need the usb_interrupt_read() function.]))
])

AC_DEFUN([AC_PATH_EXPAT], [
	AC_CHECK_LIB(expat, XML_ParserCreate_MM, expat_found=yes, expat_found=no)
	AC_CHECK_HEADERS(expat.h, dummy=yes, expat_found=no)
])

AC_DEFUN([AC_PATH_INOTIFY], [
	AC_CHECK_LIB(c ,inotify_init, inotify_found=yes, inotify_found=no)
	AC_CHECK_HEADERS(sys/inotify.h, dummy=yes, inotify_found=no)
])

AC_DEFUN([AC_ARG_BLUEZ], [
	fortify_enable=yes
	debug_enable=no
	pie_enable=no
	inotify_enable=${inotify_found}
	expat_enable=${expat_found}
	glib_enable=no
	obex_enable=${openobex_found}
	sync_enable=${opensync_found}
	alsa_enable=no
	hcid_enable=yes
	sdpd_enable=no
	test_enable=no
	cups_enable=no
	configfiles_enable=yes
	initscripts_enable=no
	pcmciarules_enable=no
	bccmd_enable=no
	avctrl_enable=no
	hid2hci_enable=${usb_found}
	dfutool_enable=no

	AC_ARG_ENABLE(fortify, AC_HELP_STRING([--disable-fortify], [disable compile time buffer checks]), [
		fortify_enable=${enableval}
	])

	AC_ARG_ENABLE(debug, AC_HELP_STRING([--enable-debug], [enable compiling with debugging information]), [
		debug_enable=${enableval}
	])

	AC_ARG_ENABLE(pie, AC_HELP_STRING([--enable-pie], [enable position independent executables flag]), [
		pie_enable=${enableval}
	])

	AC_ARG_ENABLE(all, AC_HELP_STRING([--enable-all], [enable all extra options below]), [
		dbus_enable=${enableval}
		obex_enable=${enableval}
		alsa_enable=${enableval}
		hcid_enable=${enableval}
		sdpd_enable=${enableval}
		test_enable=${enableval}
		cups_enable=${enableval}
		configfiles_enable=${enableval}
		initscripts_enable=${enableval}
		pcmciarules_enable=${enableval}
		bccmd_enable=${enableval}
		avctrl_enable=${enableval}
		hid2hci_enable=${enableval}
		dfutool_enable=${enableval}
	])

	AC_ARG_ENABLE(inotify, AC_HELP_STRING([--enable-inotify], [enable inotify support]), [
		inotify_enable=${enableval}
	])

	AC_ARG_ENABLE(expat, AC_HELP_STRING([--enable-expat], [enable Expat support]), [
		expat_enable=${enableval}
	])

	AC_ARG_ENABLE(glib, AC_HELP_STRING([--enable-glib], [enable GLib support]), [
		glib_enable=${enableval}
	])

	AC_ARG_ENABLE(obex, AC_HELP_STRING([--enable-obex], [enable OBEX support]), [
		obex_enable=${enableval}
	])

	AC_ARG_ENABLE(sync, AC_HELP_STRING([--enable-sync], [enable SYNC support]), [
		sync_enable=${enableval}
	])

	AC_ARG_ENABLE(alsa, AC_HELP_STRING([--enable-alsa], [enable ALSA support]), [
		alsa_enable=${enableval}
	])

	AC_ARG_ENABLE(hcid, AC_HELP_STRING([--enable-hcid], [install HCI daemon]), [
		hcid_enable=${enableval}
	])

	AC_ARG_ENABLE(sdpd, AC_HELP_STRING([--enable-sdpd], [install SDP daemon]), [
		sdpd_enable=${enableval}
	])

	AC_ARG_ENABLE(test, AC_HELP_STRING([--enable-test], [install test programs]), [
		test_enable=${enableval}
	])

	AC_ARG_ENABLE(cups, AC_HELP_STRING([--enable-cups], [install CUPS backend support]), [
		cups_enable=${enableval}
	])

	AC_ARG_ENABLE(configfiles, AC_HELP_STRING([--enable-configfiles], [install Bluetooth config files]), [
		configfiles_enable=${enableval}
	])

	AC_ARG_ENABLE(initscripts, AC_HELP_STRING([--enable-initscripts], [install Bluetooth boot scripts]), [
		initscripts_enable=${enableval}
	])

	AC_ARG_ENABLE(pcmciarules, AC_HELP_STRING([--enable-pcmciarules], [install PCMCIA udev rules]), [
		pcmciarules_enable=${enableval}
	])

	AC_ARG_ENABLE(bccmd, AC_HELP_STRING([--enable-bccmd], [install BCCMD interface utility]), [
		bccmd_enable=${enableval}
	])

	AC_ARG_ENABLE(avctrl, AC_HELP_STRING([--enable-avctrl], [install Audio/Video control utility]), [
		avctrl_enable=${enableval}
	])

	AC_ARG_ENABLE(hid2hci, AC_HELP_STRING([--enable-hid2hci], [install HID mode switching utility]), [
		hid2hci_enable=${enableval}
	])

	AC_ARG_ENABLE(dfutool, AC_HELP_STRING([--enable-dfutool], [install DFU firmware upgrade utility]), [
		dfutool_enable=${enableval}
	])

	if (test "${fortify_enable}" = "yes"); then
		CFLAGS="$CFLAGS -D_FORTIFY_SOURCE=2"
	fi

	if (test "${debug_enable}" = "yes" && test "${ac_cv_prog_cc_g}" = "yes"); then
		CFLAGS="$CFLAGS -g"
	fi

	if (test "${pie_enable}" = "yes" && test "${ac_cv_prog_cc_pie}" = "yes"); then
		CFLAGS="$CFLAGS -fPIE"
		LDFLAGS="$LDFLAGS -pie"
	fi

	if (test "${glib_enable}" = "yes" && test "${glib_found}" = "yes"); then
		AC_DEFINE(HAVE_GLIB, 1, [Define to 1 if you have GLib support.])
	fi

	AM_CONDITIONAL(INOTIFY, test "${inotify_enable}" = "yes" && test "${inotify_found}" = "yes")
	AM_CONDITIONAL(EXPAT, test "${expat_enable}" = "yes" && test "${expat_found}" = "yes")
	AM_CONDITIONAL(GLIB, test "${glib_enable}" = "yes" && test "${glib_found}" = "yes")
	AM_CONDITIONAL(OBEX, test "${obex_enable}" = "yes" && test "${openobex_found}" = "yes")
	AM_CONDITIONAL(SYNC, test "${sync_enable}" = "yes" && test "${opensync_found}" = "yes")
	AM_CONDITIONAL(ALSA, test "${alsa_enable}" = "yes" && test "${alsa_found}" = "yes")
	AM_CONDITIONAL(HCID, test "${hcid_enable}" = "yes")
	AM_CONDITIONAL(SDPD, test "${sdpd_enable}" = "yes")
	AM_CONDITIONAL(TEST, test "${test_enable}" = "yes")
	AM_CONDITIONAL(CUPS, test "${cups_enable}" = "yes")
	AM_CONDITIONAL(CONFIGFILES, test "${configfiles_enable}" = "yes")
	AM_CONDITIONAL(INITSCRIPTS, test "${initscripts_enable}" = "yes")
	AM_CONDITIONAL(PCMCIARULES, test "${pcmciarules_enable}" = "yes")
	AM_CONDITIONAL(BCCMD, test "${bccmd_enable}" = "yes" && test "${usb_found}" = "yes")
	AM_CONDITIONAL(AVCTRL, test "${avctrl_enable}" = "yes" && test "${usb_found}" = "yes")
	AM_CONDITIONAL(HID2HCI, test "${hid2hci_enable}" = "yes" && test "${usb_found}" = "yes")
	AM_CONDITIONAL(DFUTOOL, test "${dfutool_enable}" = "yes" && test "${usb_found}" = "yes")
])
