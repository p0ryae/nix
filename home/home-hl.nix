{
  self,
  config,
  pkgs,
  ...
}:
{
  home = {
    stateVersion = "26.05";
    file = {
      ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${self}/nvim";
    };
  };
  programs = {
    fish.enable = true;
    tmux = import ./programs/tmux.nix;
    neovim = import ./programs/nvim.nix { inherit pkgs; };
    btop = import ./programs/btop.nix;
  };
}
