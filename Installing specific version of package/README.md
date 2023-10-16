# Installing specific version of package

1. find the package on AUR
2. copy the `Git Clone URL`
3. open terminal
4. clone git repository on your computer: `git clone <repo_url>`
5. navigate to installed folder: `cd <repo_name>`
6. in version history `git log --oneline` find hash of the commit you wish to install
7. checkout the commit `git checkout <hash>`
8. build and install package: `makepkg -si` 


## Disable updating the package in next updates

If you don't want to update the installed package, change your `/etc/pacman.conf` file.

```
...
IgnorePkg = ... repo_name ...
...
```