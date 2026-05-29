{
  pkgs,
  mattpocockSkills,
  ...
}: let
  skills = import ./mattpocockSkills {inherit pkgs mattpocockSkills;};
in {
  home.file.".agents/skills" = {
    source = "${skills}";
    recursive = true;
  };
}
