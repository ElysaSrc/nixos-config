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
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    enableAllFirmware = true;
    opengl.enable = true;
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
    tmp.cleanOnBoot = true;

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

    kernelModules = ["kvm-amd"];
    kernelPackages = pkgs.linuxPackages_latest;

    initrd = {
      systemd.enable = true;
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
      luks.devices."cryptroot".device = "/dev/disk/by-uuid/8295c5b4-809b-49db-bdc1-1fdf7d48a7a8";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/6506e074-e4f0-4971-89a0-8447f620f827";
      fsType = "btrfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/EBCD-57A0";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/ff64726e-08d0-4af6-80af-6f1a6259df6c";}
  ];
}
