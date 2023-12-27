{
  config,
  lib,
  pkgs,
  ...
}: let
  colors = import ../common/colors.nix;
in {
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
      window = {opacity = 0.60;};

      font = {
        normal = {
          family = "JetBrainsMono Nerd Font Mono";
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

      colors = let
        default_scheme = {
          black = colors.black;
          red = colors.red;
          green = colors.green;
          yellow = colors.yellow;
          blue = colors.blue;
          magenta = colors.magenta;
          cyan = colors.cyan;
          white = colors.white;
        };
      in {
        primary = {
          background = "#151515";
          foreground = colors.foreground;
          dim_foreground = colors.white;
        };

        cursor = {
          text = colors.foreground;
          cursor = colors.foreground;
        };

        selection = {
          text = "CellForeground";
          background = colors.black;
        };

        search = {
          matches = {
            foreground = "CellBackground";
            background = colors.yellow;
          };
        };

        normal = default_scheme;
        bright = default_scheme;
        dim = default_scheme;
      };
    };
  };
}
