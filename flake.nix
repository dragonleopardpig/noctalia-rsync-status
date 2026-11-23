{
  description = "Noctalia local/rsync-status bar plugin and sync-projects graphical configuration helper";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      helper = pkgs.writeShellApplication {
        name = "noctalia-rsync-status";
        runtimeInputs = [ pkgs.python3 pkgs.coreutils pkgs.less pkgs.rsync pkgs.zenity ];
        text = ''
          exec python3 ${./helper/rsync-status.py} "$@"
        '';
      };
      plugin = pkgs.runCommand "noctalia-plugin-rsync-status" { } ''
        cp -r ${./rsync-status} $out
      '';
    in {
      lib = {
        pluginDir = ./rsync-status;
        helperScript = ./helper/rsync-status.py;
      };
      packages.${system} = {
        inherit helper plugin;
        default = helper;
      };
      checks.${system} = {
        helper = pkgs.runCommand "noctalia-rsync-status-checked" {
          nativeBuildInputs = [ pkgs.python3 ];
        } ''
          python3 ${./tests/test-rsync-status.py} ${./helper/rsync-status.py}
          touch $out
        '';
        plugin = pkgs.runCommand "noctalia-rsync-status-plugin-checked" {
          nativeBuildInputs = [ pkgs.luau ];
        } ''
          for entry in service bar panel; do
            {
              printf 'local TEST_ENTRY = "%s"\n' "$entry"
              cat ${./tests/test-rsync-status-plugin.luau}
            } | sed -e '/^--@COMMON@$/{r ${./rsync-status/common.luau}' -e 'd}' \
                    -e "/^--@ENTRY@$/{r ${./rsync-status}/$entry.luau" -e 'd}' \
              | sed 's|require("./common\.luau")|commonModule|g' > "test_$entry.luau"
            luau "test_$entry.luau"
          done
          touch $out
        '';
      };
    };
}
