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
        package = pkgs.swayfx;
        extraPackages = with pkgs; [swaylock swayidle dmenu];
        wrapperFeatures = {
          base = true;
          gtk = true;
        };
        extraSessionCommands = ''
          export _JAVA_AWT_WM_NONREPARENTING=1
          export MOZ_ENABLE_WAYLAND=1
          export QT_QPA_PLATFORM=wayland
          export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
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

      regreet = {
        enable = true;
        settings = {
          background = {
            path = ../../common/wallpaper.png;
            fit = "Cover";
          };
          GTK = {
            application_prefer_dark_theme = true;
            theme_name = "Adwaita-dark";
            icon_theme_name = "Papirus-Dark";
            font_name = "JetBrainsMono Nerd Font Mono 13";
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      gnome.seahorse
      papirus-icon-theme
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

      greetd = let
        wrappedGreeter = let
          cfg = config.programs.regreet;
        in
          pkgs.writeShellScriptBin "wrappedGreeter" ''
            export XKB_DEFAULT_LAYOUT=fr
            export XKB_DEFAULT_VARIANT=oss
            exec ${lib.getExe pkgs.cage} ${lib.escapeShellArgs cfg.cageArgs} -- ${lib.getExe cfg.package}
          '';
      in {
        enable = true;
        settings = {
          default_session.command = "${pkgs.dbus}/bin/dbus-run-session ${lib.getExe wrappedGreeter}";
        };
      };

      xserver = {
        enable = true;
        layout = "fr";
        excludePackages = [pkgs.xterm];
      };
    };

    networking.networkmanager = {
      enable = true;
      insertNameservers = ["127.0.0.1"];
    };
  };
}
