{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  powerManagement.cpuFreqGovernor = "performance";
  nixpkgs.hostPlatform = "x86_64-linux";

  services = {
    fwupd.enable = true;
    blueman.enable = true;
    xserver.videoDrivers = ["amdgpu"];
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableAllFirmware = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
    bluetooth = {
      enable = true;
    };
  };

  networking = {
    hostName = "elysas-laptop";
  };

  console = {
    keyMap = "fr";
  };

  boot = {
    consoleLogLevel = 0;
    tmp.cleanOnBoot = true;
    plymouth.enable = true;
    bootspec.enable = true;

    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = false;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      configurationLimit = 5;
      settings = {
        editor = false;
      };
    };

    kernelModules = ["kvm-amd" "amdgpu"];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    initrd = {
      systemd.enable = true;
      verbose = false;
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usb_storage"
        "usbhid"
        "sd_mod"
        "tpm_crb"
        "tpm_tis"
        "tpm_tis_core"
        "amdgpu"
      ];
      luks.devices = {
        "cryptroot".device = "/dev/disk/by-uuid/f7d46ae8-af45-48fa-b2b1-e21849fd8405";
        "cryptdata".device = "/dev/disk/by-uuid/46911308-e04a-4ed6-b537-ffb96e6877d1";
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/c4c05f1b-993a-425e-8cd3-8ae10be79945";
      fsType = "btrfs";
    };
    "/home" = {
      device = "/dev/disk/by-uuid/d3a05041-7994-4d2f-9b45-d2fc679ad5a2";
      fsType = "btrfs";
      options = ["subvol=home" "compress=zstd"];
    };
    "/nix" = {
      device = "/dev/disk/by-uuid/d3a05041-7994-4d2f-9b45-d2fc679ad5a2";
      fsType = "btrfs";
      options = ["subvol=nix" "compress=zstd" "noatime"];
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/C442-C54D";
      fsType = "vfat";
    };
  };
  swapDevices = [ { device = "/swapfile"; } ];
}
