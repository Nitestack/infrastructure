{
  homelab.apps.it-tools = {
    expose = {
      mode = "public";
      host = "it";
    };

    services.web = {
      enable = true;
      image = "corentinth/it-tools:nightly@sha256:f07d246567e1ceb65e29b0a2ea155a70d7b05e9a35cfc534a2eee7b1f53df64b";
      port = 80;
    };
  };
}
