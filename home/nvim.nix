{ pkgs, ... }:
{
  enable = true;
  withNodeJs = true;
  extraPackages = with pkgs; [
    stylua
    typescript-go
    nixd
    nixfmt
    gopls
    svelte-language-server
    neocmakelsp
    pyright
  ];
  plugins = [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];
}
