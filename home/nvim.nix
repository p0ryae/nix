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
    beamPackages.expert
    jdt-language-server

    stylua
    nixfmt
    prettierd
    google-java-format
    sql-formatter
    black
    luarocks
    tree-sitter
    vscode-langservers-extracted
  ];
}
