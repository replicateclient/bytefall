# Bytefall Package Policy

Rule: if a default package cannot be justified in one sentence, it is not included.

## Base

| Package | Reason |
| --- | --- |
| base | Provides the minimal Arch userspace required for a bootable system. |
| linux-zen | Gives the desktop a responsive kernel tuned for interactive work. |
| linux-firmware | Supports modern CPU, GPU, Wi-Fi, Bluetooth, and storage devices. |
| intel-ucode | Provides CPU microcode updates for Intel systems. |
| amd-ucode | Provides CPU microcode updates for AMD systems. |
| systemd | Provides init, services, journald, timers, and system integration. |
| networkmanager | Gives consistent wired and wireless networking in live and installed systems. |
| sudo | Provides conventional privilege escalation for a developer workstation. |
| reflector | Keeps pacman mirrors fast and current. |
| pacman-contrib | Provides maintenance utilities such as `paccache`. |
| man-db | Provides local manual page indexing and lookup. |
| man-pages | Provides baseline Linux and POSIX manual documentation. |
| texinfo | Provides GNU info documentation support required by common base tooling. |

## Install And Boot

| Package | Reason |
| --- | --- |
| arch-install-scripts | Provides Arch installation utilities used by image and rescue workflows. |
| archinstall | Provides an official fallback installer while Bytefall Calamares packaging is still being finalized. |
| archiso | Provides Arch's profile tooling and live image support files for repeatable ISO creation. |
| mkinitcpio-archiso | Provides the live-boot mkinitcpio hooks required to find and mount the ISO root filesystem. |
| mkinitcpio-nfs-utils | Provides ipconfig and nfsmount helpers expected by archiso PXE/NFS hooks. |
| nbd | Provides nbd-client for archiso network block device boot hooks. |
| pv | Provides progress-copy support for archiso copy-to-RAM initramfs behavior. |
| grub | Provides broad BIOS and UEFI bootloader support. |
| syslinux | Provides BIOS boot support for the live ISO. |
| edk2-shell | Provides a UEFI shell on the live ISO for rescue and firmware diagnostics. |
| memtest86+ | Provides BIOS memory testing from the live ISO boot menu. |
| memtest86+-efi | Provides UEFI memory testing from the live ISO boot menu. |
| efibootmgr | Lets the installer manage UEFI boot entries. |
| dosfstools | Formats EFI system partitions. |
| mtools | Supports FAT image manipulation during ISO creation. |
| cryptsetup | Enables optional LUKS encryption. |
| lvm2 | Supports LVM-based installation layouts. |
| btrfs-progs | Supports Btrfs installation layouts and snapshots later. |
| xfsprogs | Supports XFS installation targets. |
| e2fsprogs | Supports ext4 installation targets. |
| plymouth | Provides a clean branded boot splash. |
| parted | Provides reliable disk partition editing for installer workflows. |
| gparted | Provides a graphical partition editor in the live session for rescue and manual prep. |

## Desktop

| Package | Reason |
| --- | --- |
| plasma-meta | Provides the KDE Plasma desktop shell. |
| kde-system-meta | Provides core KDE system tools expected in a Plasma workstation. |
| sddm | Provides a graphical login manager integrated with KDE. |
| konsole | Provides a KDE-native terminal for development workflows. |
| dolphin | Provides a KDE-native file manager. |
| ark | Provides archive management in the desktop. |
| spectacle | Provides screenshots and screen capture. |
| kate | Provides a fast KDE-native editor for code and config files. |
| kcalc | Provides a small everyday desktop utility without pulling a full office suite. |
| kvantum | Provides sharper Qt theme control across KDE and Qt apps. |
| kvantum-qt5 | Keeps Qt5 applications visually aligned with Bytefall. |
| breeze-gtk | Provides GTK compatibility with KDE theme settings. |
| materia-gtk-theme | Provides an additional sharp GTK theme base for non-KDE applications. |
| papirus-icon-theme | Provides a complete icon set that Bytefall can inherit while custom icons mature. |
| qt6-base | Provides the Qt runtime and build libraries for Bytefall's native custom apps. |
| qt6-declarative | Provides Qt Quick/QML runtime support for Bytefall's Kirigami-style welcome app. |
| kirigami | Provides KDE-native Qt Quick components for Bytefall's welcome app. |
| qqc2-desktop-style | Makes Qt Quick Controls follow the Plasma desktop style instead of generic fallback widgets. |
| xdg-desktop-portal-kde | Enables modern sandbox and file portal behavior in KDE. |
| powerdevil | Provides KDE power management for laptops and workstations. |
| plasma-nm | Provides NetworkManager integration in Plasma. |
| bluedevil | Provides Bluetooth controls in Plasma. |

## Lightweight Server Desktop

| Package | Reason |
| --- | --- |
| lxqt-session | Provides the lightweight graphical session used by the Server profile. |
| lxqt-panel | Provides a low-memory desktop panel for the Server profile. |
| lxqt-runner | Provides quick app launching without the full Plasma shell. |
| lxqt-config | Provides basic LXQt settings tools. |
| lxqt-qtplugin | Keeps Qt apps integrated in the LXQt session. |
| lxqt-policykit | Provides graphical privilege prompts in the LXQt session. |
| pcmanfm-qt | Provides a lightweight Qt file manager and desktop handler. |
| qterminal | Provides a lightweight Qt terminal for the Server profile. |
| openbox | Provides the window manager used by the LXQt Server session. |

## Developer Stack

| Package | Reason |
| --- | --- |
| git | Provides version control for nearly all development workflows. |
| curl | Provides scriptable HTTP downloads and API testing. |
| wget | Provides resilient command-line downloads. |
| openssh | Provides Git remotes, SSH login, and secure file transfer. |
| gcc | Provides the standard C/C++ compiler toolchain. |
| clang | Provides LLVM tooling and a second major compiler for diagnostics. |
| make | Provides the common build runner used by source packages. |
| cmake | Provides the common cross-platform build generator. |
| ninja | Provides fast incremental builds for CMake and other systems. |
| pkgconf | Provides dependency metadata lookup for native builds. |
| gdb | Provides native debugging. |
| strace | Provides Linux syscall tracing for debugging. |
| lldb | Provides LLVM-native debugging. |
| python | Provides scripting and modern development tooling. |
| python-pip | Provides Python package installation for isolated user workflows. |
| nodejs | Provides JavaScript and TypeScript runtime support. |
| npm | Provides Node package management. |
| rustup | Provides Rust toolchain management without pinning one Rust channel in the ISO. |
| go | Provides Go development support for infrastructure tooling. |
| docker | Provides container development support for the full workstation profile. |
| docker-compose | Provides multi-container development orchestration. |
| podman | Provides a daemonless container workflow alongside Docker-compatible tooling. |
| qemu-desktop | Provides local virtualization support for testing systems and bootable images. |
| virt-manager | Provides a graphical virtual machine manager for ISO testing and development labs. |
| linux-zen-headers | Supports kernel module builds and DKMS-style developer workflows on the shipped kernel. |
| base-devel | Provides the standard Arch build tool group for compiling packages and local tools. |
| jdk-openjdk | Provides Java development support for JVM projects and Android-adjacent tooling. |
| qtcreator | Provides a native IDE for Qt/KDE development, fitting Bytefall's Plasma base. |
| code | Provides a mainstream graphical code editor for developer workstation workflows. |
| neovim | Provides a modern terminal editor for keyboard-first development. |
| tmux | Provides persistent terminal sessions and multiplexing for development work. |
| wireshark-qt | Provides graphical network inspection for debugging local and distributed systems. |

## Fast System Utilities

| Package | Reason |
| --- | --- |
| fastfetch | Shows Bytefall system identity and hardware details quickly in the terminal. |
| starship | Provides a fast structured shell prompt foundation for developer workflows. |
| ripgrep | Provides fast project search. |
| fd | Provides fast file discovery. |
| fzf | Provides interactive fuzzy selection in shells. |
| bat | Provides readable file previews with syntax highlighting. |
| eza | Provides a modern `ls` replacement with better defaults. |
| btop | Provides a clear terminal system monitor. |
| htop | Provides a familiar lightweight process monitor. |
| tldr | Provides quick command examples when manual pages are too dense. |
| tree | Provides a simple visual directory listing for project inspection. |
| less | Provides reliable terminal paging for logs, docs, and command output. |
| which | Provides portable command path lookup used by scripts and users. |
| chafa | Lets fastfetch and terminal tools render image assets as text graphics. |
| usbutils | Provides USB hardware inspection tools for live-session troubleshooting. |
| pciutils | Provides PCI hardware inspection tools for driver and firmware checks. |
| inetutils | Provides common network diagnostics such as hostname and telnet-style tools. |
| jq | Provides structured JSON inspection in terminal workflows. |
| yq | Provides YAML/TOML/XML inspection in terminal workflows. |
| unzip | Extracts zip archives commonly used by releases and SDKs. |
| zip | Creates zip archives for distribution. |
| p7zip | Handles 7z archives and other compressed formats. |
| tar | Provides standard Unix archive handling. |
| rsync | Provides reliable local and remote file synchronization. |
| firefox | Provides a full browser for documentation, web development testing, and installer help links. |

## Build Host Only

| Package | Reason |
| --- | --- |
| squashfs-tools | Builds the compressed root filesystem during ISO generation. |
| xorriso | Creates the final hybrid ISO image. |

## Bytefall Custom Repository

| Package | Reason |
| --- | --- |
| calamares | Provides the graphical installer for Bytefall once packaged or supplied by a trusted Bytefall repository. |

## Fonts

| Package | Reason |
| --- | --- |
| ttf-jetbrains-mono | Provides Bytefall's monospace-first identity. |
| ttf-iosevka-nerd | Provides dense coding typography and glyph coverage. |
| noto-fonts | Provides broad UI language coverage. |
| noto-fonts-emoji | Provides emoji rendering when apps require it. |
| terminus-font | Provides the `ter-132n` console font requested by Bytefall's virtual console config. |
