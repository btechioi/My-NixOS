# My-PC: Ivy Bridge i5-3470, HD 4000, 8GB RAM, 1TB btrfs
# Generated from live scan of 192.168.1.2
{
  nixpkgs.hostPlatform = "x86_64-linux";

  # Boot — systemd-boot on vfat ESP
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Root: btrfs on /dev/sda2, boot: vfat on /dev/sda1
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3399ab67-80e0-404a-af71-46d88db3850a";
    fsType = "btrfs";
    options = ["subvol=@"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/AFED-1CBD";
    fsType = "vfat";
  };

  # Data drive: 465GB NTFS on /dev/sdf3
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/6CEED9CAEED98CA8";
    fsType = "ntfs3";
    options = ["rw" "uid=1000" "gid=100" "umask=0022"];
  };

  # GPU — Intel HD 4000 (Ivy Bridge, 3rd Gen)
  hardware.graphics.enable = true;
  # Ivy Bridge needs the older xf86-video-intel for DRI support
  services.xserver.videoDrivers = ["modesetting"];

  # USB WiFi — Realtek RTL8188FTV (2.4GHz, needs rtl8xxxu kernel module)
  # USB WiFi — Realtek RTL8188FTV (2.4GHz, uses in-kernel rtl8xxxu driver)
  # No extra config needed — rtl8xxxu is built into the kernel

  # USB Bluetooth — Cambridge Silicon Radio dongle
  hardware.bluetooth.enable = true;

  # Laptop-specific
  # services.thermald.enable = true; # Intel thermal management
}
