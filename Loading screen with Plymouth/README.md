# Loading screen customization

Most of the themes can be found on ArchWiki, in AUR repository. You can download them with your package manager.

1. install plymouth package: `yay plymouth`
2. install your preferd loading screen theme: `yay plymouth-theme-<theme_name>`
3. set your theme: `plymouth-set-default-theme -R <theme_name>`
4. in `/etc/mkinitcpio.conf`, add `plymouth` to the `HOOKS`: `HOOKS=(... plymouth ...)`
5. in `/etc/plymouth/plymouthd.conf` add the following:
   ```
   [Daemon]
   ...
   ShowDelay=0
   ...
   ```
6. change `/etc/systemd/system/display-manager.service` file as following (I wrote only lines, that have to be added for plymouth service; some of the lines may already be added):
	```
	[Unit]
	...
	Conflicts=plymouth-quit.service
	After=plymouth-quit.service

	After=... plymouth-start.service ...
	OnFailure=plymouth-qui.service

	[Service]
	...
	ExecStartPre=-/usr/bin/plymouth deactivate
	ExecStartPost=-/usr/bin/sleep 30
	ExecStartPost=-/usr/bin/plymouth quit --retain-splash
	...
	```
7. in `/etc/default/grub` change kernel parameters: `GRUB_CMDLINE_LINUX_DEFAULT="... quiet splash"`
	- it's important that `quiet` is before any other
8. re-generate `grub.conf` file by following command: `grub-mkconfig -o /boot/grub/grub.cfg`

More configuration options can be found on ArchWiki: https://wiki.archlinux.org/title/plymouth.