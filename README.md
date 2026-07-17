<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:00e1ff,100:0055ff&height=200&section=header&text=My-Nixos%20%7C%20Multi-Host%20NixOS%20Config&fontSize=40&fontAlignY=35&animation=fadeIn&fontColor=ffffff"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white&style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Home--Manager-master-62a0ea?logo=gnubash&logoColor=white&style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Compositor-Niri-FF6B6B?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Shell-iNiR-00e1ff?style=for-the-badge"/>
</p>

<p align="center">
  <b>Reproducible, declarative NixOS configurations for my multi-machine setup.</b><br/>
  <sub>NixOS unstable • Home Manager master • iNiR desktop shell • niri-flake</sub>
</p>

---

# 🖥️ Hosts

| Host | CPU | GPU | RAM | Storage | Use Case |
|------|-----|-----|-----|---------|----------|
| **my-laptop** | i5-7440HQ (Kaby Lake) | Intel HD 630 | 8GB | SSD | Daily driver, mobile |
| **my-pc** | i5-3470 (Ivy Bridge) | Intel HD 4000 | 8GB | 1TB HDD | Desktop, development |

---

# 📁 Structure

```
My-Nixos/
├── flake.nix                          # Entry point — both hosts + HM configs
├── flake.lock                         # Pinned inputs (2026-07-15)
├── hosts/
│   ├── my-laptop/
│   │   ├── configuration.nix          # System packages, services, hostname
│   │   ├── hardware-configuration.nix # Boot, filesystems, GPU, drivers
│   │   └── home.nix                   # User packages, iNiR keybinds, niri settings
│   └── my-pc/
│       ├── configuration.nix          # Desktop config — no fingerprint
│       ├── hardware-configuration.nix # btrfs root, USB WiFi+BT, NTFS data
│       └── home.nix                   # Same iNiR keybinds, same user
├── overlays/
│   └── default.nix                    # Custom package overlays
├── modules/
│   ├── nixos/
│   └── home-manager/
└── pkgs/
    └── default.nix                    # Custom packages
```

---

# ⚡ Flake Inputs

| Input | Source | Tracks |
|-------|--------|--------|
| `nixpkgs` | `github:nixos/nixpkgs` | `nixos-unstable` |
| `home-manager` | `github:nix-community/home-manager` | `master` |
| `niri` | `github:sodiboo/niri-flake` | Follows nixpkgs |
| `inir` | `github:snowarch/inir` | Follows nixpkgs |

---

# 🧩 What's Inside

### 🖱️ Desktop
- **iNiR** — full desktop shell (bar, panels, dock, notifications, wallpaper)
- **Niri** — Wayland tiling compositor with 75 default keybinds
- **SDDM** — Wayland session manager
- **PipeWire** — audio server with ALSA + PulseAudio support

### ⚙️ Services
<p>
<img src="https://img.shields.io/badge/NetworkManager-0099FF?logo=gnome&logoColor=white&style=flat"/>
<img src="https://img.shields.io/badge/Bluetooth-0082FC?logo=bluetooth&logoColor=white&style=flat"/>
<img src="https://img.shields.io/badge/Power_Profiles_DAEMON-4CAF50?style=flat"/>
<img src="https://img.shields.io/badge/ZRAM_(zstd)-FF9800?style=flat"/>
<img src="https://img.shields.io/badge/UPower-9C27B0?style=flat"/>
<img src="https://img.shields.io/badge/XDG_Portals-2196F3?style=flat"/>
<img src="https://img.shields.io/badge/Polkit-795548?style=flat"/>
<img src="https://img.shields.io/badge/GNOME_Keyring-4CAF50?logo=gnome&logoColor=white&style=flat"/>
</p>

### 📦 Packages (58 system-level)
<details>
<summary><b>Core & CLI</b></summary>

`bc` `coreutils` `curl` `wget` `git` `python3` `ripgrep` `rsync` `jq` `eza` `fuzzel` `gum`
</details>

<details>
<summary><b>Media & Screenshots</b></summary>

`ffmpeg` `imagemagick` `mpv` `mpv-mpris` `yt-dlp` `playerctl` `pavucontrol` `socat`
`grim` `slurp` `swappy` `wf-recorder` `wl-clipboard` `cliphist`
</details>

<details>
<summary><b>Wayland & Desktop</b></summary>

`kitty` `fish` `starship` `nautilus` `libnotify` `brightnessctl` `ddcutil`
`wlsunset` `wtype` `ydotool` `xwayland-satellite` `swayidle` `swaylock`
`xdg-user-dirs` `xdg-utils` `libqalculate` `tesseract`
</details>

<details>
<summary><b>Qt/KDE & Theming</b></summary>

`qt6ct` `kvantum` `kdialog` `papirus-icon-theme` `capitaine-cursors` `adw-gtk3`
</details>

<details>
<summary><b>Fonts</b></summary>

`noto-fonts-emoji` `dejavu_fonts` `liberation` `roboto` `roboto-mono`
`roboto-flex` `jetbrains-mono` `material-symbols`
</details>

### ⚡ System Tuning
- **ZRAM** — zstd compression at 100% of RAM, priority 100 (before disk swap)
- **power-profiles-daemon** — runtime CPU governor switching (not TLP)
- **btrfs** (my-pc) — CoW filesystem with subvol layout

---

# 🚀 Deploy

### Fresh install
```bash
git clone https://github.com/btechioi/My-Nixos.git
cd My-Nixos

# my-laptop
sudo nixos-rebuild switch --flake .#my-laptop
home-manager switch --flake .#banumath@my-laptop

# my-pc
sudo nixos-rebuild switch --flake .#my-pc
home-manager switch --flake .#banumath@my-pc
```

### Update
```bash
nix flake update
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#banumath@<hostname>
```

### Preview (without installing)
```bash
# Live USB preview
sudo nixos-rebuild test --flake .#my-laptop
```

---

# 🔧 Customization

### Add a new host
1. Create `hosts/<hostname>/` with `configuration.nix`, `hardware-configuration.nix`, `home.nix`
2. Add the host to `flake.nix` under `nixosConfigurations` and `homeConfigurations`
3. Run `nix flake lock` to resolve inputs

### Add a package
- **System-wide:** Add to `environment.systemPackages` in the host's `configuration.nix`
- **User-only:** Add to `home.packages` in the host's `home.nix`
- **Overlay:** Add to `overlays/default.nix` for global modifications

---

# 🏗️ Tech Stack

<p>
<img src="https://img.shields.io/badge/-NixOS-5277C3?logo=nixos&logoColor=white&style=for-the-badge"/>
<img src="https://img.shields.io/badge/-Niri-FF6B6B?logo=gnuicecat&logoColor=white&style=for-the-badge"/>
<img src="https://img.shields.io/badge/-Home--Manager-62a0ea?logo=gnubash&logoColor=white&style=for-the-badge"/>
<img src="https://img.shields.io/badge/-iNiR-00e1ff?style=for-the-badge"/>
<img src="https://img.shields.io/badge/-Flakes-FF9800?logo=nixos&logoColor=white&style=for-the-badge"/>
<img src="https://img.shields.io/badge/-Wayland-222?logo=linux&logoColor=white&style=for-the-badge"/>
<img src="https://img.shields.io/badge/-PipeWire-333?logo=pipewire&logoColor=white&style=for-the-badge"/>
</p>

---

# 📋 Hardware Details

### my-laptop
| Component | Model |
|-----------|-------|
| CPU | Intel Core i5-7440HQ @ 2.80GHz (Kaby Lake, 4C/4T) |
| GPU | Intel HD Graphics 630 |
| RAM | 8GB DDR4 |
| Display | 1366×768 (HD) |
| Boot | systemd-boot on vfat ESP |
| Root | ext4 on NVMe |
| WiFi | Intel Wireless (built-in) |
| BT | Intel Bluetooth (built-in) |
| Audio | HDA Intel PCH |

### my-pc
| Component | Model |
|-----------|-------|
| CPU | Intel Core i5-3470 @ 3.20GHz (Ivy Bridge, 4C/4T) |
| GPU | Intel HD Graphics 4000 |
| RAM | 8GB DDR3 |
| Boot | systemd-boot on vfat ESP (4GB) |
| Root | btrfs on SATA 1TB |
| Data | NTFS on SATA 465GB |
| WiFi | Realtek RTL8188FTV (USB, 2.4GHz) |
| BT | Cambridge Silicon Radio (USB dongle) |
| Audio | HDA Intel PCH |
| Keyboard | IBM NetVista |

---

# 🔥 Stats

<p align="left">
<img src="https://github-readme-stats.vercel.app/api/pin/?username=btechioi&repo=My-Nixos&theme=tokyonight&show_owner=true" alt="My-Nixos Stats" />
</p>

---

# 📫 Reach Out
📧 **Email:** [banumathhettiarachchi@gmail.com](mailto:banumathhettiarachchi@gmail.com)
🌐 **Tech Blog:** [btechioi.netlify.app](https://btechioi.netlify.app)

---
⭐ *"Simplicity is the ultimate sophistication." — NixOS.*
