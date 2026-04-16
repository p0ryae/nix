{ pkgs, ... }:
{
  enable = true;
  withNodeJs = true;
  extraPackages = with pkgs; [
    typescript-go
    nixd
    gopls
    svelte-language-server
    clang-tools
    neocmakelsp
    pyright
    elixir-ls
    jdt-language-server

    stylua
    nixfmt
    prettierd
    google-java-format
    sql-formatter
    black
  ];
  plugins = with pkgs.vimPlugins; [
    nvim-treesitter.withAllGrammars
  ];
}
