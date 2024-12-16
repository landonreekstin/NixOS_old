# Standalone Nix shell for ICE40 FPGA tools
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    yosys        # Synthesis tool
    nextpnr-ice40 # Place-and-route tool for iCE40
    icestorm     # iCE40 bitstream tools
    iverilog     # Optional: Verilog simulation
    gtkwave      # Optional: Waveform viewer
  ];

  shellHook = ''
    echo "Welcome to the ICE40 FPGA development environment!"
    echo "Tools included:"
    echo "- yosys: for synthesis"
    echo "- nextpnr-ice40: for place and route"
    echo "- icestorm: for bitstream manipulation"
    echo "- iverilog (optional): for simulation"
    echo "- gtkwave (optional): for waveform visualization"
  '';
}