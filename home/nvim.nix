{ pkgs, ... }:
{
  enable = true;
  withNodeJs = true;
  extraPackages = with pkgs; [
    typescript
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
    luarocks
    tree-sitter
    vscode-langservers-extracted
  ];
}
