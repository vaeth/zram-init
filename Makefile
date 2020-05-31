BUGADDR   = Martin V\"ath <martin@mvath.de>

EXENAME ?= zram-init
BINVER  ?= 9.1

PREFIX  ?= /usr/local
DESTDIR ?=

BINDIR      ?= $(DESTDIR)$(PREFIX)/sbin
MODPROBEDIR ?= $(DESTDIR)$(PREFIX)/etc/modprobe.d
MANDIR      ?= $(DESTDIR)$(PREFIX)/share/man/man8
MODIR       ?= $(DESTDIR)$(PREFIX)/share/locale
COMP_ZSHDIR ?= $(DESTDIR)$(PREFIX)/share/zsh/site-functions
SYSTEMDDIR  ?= $(DESTDIR)$(PREFIX)/lib/systemd/system
CONFDIR     ?= $(DESTDIR)$(PREFIX)/etc/conf.d
INITDIR     ?= $(DESTDIR)$(PREFIX)/etc/init.d

PO ?= i18n/fr.po

SYSTEMD ?= TRUE

INSTALL_EXE  ?= install -D --mode=755
INSTALL_DATA ?= install -D --mode=644
RM           ?= rm -f
MSGFMT       ?= msgfmt --check --statistics --verbose
FXGETTEXT    ?= --no-wrap
MSGMERGE     ?= msgmerge $(FXGETTEXT) --update --backup=existing --verbose
XGETTEXT     ?= xgettext $(FXGETTEXT) --from-code=UTF-8 --add-comments="TRANSLATION:" \
				--keyword="Echo" --flag="Echo:1:no-sh-format" --keyword="xEcho"       \
				--keyword="xWarning" --keyword="Fatal" --flag="Fatal:1:no-sh-format"  \
				--keyword="xFatal" --language=Shell --copyright-holder="$(BUGADDR)"   \
				--package-name="$(EXENAME)" --package-version=$(BINVER)               \
				--msgid-bugs-address="$(BUGADDR)"

.PHONY: all
all: $(PO:.po=.mo)

i18n/$(EXENAME).pot: sbin/$(EXENAME).in
	@echo "Creating the Portable Object Template file: $@…"
	$(XGETTEXT) $< -o $@

i18n/%.po: $(EXENAME).pot
	@echo "Merging the Portable Object Template file into $@…"
	$(MSGMERGE) $@ $<

i18n/%.mo: i18n/%.po
	@echo "Compiling the Portable Object file: $<…"
	$(MSGFMT) $< -o $@

.PHONY: install
install: all
	@echo "Installing the executable…"
	$(INSTALL_EXE) "sbin/$(EXENAME).in" "$(BINDIR)/$(EXENAME)"
	@echo "Setting TEXTDOMAINDIR and TEXTDOMAIN variables"
	sed -e "s:@MODIR@:$(MODIR):g" -e "s/@EXENAME@/$(EXENAME)/g" \
		-i "$(BINDIR)/$(EXENAME)"
	@echo "Installing the modprobe.d file…"
	$(INSTALL_DATA) modprobe.d/zram.conf "$(MODPROBEDIR)/zram.conf"
	@echo "Installing the man page…"
	$(INSTALL_DATA) "man/$(EXENAME).8" "$(MANDIR)/$(EXENAME).8"
	@echo "Installing the Machine Object files…"
	for i in $(notdir $(basename $(PO))); do \
		$(INSTALL_DATA) "i18n/$$i.mo" "$(MODIR)/$$i/LC_MESSAGES/$(EXENAME).mo"; \
	done
	@echo "Installing the completion files…"
	$(INSTALL_DATA) "zsh/_$(EXENAME)" "$(COMP_ZSHDIR)/_$(EXENAME)"

ifeq ($(SYSTEMD), TRUE)
	@echo "Installing the systemd service files…"
	$(INSTALL_DATA) systemd/system/zram_btrfs.service "$(SYSTEMDDIR)/zram_btrfs.service"
	$(INSTALL_DATA) systemd/system/zram_swap.service "$(SYSTEMDDIR)/zram_swap.service"
	$(INSTALL_DATA) systemd/system/zram_tmp.service "$(SYSTEMDDIR)/zram_tmp.service"
	$(INSTALL_DATA) systemd/system/zram_var_tmp.service "$(SYSTEMDDIR)/zram_var_tmp.service"
else
	@echo "Installing the OpenRC files…"
	$(INSTALL_DATA) "openrc/conf.d/$(EXENAME)" "$(CONFDIR)/$(EXENAME)"
	$(INSTALL_EXE) "openrc/init.d/$(EXENAME)" "$(INITDIR)/$(EXENAME)"
endif

.PHONY: uninstall
uninstall:
	@echo "Uninstalling the executable…"
	$(RM) "$(BINDIR)/$(EXENAME)"
	@echo "Uninstalling the modprobe.d file…"
	$(RM) "$(MODPROBEDIR)/zram.conf"
	@echo "Uninstalling the man page…"
	$(RM) "$(MANDIR)/$(EXENAME).8"
	@echo "Uninstalling the Machine Object files…"
	for i in $(notdir $(basename $(PO))); do \
		$(RM) "$(MODIR)/$$i/LC_MESSAGES/$(EXENAME).mo"; \
	done
	@echo "Uninstalling the completion files…"
	$(RM) "$(COMP_ZSHDIR)/_$(EXENAME)"

ifeq ($(SYSTEMD), TRUE)
	@echo "Uninstalling the systemd service files…"
	$(RM) "$(SYSTEMDDIR)/zram_btrfs.service"
	$(RM) "$(SYSTEMDDIR)/zram_swap.service"
	$(RM) "$(SYSTEMDDIR)/zram_tmp.service"
	$(RM) "$(SYSTEMDDIR)/zram_var_tmp.service"
else
	@echo "Uninstalling the OpenRC files…"
	$(RM) "$(CONFDIR)/$(EXENAME)"
	$(RM) "$(INITDIR)/$(EXENAME)"
endif

.PHONY: clean
clean:
	@echo "Deleting all Machine Object files…"
	$(RM) i18n/*.mo
	@echo "Deleting all Portable Object backups…"
	$(RM) i18n/*.po~

.PHONY: mrproper
mrproper: clean
	@echo "Deleting the Portable Object Template file…"
	$(RM) i18n/$(EXENAME).pot
