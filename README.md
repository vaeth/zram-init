# zram-init

A wrapper script for the zram kernel module with interactive and init support

(C) Martin Väth (martin at mvath.de).
Many thanks to all people in the `AUTHORS` file for contributing.
The license of this package is the GNU Public License GPL-2.

This is a small helper script to setup a zram device as swap or as a ramdisk.
Also a __zsh completion__ file and __openrc__ and __systemd__ init-scripts
are provided.

If `zramctl` (from __>=util-linux-2.26__) is available,
this is used by default.
Currently, this is not a dependency: a manual method is provided as a fallback.
The latter might be removed in a future release of this script.

If you want to use one of the options `-K` `-M` `-2` `-Z` to pass generic args,
you need `push.sh` (v2.0 or newer) in your `$PATH`, see
https://github.com/vaeth/push/

To install this script, just copy the content of `sbin` into root's `$PATH`.
To obtain support for __zsh completion__, copy the content of `zsh` to
zsh's `$fpath`.
For __openrc__ support, the content of openrc should go into `/etc`.
For __systemd__ support, the content of `systemd/system` should go into a
systemd unit directory (`pkg-config --variable=systemdsystemunitdir systemd`,
usually `/lib/systemd/system` or `/usr/lib/systemd/system`) and be modified
and enabled with `systemctl enable ...` for the desired setting.
(Or install locally, e.g. directly into `/etc/systemd/system`).
For systemd and optionally also for openrc the content of `modprobe.d`
should go into `/lib/modprobe.d` or `/etc/modprobe.d` and be modified
appropriately.

To use `LZ4` compression with zram your kernel needs to be compiled with
option:

`CONFIG_ZRAM_LZ4_COMPRESS=y`

For Gentoo, there is an ebuild in the main tree (older version)
and in the mv overlay (current version).
For Alpine Linux, a __zram-init__ package is available.
