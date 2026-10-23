{
  pkgs,
  mattpocockSkills,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "mattpocock-skills";
  version = "${mattpocockSkills.shortRev}";

  src = mattpocockSkills.outPath;

  dontUnpack = true; # It's already unpacked in the output path
  dontConfigure = true; # No configuration step needed
  dontBuild = true; # No build step needed
  dontFixup = true; # Skips patching ELF binaries, stripping, etc. — irrelevant for plain text/markdown files

  installPhase = ''
    set -euo pipefail

    mkdir -p "$out"

    find "$src/skills" -name SKILL.md \
      -not -path '*/node_modules/*' \
      -not -path '*/deprecated/*' \
      -print0 | while IFS= read -r -d "" skill_md; do
        skill_dir="$(dirname "$skill_md")"
        name="$(basename "$skill_dir")"
        cp -r "$skill_dir" "$out/$name"
      done
  '';
}
