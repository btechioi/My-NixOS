# My-PC: Ivy Bridge i5-3470, HD 4000, 8GB RAM
# Desktop — no fingerprint, USB WiFi+BT, btrfs root
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.niri.nixosModules.niri
    inputs.inir.nixosModules.inir
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
      pkgs.niri
      pkgs.power-profiles-daemon
    ];
  };

  networking.hostName = "my-pc";

  users.users.banumath = {
    initialPassword = "correcthorsebatterystaple";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s)
    ];
    extraGroups = [
      "wheel"
      "video"
      "input"
      "networkmanager"
      "audio"
      "power"
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
  # SERVICES
  # =====================================================================

  # --- PipeWire ---
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- NetworkManager (USB WiFi uses rtl8xxxu kernel driver) ---
  networking.networkmanager = {
    enable = true;
    # Ensure WiFi is available
    wifi.backend = "wpa_supplicant";
  };

  # --- Bluetooth (USB dongle — Cambridge Silicon Radio) ---
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # --- Power profiles ---
  services.power-profiles-daemon.enable = true;

  # --- UPower ---
  services.upower.enable = true;

  # --- Geoclue ---
  services.geoclue2.enable = true;

  # --- Polkit ---
  security.polkit.enable = true;

  # --- SDDM ---
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # --- XDG portals ---
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  # --- GNOME Keyring ---
  services.gnome.gnome-keyring.enable = true;

  # --- ZRAM — 100% RAM, zstd, same as laptop ---
  zramSwap = {
    enable = true;
    memoryPercent = 100;
    algorithm = "zstd";
    priority = 100;
  };

  # =====================================================================
  # SYSTEM PACKAGES
  # =====================================================================
  environment.systemPackages = with pkgs; [
    # Core
    bc coreutils curl wget git python3 ripgrep rsync jq

    # Clipboard
    wl-clipboard cliphist

    # Screenshots & recording
    grim slurp swappy wf-recorder

    # OCR
    tesseract tesseract-data-eng

    # Media
    imagemagick ffmpeg playerctl pavucontrol mpv mpv-mpris yt-dlp socat

    # Wayland
    wlsunset wtype ydotool xwayland-satellite swayidle swaylock

    # Hardware
    brightnessctl ddcutil

    # Terminal/Shell
    kitty fish fuzzel starship eza gum

    # Files
    nautilus

    # Notifications
    libnotify

    # Desktop
    xdg-user-dirs xdg-utils libqalculate

    # Qt/KDE
    qt6ct kvantum kdialog

    # Fonts
    noto-fonts-emoji dejavu_fonts liberation roboto roboto-mono
    roboto-flex jetbrains-mono material-symbols

    # Icons/Cursors
    papirus-icon-theme capitaine-cursors adw-gtk3
  ];

  # =====================================================================
  # SESSION ENVIRONMENT
  # =====================================================================
  environment.sessionVariables = {
    QT_SCALE_FACTOR = "1";
    QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
    QT_LOGGING_RULES = "quickshell.dbus.properties=false;qt.qml.settings.warning=false;qt.core.qsettings.warning=false;kf.xmlgui=false;kf.coreaddons=false;kf.config.core=false;kf.iconthemes=false";
  };

  system.stateVersion = "25.11";
}
