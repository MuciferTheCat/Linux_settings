# Logitech Options for Linux

Basic setup for Logitech MX Master. For more config options, please visit https://wiki.archlinux.org/title/Logitech_MX_Master.

For proper operation, delay the start of service in `/usr/lib/systemd/system/logid.service`:

```
[Unit]
Description=Logitech Configuration Daemon
StartLimitIntervalSec=0
After=multi-user.target
Wants=multi-user.target

[Service]
Type=simple
ExecStart=/usr/bin/logid
ExecStartPre=/bin/sleep 10
User=root

[Install]
WantedBy=graphical.target
```

In case of still not working properly, restart logid service: `sudo systemctl restart logid`.