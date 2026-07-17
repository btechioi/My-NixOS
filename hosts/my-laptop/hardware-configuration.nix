# This is a placeholder — replace with your actual hardware configuration.
# Generate it on your NixOS system with:
#   nixos-generate-config --show-hardware-config > hardware-configuration.nix
{
  # System architecture (required for flakes)
  nixpkgs.hostPlatform = "x86_64-linux";

  # Boot — adjust to your setup
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Example filesystem layout — replace with your actual mounts
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # If you use swap:
  # swapDevices = [{
  #   device = "/dev/disk/by-label/swap";
  # }];

  # GPU — uncomment ONE of these:

  # Intel (Kaby Lake / newer)
  hardware.graphics.enable = true;
  # services.xserver.videoDrivers = [ "modesetting" ];

  # AMD
  # hardware.graphics.amd.enable = true;

  # NVIDIA (uncomment and remove the Intel lines above)
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   open = true;
  #   nvidiaSettings = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };

  # Laptop-specific
  # services.thermald.enable = true; # Intel thermal management
}
