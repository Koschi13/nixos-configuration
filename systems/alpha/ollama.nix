{...}: {
  services.ollama = {
    enable = true;
    acceleration = "cuda";
    # environmentVariables = {
    #   OLLAMA_KEEP_ALIVE = "-1";
    # }
  };
  services.nextjs-ollama-llm-ui.enable = true;
}
