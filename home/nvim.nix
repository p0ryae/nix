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
    clang-tools
    neocmakelsp
    pyright
  ];
  plugins = with pkgs.vimPlugins; [
    nvim-treesitter.withAllGrammars
  ];
}
