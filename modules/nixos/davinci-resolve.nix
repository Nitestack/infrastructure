# ╭──────────────────────────────────────────────────────────╮
# │ DaVinci Resolve                                          │
# ╰──────────────────────────────────────────────────────────╯
{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    davinci-resolve
  ];
  environment.variables = {
    RUSTICL_ENABLE = "radeonsi";
  };
  hardware = {
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        mesa.opencl # Enables Rusticl (OpenCL) support
      ];
    };
    amdgpu.opencl.enable = true;
  };
}
