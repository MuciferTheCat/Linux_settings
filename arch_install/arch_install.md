# Guide for installing Arch (BTRFS, Hyprland)

## Preliminary steps

Set up keyboard layout:
```bash
localectl list-keymaps

loadkeys slovene
```

Connect to the internet:
```bash
iwectl

station wlan0 get-networks

station wlan0 connect SSID
```

Check the internet connection:
```bash
ping archlinux.org
```

## Main installation

### Disk partitioning

Make 3 partitions: 

- EFI
- Linux FileSystem
- Swap

```bash
fdisk /dev/nvme0n1

# new partition: EFI
n
# leave default partition number
ENTER
# leave default first sector
ENTER
# last sector
+1G

# new partition: Linux Filesystem
n
#leave default partition number
ENTER
#leave default first sector
ENTER
# last sector (substract swap partition size)
-32G

# new partition: swap
n
#leave default partition number
ENTER
# leave default first sector
ENTER
# leave default last sector
ENTER

# check partitions
p

# write changes
w

# quit
q
```

### Disk formatting

Format the newly created partitions:
```bash
#list partitions
fdisk -l

# format partitions
mkfs.fat -F 32 /dev/nvme0n1p<partition_number>
mkfs.btrfs /dev/nvme0n1p<partition_number>
mkswap /dev/nvme0n1p<partition_number>

# mount linux fs
mount /dev/nvme0n1p<btrfs_partition_number>
```

### Disk mounting

Make 6 subvolumes:

- @
- @home
- @.snapshots
- @var/log
- @var/cache
- @var/tmp

```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@.snapshots
btrfs subvolume create /mnt/@var/log
btrfs subvolume create /mnt/@var/cache
btrfs subvolume create /mnt/@var/tmp

umount /mnt
```

Mounting:
```bash
# mount newly created subvolumes
mount -o compress=zstd,subvol=@ /dev/nvme0n1p<btrfs_partition_number> /mnt
mkdir -p /mnt/home
mount -o compress=zstd,subvol=@home /dev/nvme0n1p<btrfs_partition_number> /mnt/home
mkdir -p /mnt/.snapshots
mount -o compress=zstd,subvol=@.snapshots /dev/nvme0n1p<btrfs_partition_number> /mnt/.snapshots
mkdir -p /mnt/var/log
mount -o compress=zstd,subvol=@var/log /dev/nvme0n1p<btrfs_partition_number> /mnt/var/log
mkdir -p /mnt/var/cache
mount -o compress=zstd,subvol=@var/cache /dev/nvme0n1p<btrfs_partition_number> /mnt/var/cache
mkdir -p /mnt/var/tmp
mount -o compress=zstd,subvol=@var/tmp /dev/nvme0n1p<btrfs_partition_number> /mnt/var/tmp

# mount efi partition
mkdir -p /mnt/efi
mount /dev/nvme0n1p<efi_partition_number> /mnt/efi
```

### Packages installation

Install following packages (probs gonna need them in the future):
```bash
pacstrap -K /mnt base base-devel linux linux-firmware git btrfs-progs grub efibootmgr grub-btrfs inotify-tools timeshift vim networkmanager pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber reflector zsh zsh-completions zsh-autosuggestions openssh man sudo
```

### Fstab

Generate the fstab file:
```bash
genfstab -U /mnt >> /mnt/etc/fstab

# check the fstab file
cat /mnt/etc/fstab
```

### Context switch to our new system

Access the new system:
```bash
arch-chroot /mnt
```

### Set up the time zone

```bash
ln -sf /usr/share/zoneinfo/Europe/Ljubljana /etc/localtime

# sync system time to the hardware clock
hwclock --systohc
```

### Set up language and tty keyboard map

Select preferred:
```bash
vim /etc/locale.gen

# uncomment: en_US.UTF-8 UTF-8, sl_SI.UTF-8 UTF-8

# Now issue the generation of the locales
locale-gen
```

Activate the locale:
```bash
touch /etc/locale.conf
vim /etc/locale.conf

# /etc/locale.conf
LANG=sl_SI.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_TIME=en_US.UTF-8
```

Make keyboard layout permanent:
```bash
vim /etc/vconsole.conf

# /etc/vconsole.conf
KEYMAP=slovene
```

### Hostname and Host configuration

```bash
# create /etc/hostname
touch /etc/hostname
vim /etc/hostanme

# /etc/hostname
<name_of_your_computer>

# create /etc/hosts
touch /etc/hosts
vim /etc/hosts

# /etc/hosts
127.0.0.1 localhost
::1 localhost
127.0.1.1 <name_of_your_computer>
```

### Root and users

```bash
# Add a new user
# -m creates the home dir automatically
# -G adds the user to an initial list of groups, in this case wheel, the administration group
useradd -mG wheel <username>
passwd <username>
```

```bash
# The command below is a one line command that will open the /etc/sudoers file with your favourite editor.
# You can choose a different editor than vim by changing the EDITOR variable
# Once opened, you have to look for a line which says something like "Uncomment to let members of group wheel execute any action"
# and uncomment exactly the line BELOW it, by removing the #. This will grant superuser priviledges to your user.
# Why are we issuing this command instead of a simple vim /etc/sudoers ? 
# Because visudo does more than opening the editor, for example it locks the file from being edited simultaneously and
# runs syntax checks to avoid committing an unreadable file.
EDITOR=vim visudo
```

### Grub configuration

Deploy grub:
```bash
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
```

Deploy grub configuration:
```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

### Unmount everything and reboot (and hope for the best)

```bash
# Enable newtork manager before rebooting otherwise, you won't be able to connect
systemctl enable NetworkManager

# Exit from chroot
exit

# Unmount everything to check if the drive is busy
umount -R /mnt

# Reboot the system and unplug the installation media
reboot

# log in with your user account

#enable and start the time synchronization service
timedatectl set-ntp true
```

### Automatic snapshots boot entries update

Add snapshot boot to the Grub menu:
```bash
sudo systemctl edit --full grub-btrfsd

# grub-btrfsd
ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto

sudo systemctl enable grub-btrfsd
```

### Aur helper (yay) and additional packages installation

Install yay:
```bash
# Install yay
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# Install "timeshift-autosnap", a configurable pacman hook which automatically makes snapshots before pacman upgrades.
yay -S timeshift-autosnap
```

### Finalization

Final reboot:
```bash
reboot
```

## Video drivers

### AMD

Install AMDGPU drivers:
```bash
# What are we installing ?
# mesa: DRI driver for 3D acceleration.
# xf86-video-amdgpu: DDX driver for 2D acceleration in Xorg. I won't install this, because I prefer the default kernel modesetting driver.
# vulkan-radeon: vulkan support.
# libva-mesa-driver: VA-API h/w video decoding support.
# mesa-vdpau: VDPAU h/w accelerated video decoding support.

sudo pacman -S mesa vulkan-radeon libva-mesa-driver mesa-vdpau
```

### Other GPU brands

Please follow `https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae#nvidia` for Nvidia card or `https://gist.github.com/mjkstra/96ce7a5689d753e7a6bdd92cdc169bae#intel` for Intel card.

## Setting up graphical environment

### Option 1: Hyprland

```bash
# Install hyprland from tagged releases and other utils:
# swaylock: the lockscreen (optional, works perfectly fine without it but you only have log out option)
# wofi: the wayland version of rofi, an application launcher, extremely configurable
# waybar: a status bar for wayland wm's
# dolphin: a powerful file manager from KDE applications
# alacritty: a beautiful and minimal terminal application, super configurable
pacman -S --needed hyprland swaylock wofi waybar dolphin alacritty

# wlogout: a logout/shutdown menu
yay -S wlogout
```