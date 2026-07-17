# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # inputs.self.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # Niri config module — generates ~/.config/niri/config.kdl from Nix options.
    # This is the HOME MANAGER side of niri config (keybinds, layout, window rules).
    # The NixOS module (in configuration.nix) handles the system package + service.
    inputs.niri.homeModules.config

    # NOTE: iNiR's HM module is NOT imported here because the NixOS module
    # (in configuration.nix) already handles the system package + service.
    # If you use Home Manager WITHOUT the NixOS module (standalone HM),
    # uncomment the line below and remove the inir NixOS module from configuration.nix:
    # inputs.inir.homeManagerModules.inir

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      inputs.self.overlays.additions
      inputs.self.overlays.modifications

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "banumath";
    homeDirectory = "/home/banumath";
  };

  # --- iNiR symlink for tools expecting traditional config path ---
  # This creates ~/.config/quickshell/inir -> the packaged Nix store path.
  # Enable if you use `inir setup`, `inir doctor`, or other tools that look
  # for the config at ~/.config/quickshell/inir. Disable if it conflicts with
  # a live git checkout at that path (e.g., during development).
  xdg.configFile."quickshell/inir".source =
    "${inputs.inir.packages.${pkgs.system}.default}/share/quickshell/inir";

  # --- User-level packages that complement iNiR ---
  home.packages = with pkgs; [
    # Terminal + shell (iNiR's default terminal and shell)
    kitty
    fish

    # Shell prompt
    starship

    # File manager
    nautilus

    # System monitor for iNiR's sidebar widget
    btop

    # YTMusic needs a JS runtime for yt-dlp anti-bot
    deno
  ];

  # --- Fish shell config (iNiR scripts require fish) ---
  programs.fish = {
    enable = true;
    shellInit = ''
      # iNiR launcher
      if not contains "$HOME/.local/bin" $PATH
        set -gx PATH "$HOME/.local/bin" $PATH
      end
    '';
    shellAbbrs = {
      inir-run = "inir run";
      inir-settings = "inir settings";
      inir-logs = "inir logs --full";
      inir-doctor = "inir doctor";
      inir-update = "inir update";
    };
  };

  # --- Kitty terminal (iNiR's default) ---
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrains Mono";
      font_size = 12;
      background_opacity = "0.92";
      confirm_os_window_close = -1;
    };
  };

  # --- Starship prompt (iNiR themes this automatically) ---
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };

  # ==========================================================================
  # Niri settings — full iNiR config.kdl translation
  # These generate ~/.config/niri/config.kdl via the niri-flake homeModules.config.
  # ==========================================================================
  programs.niri.settings = {
    # --- Top-level ---
    prefer-no-csd = true;

    hotkey-overlay = {
      skip-at-startup = true;
    };

    screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

    # --- Input ---
    input = {
      keyboard = {
        xkb = {
          layout = "us";
        };
        repeat-delay = 250;
        repeat-rate = 50;
      };
      touchpad = {
        tap = true;
        tap-button-map = "left-right-middle";
      };
      mouse = {
        accel-profile = "flat";
      };
      mod-key = "Super";
      mod-key-nested = "Alt";
    };

    # --- Layout ---
    layout = {
      gaps = 25;
      background-color = "transparent";
      center-focused-column = "never";

      preset-column-widths = [
        { proportion = 0.33333; }
        { proportion = 0.5; }
        { proportion = 0.66667; }
      ];

      default-column-width = {
        proportion = 0.5;
      };

      border = {
        enable = false;
        width = 4;
        active = "#707070";
        inactive = "#d0d0d0";
        urgent = "#cc4444";
      };

      focus-ring = {
        enable = false;
        width = 1;
        active = "#808080";
        inactive = "#505050";
      };

      shadow = {
        softness = 30;
        spread = 5;
        offset = {
          x = 0;
          y = 5;
        };
        color = "#0007";
      };

      struts = {};
    };

    # --- Cursor ---
    cursor = {
      theme = "capitaine-cursors-light";
      size = 24;
      hide-on-key-press = true;
    };

    # --- Overview ---
    overview = {
      zoom = 0.75;
    };

    # --- Window rules ---
    window-rules = [
      {
        geometry-corner-radius = {
          top-left = 16.0;
          top-right = 16.0;
          bottom-left = 16.0;
          bottom-right = 16.0;
        };
        clip-to-geometry = true;
      }
      {
        matches = [{ is-active = false; }];
        opacity = 0.9;
      }
    ];

    # --- Animations (tuned to complement quickshell's Material motion curves) ---
    animations = {
      workspace-switch = {
        kind.spring = {
          damping-ratio = 0.78;
          stiffness = 600;
          epsilon = 0.0001;
        };
      };
      window-open = {
        kind.spring = {
          damping-ratio = 0.82;
          stiffness = 500;
          epsilon = 0.0001;
        };
      };
      window-close = {
        kind.spring = {
          damping-ratio = 0.88;
          stiffness = 900;
          epsilon = 0.0001;
        };
      };
      horizontal-view-movement = {
        kind.spring = {
          damping-ratio = 0.80;
          stiffness = 550;
          epsilon = 0.0001;
        };
      };
      window-movement = {
        kind.spring = {
          damping-ratio = 0.85;
          stiffness = 650;
          epsilon = 0.0001;
        };
      };
      window-resize = {
        kind.spring = {
          damping-ratio = 0.88;
          stiffness = 700;
          epsilon = 0.0001;
        };
      };
      config-notification-open-close = {
        kind.spring = {
          damping-ratio = 0.90;
          stiffness = 800;
          epsilon = 0.0001;
        };
      };
      screenshot-ui-open = {
        kind.spring = {
          damping-ratio = 0.85;
          stiffness = 750;
          epsilon = 0.0001;
        };
      };
    };

    # --- Environment variables ---
    environment = {
      XDG_CURRENT_DESKTOP = "niri";
      XDG_MENU_PREFIX = "plasma-";
      QT_QPA_PLATFORM = "wayland";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      QT_LOGGING_RULES = "quickshell.dbus.properties=false";
      QT_QPA_PLATFORMTHEME = "kde";
      QT_STYLE_OVERRIDE = "Darkly";
      INIR_VENV = "$HOME/.local/state/quickshell/.venv";
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = "$HOME/.local/state/quickshell/.venv";
    };

    # --- Spawn at startup ---
    spawn-at-startup = [
      { argv = ["bash" "-c" "systemctl --user import-environment XDG_MENU_PREFIX && kbuildsycoca6"]; }
      { argv = ["bash" "-c" "wl-paste --watch cliphist store &"]; }
      { argv = ["/usr/lib/mate-polkit/polkit-mate-authentication-agent-1"]; }
    ];

    # --- Layer rules for ii backdrop visibility during Niri overview ---
    layer-rules = [
      {
        matches = [{ namespace = "quickshell:iiBackdrop"; }];
        place-within-backdrop = true;
        opacity = 1.0;
      }
      {
        matches = [{ namespace = "quickshell:wBackdrop"; }];
        place-within-backdrop = true;
        opacity = 1.0;
      }
    ];

    # --- Keybindings ---
    binds = {
      # System
      "Mod+Tab" = {
        repeat = false;
        action.toggle-overview = [];
      };
      "Mod+Shift+E".action.quit = [];
      "Mod+Escape" = {
        allow-inhibiting = false;
        action.toggle-keyboard-shortcuts-inhibit = [];
      };

      # ii Window Switcher (Alt+Tab)
      "Alt+Tab".action.spawn = ["qs" "-c" "inir" "ipc" "call" "altSwitcher" "next"];
      "Alt+Shift+Tab".action.spawn = ["qs" "-c" "inir" "ipc" "call" "altSwitcher" "previous"];

      # ii Overlay
      "Super+G".action.spawn = ["qs" "-c" "inir" "ipc" "call" "overlay" "toggle"];

      # ii Overview (daemon)
      "Mod+Space" = {
        repeat = false;
        action.spawn = ["qs" "-c" "inir" "ipc" "call" "overview" "toggle"];
      };

      # ii Clipboard
      "Mod+V".action.spawn = ["qs" "-c" "inir" "ipc" "call" "clipboard" "toggle"];

      # ii Lock screen
      "Mod+Alt+L" = {
        allow-when-locked = true;
        action.spawn = ["qs" "-c" "inir" "ipc" "call" "lock" "activate"];
      };

      # ii Region tools
      "Mod+Shift+S".action.spawn = ["qs" "-c" "inir" "ipc" "call" "region" "screenshot"];
      "Mod+Shift+X".action.spawn = ["qs" "-c" "inir" "ipc" "call" "region" "ocr"];
      "Mod+Shift+A".action.spawn = ["qs" "-c" "inir" "ipc" "call" "region" "search"];

      # ii Wallpaper selector
      "Ctrl+Alt+T".action.spawn = ["qs" "-c" "inir" "ipc" "call" "wallpaperSelector" "toggle"];

      # ii Settings
      "Mod+Comma".action.spawn = ["qs" "-c" "inir" "ipc" "call" "settings" "open"];

      # ii Cheatsheet
      "Mod+Slash".action.spawn = ["qs" "-c" "inir" "ipc" "call" "cheatsheet" "toggle"];

      # ii Panel family (cycle between Material ii and Waffle styles)
      "Mod+Shift+W".action.spawn = ["qs" "-c" "inir" "ipc" "call" "panelFamily" "cycle"];

      # Applications (uses configured terminal from Settings)
      "Mod+T".action.spawn = ["bash" "-c" "$HOME/.config/quickshell/inir/scripts/launch-terminal.sh"];
      "Mod+Return".action.spawn = ["bash" "-c" "$HOME/.config/quickshell/inir/scripts/launch-terminal.sh"];
      "Super+E".action.spawn = ["nautilus"];
      "Super+W".action.spawn = ["bash" "-c" "xdg-open https://"];

      # Window management
      "Mod+Q" = {
        repeat = false;
        action.spawn = ["bash" "-c" "$HOME/.config/quickshell/inir/scripts/close-window.sh"];
      };
      "Mod+D".action.maximize-column = [];
      "Mod+F".action.fullscreen-window = [];
      "Mod+A".action.toggle-window-floating = [];

      # Focus
      "Mod+Left".action.focus-column-left = [];
      "Mod+Right".action.focus-column-right = [];
      "Mod+Up".action.focus-window-up = [];
      "Mod+Down".action.focus-window-down = [];
      "Mod+H".action.focus-column-left = [];
      "Mod+J".action.focus-window-down = [];
      "Mod+K".action.focus-window-up = [];
      "Mod+L".action.focus-column-right = [];

      # Move windows
      "Mod+Shift+Left".action.move-column-left = [];
      "Mod+Shift+Right".action.move-column-right = [];
      "Mod+Shift+Up".action.move-window-up = [];
      "Mod+Shift+Down".action.move-window-down = [];
      "Mod+Shift+H".action.move-column-left = [];
      "Mod+Shift+J".action.move-window-down = [];
      "Mod+Shift+K".action.move-window-up = [];
      "Mod+Shift+L".action.move-column-right = [];

      # Workspaces
      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;

      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;

      # Screenshots (native)
      "Print".action.screenshot = [];
      "Ctrl+Print".action.screenshot-screen = [];
      "Alt+Print".action.screenshot-window = [];

      # ======================================================================
      # HARDWARE KEYS — Audio, Brightness, Media
      # These use ii IPC so the OSD (On Screen Display) shows feedback
      # ======================================================================

      # Volume
      "XF86AudioRaiseVolume" = {
        allow-when-locked = true;
        action.spawn = ["qs" "-c" "inir" "ipc" "call" "audio" "volumeUp"];
      };
      "XF86AudioLowerVolume" = {
        allow-when-locked = true;
        action.spawn = ["qs" "-c" "inir" "ipc" "call" "audio" "volumeDown"];
      };
      "XF86AudioMute" = {
        allow-when-locked = true;
        action.spawn = ["qs" "-c" "inir" "ipc" "call" "audio" "mute"];
      };
      "XF86AudioMicMute" = {
        allow-when-locked = true;
        action.spawn = ["qs" "-c" "inir" "ipc" "call" "audio" "micMute"];
      };

      # Brightness
      "XF86MonBrightnessUp" = {
        allow-when-locked = true;
        action.spawn = ["qs" "-c" "inir" "ipc" "call" "brightness" "increment"];
      };
      "XF86MonBrightnessDown" = {
        allow-when-locked = true;
        action.spawn = ["qs" "-c" "inir" "ipc" "call" "brightness" "decrement"];
      };

      # Media playback
      "XF86AudioPlay".action.spawn = ["qs" "-c" "inir" "ipc" "call" "mpris" "playPause"];
      "XF86AudioPause".action.spawn = ["qs" "-c" "inir" "ipc" "call" "mpris" "playPause"];
      "XF86AudioNext".action.spawn = ["qs" "-c" "inir" "ipc" "call" "mpris" "next"];
      "XF86AudioPrev".action.spawn = ["qs" "-c" "inir" "ipc" "call" "mpris" "previous"];

      # Music control (keyboard alternatives for keyboards without media keys)
      "Ctrl+Mod+Space".action.spawn = ["qs" "-c" "inir" "ipc" "call" "mpris" "playPause"];
      "Mod+Alt+N".action.spawn = ["qs" "-c" "inir" "ipc" "call" "mpris" "next"];
      "Mod+Alt+P".action.spawn = ["qs" "-c" "inir" "ipc" "call" "mpris" "previous"];
      "Mod+Shift+M".action.spawn = ["qs" "-c" "inir" "ipc" "call" "audio" "mute"];
      "Mod+Shift+P".action.spawn = ["qs" "-c" "inir" "ipc" "call" "mpris" "playPause"];
      "Mod+Shift+N".action.spawn = ["qs" "-c" "inir" "ipc" "call" "mpris" "next"];
      "Mod+Shift+B".action.spawn = ["qs" "-c" "inir" "ipc" "call" "mpris" "previous"];

      # Power / Session
      "Mod+Shift+Q".action.spawn = ["qs" "-c" "inir" "ipc" "call" "session" "toggle"];
    };
  };

  # --- Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.11";
}
