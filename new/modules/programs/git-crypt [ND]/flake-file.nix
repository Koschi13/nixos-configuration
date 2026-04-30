{
  flake-file.inputs = {
    git-crypt-secrets = {
      url = "path:./.secrets";
      flake = false;
    };
  };
}
