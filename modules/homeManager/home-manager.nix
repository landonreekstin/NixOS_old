{ inputs, ... }: {

  # may look a bit different
  home-manager."landon" = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "landon" = import ./../hosts/default/home.nix;
      modules = [
        ./../hosts/default/home.nix
        inputs.self.outputs.homeManagerModules.default
      ];
    };
  };

}