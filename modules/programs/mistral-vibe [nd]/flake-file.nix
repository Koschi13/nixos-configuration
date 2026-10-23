{
  flake-file.inputs = {
    mistral-vibe = {
      url = "github:mistralai/mistral-vibe?ref=v2.25.5";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
