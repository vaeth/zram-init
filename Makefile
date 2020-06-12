BUGADDR   = Martin V\"ath <martin@mvath.de>

EXENAME ?= zram-init

PREFIX      ?= /usr/local
SYSCONFDIR  ?= $(PREFIX)/etc
DESTDIR     ?=

BINDIR      ?= $(DESTDIR)$(PREFIX)/sbin
MODPROBEDIR ?= $(DESTDIR)$(SYSCONFDIR)/modprobe.d
MANDIR      ?= $(DESTDIR)$(PREFIX)/share/man
MANSUBDIR   ?= man8
MANI18NAPP  ?=
MODIR       ?= $(DESTDIR)$(PREFIX)/share/locale
MODIR_SED   ?= $(MODIR)
COMP_ZSHDIR ?= $(DESTDIR)$(PREFIX)/share/zsh/site-functions
SYSTEMDDIR  ?= $(DESTDIR)$(PREFIX)/lib/systemd/system
CONFDIR     ?= $(DESTDIR)$(SYSCONFDIR)/conf.d
INITDIR     ?= $(DESTDIR)$(SYSCONFDIR)/init.d

PO ?= i18n/de.po i18n/fr.po

MANI18N     ?= de fr

GETTEXT ?= TRUE
MODIFY_SHEBANG ?= TRUE
MODPROBED ?= TRUE
MANPAGE ?= TRUE
ZSH_COMPLETION ?= TRUE
SYSTEMD ?= TRUE
OPENRC ?= TRUE

INSTALL_EXE  ?= install -D --mode=755
INSTALL_DATA ?= install -D --mode=644
RM           ?= rm -f
MSGFMT       ?= msgfmt --check --statistics --verbose
FXGETTEXT    ?= --no-wrap
MSGMERGE     ?= msgmerge $(FXGETTEXT) --update --backup=existing --verbose
XGETTEXT     ?= xgettext $(FXGETTEXT) --from-code=UTF-8 --add-comments="TRANSLATION:" \
		--keyword="Echo" --flag="Echo:1:no-sh-format" --keyword="xEcho" \
		--keyword="xWarning" --keyword="Fatal" --flag="Fatal:1:no-sh-format" \
		--keyword="xFatal" --language=Shell --add-location=never \
		--copyright-holder="$(BUGADDR)" \
		--package-name="$(EXENAME)" --msgid-bugs-address="$(BUGADDR)"

.PHONY: all
ifeq ($(GETTEXT), TRUE)
all: $(PO:.po=.mo) sbin/$(EXENAME)
else
all: sbin/$(EXENAME)
endif

.PHONY: po
po: $(PO)

i18n/$(EXENAME).pot: sbin/$(EXENAME).in
	@echo 'Creating the Portable Object Template file: $@…'
	$(XGETTEXT) '$<' -o '$@'

i18n/%.po: i18n/$(EXENAME).pot
	@echo 'Merging the Portable Object Template file into $@…'
	$(MSGMERGE) '$@' '$<'

i18n/%.mo: i18n/%.po
	@echo 'Compiling the Portable Object file: $<…'
	$(MSGFMT) '$<' -o '$@'

sbin/$(EXENAME): sbin/$(EXENAME).in
	@echo 'Setting TEXTDOMAINDIR and TEXTDOMAIN variables'
	sed -e "s'@MODIR@'$(MODIR_SED)'g" -e "s'@EXENAME@'$(EXENAME)'g" \
		-- '$<' >'$@'
	chmod 755 -- '$@' || echo 'warn: chmod 755 $@ failed'
ifeq ($(MODIFY_SHEBANG), TRUE)
	@echo 'Modifying shebang…'
	sed -e "1s'"'^\#\!.*$$'"'$${SHEBANG:-#!`command -v sh 2>/dev/null`}'" \
		-i -- '$@'
endif

.PHONY: install
install: all
	@echo 'Installing the executable…'
	$(INSTALL_EXE) 'sbin/$(EXENAME)' '$(BINDIR)/$(EXENAME)'
ifeq ($(MODPROBED), TRUE)
	@echo 'Installing the modprobe.d file…'
	$(INSTALL_DATA) modprobe.d/zram.conf '$(MODPROBEDIR)/zram.conf'
endif
ifeq ($(MANPAGE), TRUE)
	@echo 'Installing the man pages…'
	$(INSTALL_DATA) 'man/$(EXENAME).8' '$(MANDIR)/$(MANSUBDIR)/$(EXENAME).8'
	for i in $(MANI18N); do \
		! test -r 'man/$(EXENAME).$$i.8' || \
			$(INSTALL_DATA) 'man/$(EXENAME).$$i.8' \
		'$(MANDIR)/$$i$(MANI18NAPP)/$(MANSUBDIR)/$(EXENAME).8' ; \
	done
endif
ifeq ($(GETTEXT), TRUE)
	@echo 'Installing the Machine Object files…'
	for i in $(notdir $(basename $(PO))); do \
		$(INSTALL_DATA) "i18n/$$i.mo" "$(MODIR)/$$i/LC_MESSAGES/$(EXENAME).mo"; \
	done
endif
ifeq ($(ZSH_COMPLETION), TRUE)
	@echo 'Installing the completion files…'
	$(INSTALL_DATA) 'zsh/_$(EXENAME)' '$(COMP_ZSHDIR)/_$(EXENAME)'
endif
ifeq ($(SYSTEMD), TRUE)
	@echo 'Installing the systemd service files…'
	$(INSTALL_DATA) systemd/system/zram_btrfs.service '$(SYSTEMDDIR)/zram_btrfs.service'
	$(INSTALL_DATA) systemd/system/zram_swap.service '$(SYSTEMDDIR)/zram_swap.service'
	$(INSTALL_DATA) systemd/system/zram_tmp.service '$(SYSTEMDDIR)/zram_tmp.service'
	$(INSTALL_DATA) systemd/system/zram_var_tmp.service '$(SYSTEMDDIR)/zram_var_tmp.service'
endif
ifeq ($(OPENRC), TRUE)
	@echo 'Installing the OpenRC files…'
	$(INSTALL_DATA) 'openrc/conf.d/$(EXENAME)' '$(CONFDIR)/$(EXENAME)'
	$(INSTALL_EXE) 'openrc/init.d/$(EXENAME)' '$(INITDIR)/$(EXENAME)'
endif

.PHONY: uninstall
uninstall:
	@echo 'Uninstalling the executable…'
	$(RM) '$(BINDIR)/$(EXENAME)'
ifeq ($(MODPROBED), TRUE)
	@echo 'Uninstalling the modprobe.d file…'
	$(RM) '$(MODPROBEDIR)/zram.conf'
endif
ifeq ($(MANPAGE), TRUE)
	@echo 'Uninstalling the man page…'
	$(RM) '$(MANDIR)/$(EXENAME).8'
endif
ifeq ($(GETTEXT), TRUE)
	@echo 'Uninstalling the Machine Object files…'
	for i in $(notdir $(basename $(PO))); do \
		$(RM) '$(MODIR)/$$i/LC_MESSAGES/$(EXENAME).mo'; \
	done
endif
ifeq ($(ZSH_COMPLETION), TRUE)
	@echo 'Uninstalling the completion files…'
	$(RM) '$(COMP_ZSHDIR)/_$(EXENAME)'
endif
ifeq ($(SYSTEMD), TRUE)
	@echo 'Uninstalling the systemd service files…'
	$(RM) '$(SYSTEMDDIR)/zram_btrfs.service'
	$(RM) '$(SYSTEMDDIR)/zram_swap.service'
	$(RM) '$(SYSTEMDDIR)/zram_tmp.service'
	$(RM) '$(SYSTEMDDIR)/zram_var_tmp.service'
endif
ifeq ($(OPENRC), TRUE)
	@echo 'Uninstalling the OpenRC files…'
	$(RM) '$(CONFDIR)/$(EXENAME)'
	$(RM) '$(INITDIR)/$(EXENAME)'
endif

.PHONY: clean
clean:
	@echo 'Deleting the executable…'
	$(RM) sbin/$(EXENAME)
	@echo 'Deleting all Machine Object files…'
	$(RM) i18n/*.mo
	@echo 'Deleting all Portable Object backups…'
	$(RM) i18n/*.po~

.PHONY: mrproper
mrproper: clean
	@echo 'Deleting the Portable Object Template file…'
	$(RM) i18n/$(EXENAME).pot
	@echo 'Deleting archives and similar stuff…'
	$(RM) *.asc *.gz *.tar *.xz *.zip *.tar.*

.PHONY: distclean
distclean: mrproper

.PHONY: maintainer-clean
maintainer-clean: mrproper
