{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    fd
  ];

  programs.mcfly = {
    enable = true;
  };

  programs.ripgrep = {
    enable = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.eza = {
    enable = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
    enableAliases = true;
    git = true;
    icons = true;
  };

  programs.zsh = {
    enable = true;
    enableVteIntegration = true;
    initExtra = ''
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word
      bindkey '^H' backward-kill-word
      bindkey '5~' kill-word
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';
    shellAliases = {
      cat = "${pkgs.bat}/bin/bat";
      ns = "nix-shell";
      nxs = "sudo nixos-rebuild switch";
      ncgd = "sudo nix-collect-garbage -d";
    };
    zplug = {
      enable = true;
      plugins = [
        {name = "zsh-users/zsh-autosuggestions";}
      ];
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env = {TERM = "xterm-256color";};
      window = {opacity = 0.92;};

      font = {
        normal = {
          family = "JetBrains Mono";
          style = "Regular";
        };
        size = 13;
      };

      cursor = {
        style = {
          shape = "Beam";
        };
        vi_mode_style = {
          shape = "Block";
        };
      };

      colors = {
        primary = {
          background = "#2e3440";
          foreground = "#d8dee9";
          dim_foreground = "#a5abb6";
        };

        cursor = {
          text = "#2e3440";
          cursor = "#d8dee9";
        };

        vi_mode_cursor = {
          text = "#2e3440";
          cursor = "#d8dee9";
        };

        selection = {
          text = "CellForeground";
          background = "#4c566a";
        };

        footer_bar = {
          background = "#434c5e";
          foreground = "#d8dee9";
        };

        search = {
          matches = {
            foreground = "CellBackground";
            background = "#88c0d0";
          };
        };

        normal = {
          black = "#3b4252";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#88c0d0";
          white = "#e5e9f0";
        };

        bright = {
          black = "#4c566a";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#8fbcbb";
          white = "#eceff4";
        };

        dim = {
          black = "#373e4d";
          red = "#94545d";
          green = "#809575";
          yellow = "#b29e75";
          blue = "#68809a";
          magenta = "#8c738c";
          cyan = "#6d96a5";
          white = "#aeb3bb";
        };
      };
    };
  };
}
