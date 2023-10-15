{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.elyse.home;
in {
  options.elyse.home = {
    enable = mkEnableOption "Enable Elyse's GUI and default session";
  };

  config = mkIf cfg.enable {
    security.polkit.enable = true;
    programs = {
      sway = {
        enable = true;
        extraPackages = with pkgs; [swaylock swayidle dmenu];
        wrapperFeatures = {
          base = true;
          gtk = true;
        };
        extraSessionCommands = ''
          eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh);
          export SSH_AUTH_SOCK;
        '';
      };
      dconf.enable = true;
      thunar = {
        enable = true;
        plugins = with pkgs.xfce; [
          thunar-archive-plugin
          thunar-volman
        ];
      };
    };

    environment.systemPackages = with pkgs; [
      gnome.seahorse
    ];

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.elyse = import ../../home;
    };

    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        font-awesome
        source-han-sans
        source-han-sans-japanese
        source-han-serif-japanese
        jetbrains-mono
        (nerdfonts.override {fonts = ["JetBrainsMono"];})
      ];
      fontconfig.defaultFonts = {
        serif = ["Noto Serif" "Source Han Serif"];
        sansSerif = ["Noto Sans" "Source Han Sans"];
      };
    };

    sound.enable = true;
    security.rtkit.enable = true;

    services = {
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
      tumbler.enable = true;

      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      adguardhome = {
        enable = true;
        settings = {
          http = {address = "127.0.0.1:3042";};
          dns = {bind_hosts = ["127.0.0.1"];};
        };
      };

      xserver = {
        enable = true;
        layout = "fr";
        excludePackages = [pkgs.xterm];

        displayManager.gdm = {
          enable = true;
        };
      };
    };

    networking.networkmanager = {
      enable = true;
      insertNameservers = ["127.0.0.1"];
    };
  };
}
