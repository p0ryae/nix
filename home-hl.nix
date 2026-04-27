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
    tmux = import ./home/tmux.nix;
    neovim = import ./home/nvim.nix { inherit pkgs; };
    btop = import ./home/btop.nix;
  };
}
