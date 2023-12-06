{
  config,
  lib,
  pkgs,
  ...
}: let
  # Define installed programs in a cleaner way
  jb_plugins = ide:
    pkgs.jetbrains.plugins.addPlugins ide [
      "17718" # GitHub Copilot
    ];

  desktopPkgs = with pkgs; [
    ungoogled-chromium
    firefox
    signal-desktop
    spotify
    discord
    libreoffice
    system-config-printer
    skanpage
    gimp
    inkscape
    slack
  ];

  developmentPkgs =
    (with pkgs; [
      # IDE
      vscode
    ])
    ++ (with pkgs.jetbrains; [
      datagrip
      (jb_plugins rider)
      (jb_plugins goland)
      (jb_plugins idea-ultimate)
      (jb_plugins rust-rover)
      (jb_plugins webstorm)
    ]);

  otherPkgs = with pkgs; [
    pavucontrol
    easyeffects
    unzip
  ];
in {
  services = {
    network-manager-applet.enable = true;
    blueman-applet.enable = true;
  };

  home.stateVersion = "23.05";

  nixpkgs.config = {
    allowUnfree = true;
  };

  home.file.".config/nixpkgs/config.nix" = {
    enable = true;
    text = ''
      { allowUnfree = true; }
    '';
  };

  home.file.".config/starship.toml" = {
    enable = true;
    source = ./configs/starship.toml;
  };

  imports = [
    ./sway.nix
    ./shell.nix
  ];

  home.packages = desktopPkgs ++ developmentPkgs ++ otherPkgs;

  services.easyeffects.enable = true;

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    git = {
      enable = true;
      includes = [
        {
          contents = {
            user = {
              name = "Élysæ";
              email = "101974839+ElysaSrc@users.noreply.github.com";
            };
          };
          condition = "gitdir:~/Dev/GitHub/";
        }
      ];
      ignores = [
        ".envrc"
        ".vscode/settings.json"
        ".direnv"
      ];
      extraConfig = {
        init.defaultBranch = "main";
        core.editor = "code --wait";
        push.autoSetupRemote = true;
        commit.gpgsign = true;
        gpg = {
          format = "ssh";
          ssh.allowedSignersFile = "~/.ssh/allowed_signers";
        };
        user.signingkey = "~/.ssh/id_ed25519.pub";
      };
    };
  };
}
