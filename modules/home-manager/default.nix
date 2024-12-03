# default.nix
# This module imports all other home-manager modules, allowing the enable for each module
# to be set in each /hosts/<hostname>/configuration.nix file.
{ config, lib, pkgs, ... }:

{
  imports = [
    ./home-manager.nix
  ];
}