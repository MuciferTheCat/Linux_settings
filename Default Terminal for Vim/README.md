# Setting the default terminal (or another app) for Vim (or any other app)

First, navigate to `/usr/share/applications/`. There are located most of the `.desktop` applications. In a text editor open `vim.desktop` file (or file of the program, you wish to change the default app). In the case of Vim: in the line 112 change from `Exec=vim %F` to `Exec=gnome-terminal -e "vim %F"` (I changed my default terminal to gnome terminal. Use any terminal you prefer). The next step is to set `Terminal=false` in line 113.

The numbers of lines refer to numbers of lines in my config file.