{
  config,
  lib,
  pkgs,
  ...
}: let
  # Define installed programs in a cleaner way
  desktopPkgs = with pkgs; [
    ungoogled-chromium
    firefox
    rambox
    signal-desktop
    spotify
    discord
    libreoffice
    system-config-printer
    skanpage
    gimp
    slack
  ];

  developmentPkgs =
    (with pkgs; [
      # IDE
      vscode
    ])
    ++ (with pkgs.jetbrains; [
      datagrip
      rider
      goland
      idea-ultimate
      rust-rover
      webstorm
    ]);

  otherPkgs = with pkgs; [
    pavucontrol
    easyeffects
    unzip
  ];
in {
  services.network-manager-applet.enable = true;
  services.blueman-applet.enable = true;

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
