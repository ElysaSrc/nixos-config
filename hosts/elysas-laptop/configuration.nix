{
  config,
  pkgs,
  ...
}: {
  elyse = {
    host.enable = true;
    home.enable = true;
    docker.enable = true;
  };
}
