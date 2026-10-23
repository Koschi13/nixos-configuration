{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }: let
    # Refuses to commit plaintext secrets: everything staged in .secrets/ has
    # to be encrypted by git-crypt, everything in secrets/ (but the rules) by
    # age and everything in keys/ by gpg. It checks the staged blobs, so after
    # the git-crypt clean filter.
    secrets-guard = pkgs.writers.writePython3Bin "secrets-guard" {} ''
      import fnmatch
      import os
      import subprocess
      import sys

      GIT = "${pkgs.lib.getExe pkgs.git}"

      # Binary OpenPGP message, starting with a public-key encrypted session
      # key packet (old or new packet format)
      GPG_PACKETS = b"\x84\x85\x86\x87\xc1"

      # The first matching pattern wins. A file passes if the check accepts
      # its staged content, `None` refuses it unseen.
      RULES = [
          (".secrets/*",
           lambda blob: blob.startswith(b"\0GITCRYPT\0"),
           "not encrypted by git-crypt"),
          ("secrets/agenix-rules.nix", lambda blob: True, None),
          ("secrets/*.age",
           lambda blob: blob.startswith(b"age-encryption.org/v1"),
           "not encrypted by age"),
          ("secrets/*", None, "no *.age file"),
          ("keys/*.gpg",
           lambda blob: len(blob) > 0 and blob[0] in GPG_PACKETS,
           "not encrypted by gpg"),
          ("keys/*", None, "no *.gpg file"),
      ]


      def git(*args):
          return subprocess.run([GIT, *args], check=True,
                                capture_output=True).stdout


      def staged():
          out = git("diff", "--cached", "--name-only", "-z",
                    "--diff-filter=ACMR")
          return [os.fsdecode(file) for file in out.split(b"\0") if file]


      status = 0
      for file in staged():
          for pattern, check, error in RULES:
              if fnmatch.fnmatchcase(file, pattern):
                  if check is None or not check(git("cat-file", "blob",
                                                    f":{file}")):
                      print(f"secrets-guard: {file} is {error}",
                            file=sys.stderr)
                      status = 1
                  break
      sys.exit(status)
    '';
  in {
    # `nix fmt`, also used by the `treefmt` git hook
    treefmt.programs.alejandra.enable = true;

    # The git hooks of the repository. `nix develop` (or direnv) installs them
    # and links the generated `.pre-commit-config.yaml` into the repository
    # root.
    pre-commit = {
      # gitleaks needs the git history, which the sandbox doesn't have
      check.enable = false;
      settings.hooks = {
        treefmt.enable = true;
        gitleaks.enable = true;
        secrets-guard = {
          enable = true;
          name = "secrets-guard";
          entry = pkgs.lib.getExe secrets-guard;
          pass_filenames = false;
          always_run = true;
        };
      };
    };

    devShells.default = config.pre-commit.devShell;
  };
}
