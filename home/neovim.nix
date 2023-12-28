{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [ neovide ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    extraLuaConfig = ''
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    '';

    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = ''
          require("nvim-tree").setup({ on_attach = on_attach })
        '';
      }
      nvim-web-devicons
      vim-startify
      ctrlp-vim
      {
        plugin = gruvbox-nvim;
        type = "lua";
        config = ''
          vim.o.background = "dark" -- or "light" for light mode
          vim.cmd([[colorscheme gruvbox]])
        '';
      }
    ];

    coc = {
      enable = true;
      settings = {
        "suggest.noselect" = true;
        "suggest.enablePreview" = true;
        "suggest.enablePreselect" = false;
        "suggest.disableKind" = true;
        languageServers = [
          {
              language = "rust";
              lsp = pkgs.rust-analyzer;
          }
        ];
      };
    };
  };
}
