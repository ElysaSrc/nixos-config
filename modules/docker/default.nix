{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.elyse.docker;
in {
  options.elyse.docker = {
    enable = mkEnableOption "Enable Docker Stack for development purposes";
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      storageDriver = "overlay2";
      autoPrune.enable = true;
    };
    environment.systemPackages = with pkgs; [
      docker-compose
    ];
    users.groups.docker.members = ["elyse"];
  };
}
