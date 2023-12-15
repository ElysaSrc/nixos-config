{
  config,
  lib,
  pkgs,
  ...
}: let
  colors = import ../common/colors.nix;

  takeScreenArea = pkgs.writeShellScriptBin "take-screen" ''
    ${pkgs.grim}/bin/grim -t png -g "$(${pkgs.slurp}/bin/slurp -d)" - | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  swaylockTheme = pkgs.writeShellScriptBin "swaylock" ''
    ${pkgs.swaylock}/bin/swaylock -i ${../common/wallpaper.png} -fF
  '';
in {
  services = {
    clipman.enable = true;
    avizo.enable = true;
    kdeconnect = {
      enable = true;
    };

    mako = {
      enable = true;
      defaultTimeout = 15000;
      font = "JetBrainsMono Nerd Font Mono 13";
      borderSize = 2;
      backgroundColor = colors.background;
      borderColor = colors.magenta;
      textColor = colors.foreground;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt;
    };
  };

  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome.gnome-themes-extra;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      allow_markup = true;
      allow_images = true;
      width = 550;
    };
  };

  programs.waybar = {
    enable = true;
    style = builtins.readFile ./configs/waybar.css;
    systemd.enable = true;
    systemd.target = "sway-session.target";
    settings = let
      battery = {
        "interval" = 60;
        "states" = {
          "warning" = 30;
          "critical" = 15;
        };
        "format" = "{icon} {capacity}%";
        "format-icons" = ["" "" "" "" ""];
        "max-length" = 25;
      };
      tray = {
        "icon-size" = 21;
        "spacing" = 5;
      };
      sway_workspaces = {
        format = "{value}";
        disable-scroll = false;
        all-outputs = false;
      };
      cpu = {
        "format" = " {usage}%";
      };
      memory = {
        "format" = " {}%";
      };
      backlight = {
        "format" = "{icon} {percent}%";
        "format-icons" = ["" "" "" "" "" "" "" "" ""];
      };
      bluetooth = {
        "on-click" = "/run/current-system/sw/bin/blueman-manager";
        "format" = " {status}";
        "format-disabled" = "";
        "format-connected" = " {num_connections} connected";
        "tooltip-format" = "{controller_alias}\t{controller_address}";
        "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
        "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
      };
      idle_inhibitor = {
        "format" = "{icon}";
        "format-icons" = {
          "activated" = "";
          "deactivated" = "";
        };
      };
      network = {
        "format-wifi" = "{essid} ({signalStrength}%) ";
        "format-ethernet" = " {ifname}";
        "tooltip-format" = " {ifname} via {gwaddr}";
        "format-linked" = " {ifname} (No IP)";
        "format-disconnected" = "Disconnected ⚠ {ifname}";
        "format-alt" = " {ifname}: {ipaddr}/{cidr}";
      };
      pulseaudio = {
        "scroll-step" = 1;
        "format" = "{icon} {volume}% {format_source}";
        "format-bluetooth" = " {icon} {volume}% {format_source}";
        "format-bluetooth-muted" = "  {icon} {format_source}";
        "format-muted" = "  {format_source}";
        "format-source" = " {volume}%";
        "format-source-muted" = "";
        "format-icons" = {
          "headphone" = "";
          "hands-free" = "";
          "headset" = "";
          "phone" = "";
          "portable" = "";
          "car" = "";
          "default" = ["" "" ""];
        };
        "on-click" = "/etc/profiles/per-user/elyse/bin/pavucontrol";
        "ignored-sinks" = ["Easy Effects Sink"];
      };
    in {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        output = [
          "eDP-1"
          "HDMI-A-1"
        ];
        modules-left = ["sway/workspaces" "sway/mode"];
        modules-center = [];
        modules-right = [
          "idle_inhibitor"
          "cpu"
          "memory"
          "battery"
          "pulseaudio"
          "backlight"
          "tray"
          "clock"
        ];
        "battery" = battery;
        "tray" = tray;
        "sway/workspaces" = sway_workspaces;
        "cpu" = cpu;
        "memory" = memory;
        "backlight" = backlight;
        "bluetooth" = bluetooth;
        "idle_inhibitor" = idle_inhibitor;
        "network" = network;
        "pulseaudio" = pulseaudio;
      };
    };
  };

  services.swayidle = let
    swaylockCmd = "${swaylockTheme}/bin/swaylock";

    lockAndDim = pkgs.writeShellScriptBin "lockAndDim" ''
      ${pkgs.brightnessctl}/bin/brightnessctl --save
      ${pkgs.brightnessctl}/bin/brightnessctl -c backlight set 10%
      ${swaylockCmd}
    '';

    fullBrightness = pkgs.writeShellScriptBin "fullBrightness" ''
      ${pkgs.brightnessctl}/bin/brightnessctl --restore
    '';

    screenDown = pkgs.writeShellScriptBin "screenDown" ''
      ${pkgs.sway}/bin/swaymsg "output * dpms off"
    '';

    screenUp = pkgs.writeShellScriptBin "screenUp" ''
      ${pkgs.sway}/bin/swaymsg "output * dpms on"
    '';
  in {
    enable = true;
    timeouts = [
      {
        timeout = 120;
        command = "${lockAndDim}/bin/lockAndDim";
        resumeCommand = "${fullBrightness}/bin/fullBrightness";
      }
      {
        timeout = 140;
        command = "${screenDown}/bin/screenDown";
        resumeCommand = "${screenUp}/bin/screenUp";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = swaylockCmd;
      }
      {
        event = "lock";
        command = swaylockCmd;
      }
    ];
  };

  systemd.user.services.swww = {
    Unit = {
      PartOf = ["graphical-session.target"];
      After = ["graphical-session-pre.target"];
    };

    Service = {
      ExecStart = "${pkgs.swww}/bin/swww-daemon";
      ExecStartPost = "${pkgs.swww}/bin/swww img ${../common/wallpaper.gif}";
      Restart = "on-failure";
    };

    Install = {WantedBy = ["graphical-session.target"];};
  };

  wayland.windowManager.sway = let
    terminal = "alacritty";
    modifier = "Mod4";
  in {
    enable = true;
    package = null;

    config = {
      terminal = terminal;
      modifier = modifier;

      colors = {
        background = colors.background;
        focused = {
          background = colors.background;
          border = colors.magenta;
          childBorder = colors.magenta;
          indicator = colors.white;
          text = colors.foreground;
        };
        focusedInactive = {
          background = colors.background;
          border = colors.black;
          childBorder = colors.black;
          indicator = colors.white;
          text = colors.foreground;
        };
        placeholder = {
          background = colors.background;
          border = "#000000";
          childBorder = "#0c0c0c";
          indicator = "#000000";
          text = "#ffffff";
        };
        unfocused = {
          background = colors.background;
          border = colors.black;
          childBorder = colors.black;
          indicator = colors.white;
          text = colors.foreground;
        };
        urgent = {
          background = colors.background;
          border = colors.red;
          childBorder = colors.red;
          indicator = colors.white;
          text = colors.foreground;
        };
      };

      gaps = {
        inner = 5;
        outer = 5;
      };

      input = {
        "*" = {
          xkb_layout = "fr";
          xkb_numlock = "enabled";
          xkb_variant = "oss";
        };
      };

      bars = [];

      /*
      output = {"*" = {bg = "${../common/wallpaper.png} fill";};};
      */

      keybindings = {
        "${modifier}+return" = "exec ${terminal}";
        "${modifier}+q" = "kill";
        "${modifier}+t" = "exec ${terminal} -e nmtui";
        "${modifier}+l" = "exec ${swaylockTheme}/bin/swaylock";
        "${modifier}+e" = "exec thunar";
        "${modifier}+s" = "exec ${terminal} -e ${pkgs.bottom}/bin/btm";
        "${modifier}+Shift+l" = "exec systemctl suspend";
        "${modifier}+Shift+s" = "exec ${takeScreenArea}/bin/take-screen";
        "XF86Launch2" = "exec ${takeScreenArea}/bin/take-screen";
        "${modifier}+Shift+return" = "exec chromium";
        "${modifier}+space" = "exec wofi --show drun";

        "XF86MonBrightnessUp" = "exec lightctl up";
        "XF86MonBrightnessDown" = "exec lightctl down";

        "XF86AudioRaiseVolume" = "exec volumectl -u up";
        "XF86AudioLowerVolume" = "exec volumectl -u down";
        "XF86AudioMute" = "exec volumectl toggle-mute";
        "XF86AudioMicMute" = "exec volumectl -m toggle-mute";

        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

        "${modifier}+ampersand" = "workspace 1";
        "${modifier}+eacute" = "workspace 2";
        "${modifier}+quotedbl" = "workspace 3";
        "${modifier}+apostrophe" = "workspace 4";
        "${modifier}+parenleft" = "workspace 5";
        "${modifier}+minus" = "workspace 6";
        "${modifier}+egrave" = "workspace 7";
        "${modifier}+underscore" = "workspace 8";
        "${modifier}+ccedilla" = "workspace 9";
        "${modifier}+agrave" = "workspace 10";

        "${modifier}+Shift+ampersand" = "move container to workspace 1";
        "${modifier}+Shift+eacute" = "move container to workspace 2";
        "${modifier}+Shift+quotedbl" = "move container to workspace 3";
        "${modifier}+Shift+apostrophe" = "move container to workspace 4";
        "${modifier}+Shift+parenleft" = "move container to workspace 5";
        "${modifier}+Shift+minus" = "move container to workspace 6";
        "${modifier}+Shift+egrave" = "move container to workspace 7";
        "${modifier}+Shift+underscore" = "move container to workspace 8";
        "${modifier}+Shift+ccedilla" = "move container to workspace 9";
        "${modifier}+Shift+agrave" = "move container to workspace 10";

        "${modifier}+f" = "fullscreen toggle";
        "${modifier}+a" = "focus parent";
        "${modifier}+b" = "splith";
        "${modifier}+v" = "splitv";

        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+Shift+f" = "focus mode_toggle";

        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit ?' -b 'Yes' 'swaymsg exit'";
        "${modifier}+Shift+p" = "exec swaynag -t warning -m 'Shutdown system ?' -b 'Yes' 'poweroff'";
      };
    };

    extraConfig = ''
      seat seat0 xcursor_theme "${config.gtk.cursorTheme.name}"
      default_border pixel 2
      default_floating_border pixel 2
      font pango:monospace 0
      titlebar_padding 1
      titlebar_border_thickness 0

      workspace 1
      exec ${terminal}
    '';
  };
}
