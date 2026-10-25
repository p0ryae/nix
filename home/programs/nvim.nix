{ pkgs, ... }:
{
  enable = true;
  withNodeJs = true;
  plugins = with pkgs.vimPlugins; [
    nvim-treesitter.withAllGrammars
  ];
  extraPackages = with pkgs; [
    typescript
    typescript-language-server
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
