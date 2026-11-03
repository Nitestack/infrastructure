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
    graphics.extraPackages = with pkgs; [
      mesa.opencl # Enables Rusticl (OpenCL) support
    ];
    amdgpu.opencl.enable = true;
  };
}
