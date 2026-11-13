{
  # nginx in front of the web services of the host, so each one is reachable
  # by name on port 80 instead of by port. The services listen on localhost
  # only and add their own virtual host:
  #
  # ```nix
  # services.nginx.virtualHosts."glance.lan".locations."/".proxyPass = "http://127.0.0.1:5678";
  # ```
  #
  # The names resolve through local DNS records of the gateway, which point at
  # the IP of the host. Plain HTTP, as `.lan` names get no public certificate.
  flake.modules.nixos.reverse-proxy = {
    # Deduplicates the module, as every web service imports it
    key = "reverse-proxy";

    services.nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;

      # Requests for any other name, e.g. the bare IP or hostname, get no
      # service instead of whichever virtual host comes first
      virtualHosts."_" = {
        default = true;
        locations."/".return = "404";
      };
    };

    networking.firewall.allowedTCPPorts = [80];
  };
}
