{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.elyse.host;
in {
  options.elyse.host = {
    enable = mkEnableOption "Enable Elyse's defaults";

    stateVersion = mkOption {
      type = types.str;
      default = "23.05";
      description = "NixOS state-Version";
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;
    nix = {
      optimise.automatic = true;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
    
    time.timeZone = "Europe/Paris";

    programs.zsh.enable = true;

    environment = {
      pathsToLink = ["/share/zsh"];
      systemPackages = with pkgs; [
        pciutils
        usbutils
        inetutils
        dig
        git
      ];
    };

    i18n = let
      en = "en_US.UTF-8";
      fr = "fr_FR.UTF-8";
    in {
      defaultLocale = en;
      extraLocaleSettings = {
        LANG = en;
        LC_CTYPE = en;
        LC_NUMERIC = fr;
        LC_TIME = fr;
        LC_COLLATE = fr;
        LC_MONETARY = fr;
        LC_PAPER = fr;
        LC_NAME = fr;
        LC_ADDRESS = fr;
        LC_TELEPHONE = fr;
        LC_MEASUREMENT = fr;
        LC_IDENTIFICATION = en;
      };
    };

    users.users.elyse = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "audio"
        "video"
        "input"
      ];
      shell = pkgs.zsh;
      description = "Élysæ";
    };

    system.stateVersion = cfg.stateVersion;

    services = {
      tailscale.enable = true;
      printing.enable = true;
      upower.enable = true;
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };

    networking.firewall.trustedInterfaces = [
      "tailscale0"
    ];
  };
}
