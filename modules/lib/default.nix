{
  lib,
  config,
  ...
}: {
  options.kybe.lib = lib.mkOption {
    type = lib.types.attrs;
    default = {};
  };
  config.kybe.lib = import ./lib.nix {inherit config;};
}
