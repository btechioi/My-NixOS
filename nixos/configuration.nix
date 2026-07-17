# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
#
# iNiR + Niri integration — mapped from Arch PKGBUILD depends (105 packages).
# The iNiR flake wraps most CLI tools into its own PATH via makeWrapper.
# System-level services and daemons are configured here as NixOS modules.
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # Niri compositor
    inputs.niri.nixosModules.niri

    # iNiR desktop shell
    inputs.inir.nixosModules.inir

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      inputs.self.overlays.additions
      inputs.self.overlays.modifications
    ];
    config.allowUnfree = true;
  };

  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
    };
    channel.enable = false;
  };

  # --- Niri compositor ---
  programs.niri.enable = true;

  # --- iNiR desktop shell ---
  programs.inir = {
    enable = true;
    service.compositor = "niri";
    extraPackages = [
      # iNiR shells out to niri msg — must match the compositor package
      pkgs.niri
      # Power profile control (iNiR quick toggle)
      pkgs.power-profiles-daemon
      # Fingerprint auth (lock screen)
      pkgs.fprintd
    ];
  };

  # FIXME: Set your hostname
  networking.hostName = "my-laptop";

  # FIXME: Replace with your username
  users.users.banumath = {
    initialPassword = "correcthorsebatterystaple";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s)
    ];
    extraGroups = [
      "wheel"
      "video" # brightnessctl, backlight
      "input" # ydotool, evdev
      "networkmanager"
      "audio" # PipeWire devices
      "power" # power-profiles-daemon
    ];
  };

  # --- SSH ---
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # =====================================================================
  # SERVICES (Arch PKGBUILD deps → NixOS module options)
  # =====================================================================

  # --- PipeWire audio (arch: pipewire pipewire-pulse pipewire-alsa wireplumber) ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  # --- NetworkManager (arch: networkmanager) ---
  networking.networkmanager.enable = true;

  # --- Bluetooth (arch: blueman) ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # --- Power profiles (arch: NONE — iNiR uses powerprofilesctl via D-Bus) ---
  # Replaces TLP. iNiR's quick toggles call `powerprofilesctl` to switch
  # between balanced/performance/power-saver on the fly.
  services.power-profiles-daemon.enable = true;

  # --- UPower (arch: upower) — battery info, thresholds ---
  services.upower.enable = true;

  # --- ZRAM — compressed RAM swap (best setting for 8GB laptop) ---
  # zstd gives best compression ratio with good speed on i5-7440HQ.
  # Size = RAM (8GB) gives up to 16GB effective before disk swap.
  zramSwap = {
    enable = true;
    memoryPercent = 100; # zram size = total RAM
    algorithm = "zstd";
    priority = 100; # use zram before any disk swap
  };

  # --- Geoclue (arch: geoclue) — location for weather widget ---
  services.geoclue2.enable = true;

  # --- Polkit (arch: polkit polkit-gnome) ---
  security.polkit.enable = true;

  # --- SDDM display manager (arch: sddm) ---
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # --- XDG portals (arch: xdg-desktop-portal xdg-desktop-portal-gtk xdg-desktop-portal-gnome) ---
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  # --- Fprintd (arch: fprintd) — fingerprint lock screen ---
  services.fprintd.enable = true;

  # --- GNOME Keyring (arch: gnome-keyring) ---
  services.gnome.gnome-keyring.enable = true;

  # =====================================================================
  # SYSTEM PACKAGES
  # Organized by the PKGBUILD dependency groups.
  # The iNiR flake wraps many of these into its own PATH, but system-wide
  # availability is needed for services, D-Bus calls, and non-iNiR usage.
  # =====================================================================
  environment.systemPackages = with pkgs; [
    # --- Core utilities (arch: bc coreutils curl wget git python ripgrep rsync jq) ---
    bc
    coreutils
    curl
    wget
    git
    python3
    ripgrep
    rsync
    jq

    # --- Clipboard (arch: wl-clipboard cliphist) ---
    wl-clipboard
    cliphist

    # --- Screenshots & recording (arch: grim slurp swappy wf-recorder) ---
    grim
    slurp
    swappy
    wf-recorder

    # --- OCR (arch: tesseract tesseract-data-eng) ---
    tesseract
    tesseract-data-eng

    # --- Image/video processing (arch: imagemagick ffmpeg) ---
    imagemagick
    ffmpeg

    # --- Audio CLI (arch: playerctl pavucontrol mpv mpv-mpris yt-dlp socat) ---
    playerctl
    pavucontrol
    mpv
    mpv-mpris
    yt-dlp
    socat

    # --- Night light (arch: wlsunset) ---
    wlsunset

    # --- Input simulation (arch: wtype ydotool) ---
    wtype
    ydotool

    # --- Xwayland (arch: xwayland-satellite) ---
    xwayland-satellite

    # --- Hardware control (arch: brightnessctl ddcutil) ---
    brightnessctl
    ddcutil

    # --- Idle & lock (arch: swayidle swaylock) ---
    swayidle
    swaylock

    # --- Terminal & shell (arch: kitty fish fuzzel starship eza gum) ---
    kitty
    fish
    fuzzel
    starship
    eza
    gum

    # --- File manager (arch: nautilus) ---
    nautilus

    # --- Notifications (arch: libnotify) ---
    libnotify

    # --- Desktop integration (arch: xdg-user-dirs xdg-utils) ---
    xdg-user-dirs
    xdg-utils

    # --- Calculator backend (arch: libqalculate) ---
    libqalculate

    # --- D-Bus tools (arch: socat — for YTMusic IPC) ---
    # socat already listed above

    # --- Login manager (arch: sddm) ---
    # sddm is a NixOS service, not a package — handled above

    # =====================================================================
    # QT6 / KDE INTEGRATION
    # Arch: qt6-base qt6-declarative qt6-svg qt6-wayland qt6-5compat
    #        qt6-imageformats qt6-multimedia qt6-multimedia-ffmpeg
    #        qt6-positioning qt6-quicktimeline qt6-sensors qt6-tools
    #        qt6-translations qt6-virtualkeyboard
    #        kirigami kdialog syntax-highlighting qt6ct kvantum
    #        plasma-integration plasma-browser-integration
    #        frameworkintegration kdecoration breeze-icons
    #        hicolor-icon-theme adwaita-icon-theme
    # The iNiR flake wraps Qt6/KDE libs into its own QML/QT paths.
    # System-level Qt integration (kvantum, qt6ct) is still needed.
    qt6ct
    kvantum

    # KDE dialog runner (arch: kdialog)
    kdialog

    # --- Theming fonts (arch: noto-fonts-emoji papirus-icon-theme) ---
    noto-fonts-emoji
    papirus-icon-theme

    # --- System fonts (arch: ttf-dejavu ttf-liberation ttf-roboto ttf-roboto-mono) ---
    dejavu_fonts
    liberation
    roboto
    roboto-mono

    # --- AUR-equivalent fonts (arch: ttf-material-symbols-variable-git — critical for UI icons) ---
    material-symbols

    # --- AUR-equivalent: darkly-bin (Material You Qt widget style) ---
    # Not in nixpkgs — if unavailable, iNiR falls back to kvantum styling
    # darkly or a suitable alternative can be added via an overlay

    # --- AUR-equivalent: capitaine-cursors (cursor theme) ---
    capitaine-cursors

    # --- AUR-equivalent: adw-gtk-theme (GTK theme for Material colors) ---
    adw-gtk3

    # --- AUR-equivalent: ttf-roboto-flex (default UI font) ---
    roboto-flex

    # --- AUR-equivalent: ttf-jetbrains-mono-nerd (monospace) ---
    jetbrains-mono
  ];

  # =====================================================================
  # SESSION ENVIRONMENT
  # =====================================================================
  environment.sessionVariables = {
    # Qt scaling — iNiR handles its own QML scaling
    QT_SCALE_FACTOR = "1";
    QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
    # Suppress noisy Qt/KF warnings (matches Arch systemd service)
    QT_LOGGING_RULES = "quickshell.dbus.properties=false;qt.qml.settings.warning=false;qt.core.qsettings.warning=false;kf.xmlgui=false;kf.coreaddons=false;kf.config.core=false;kf.iconthemes=false";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.11";
}
