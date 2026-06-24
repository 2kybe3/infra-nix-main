{ self, config, ... }:
let
  ss = config.sops.secrets;

  renovateBotUserName = "renovate-bot";

  passthruFormatter = ''
    function(data)
      return data
    end
  '';

  owner = config.services.webhook-router.user;
in
{
  sops.secrets =
    let
      sopsFile = "${self}/secrets/webhook-router.yaml";
    in
    {
      webhook-router-discord-main = {
        inherit sopsFile owner;
        key = "discord-main";
      };
      webhook-router-discord-renovate = {
        inherit sopsFile owner;
        key = "discord-renovate";
      };
      webhook-router-discord-mirrors = {
        inherit sopsFile owner;
        key = "discord-mirrors";
      };

      webhook-router-input-git-kybe-xyz-system = {
        inherit sopsFile owner;
        key = "input-git-kybe-xyz-system";
      };
    };

  services.webhook-router = {
    enable = true;
    openFirewall = true;

    settings = {
      ip = "0.0.0.0";
      port = 3000;

      webhooks = {
        discord-main = {
          url_file = ss.webhook-router-discord-main.path;
          formatter.script = passthruFormatter;
        };
        discord-renovate = {
          url_file = ss.webhook-router-discord-renovate.path;
          formatter.script = passthruFormatter;
        };
        discord-mirrors = {
          url_file = ss.webhook-router-discord-mirrors.path;
          formatter.script = passthruFormatter;
        };
      };

      inputs.renovate-git-kybe-xyz-system = {
        token_file = ss.webhook-router-input-git-kybe-xyz-system.path;
        fallback_target = "discord-main";
        rules = [
          {
            name = "drop-renovate-issue-edits-and-renovate-actions";
            script = ''
              function(data)
                local embed = data.embeds and data.embeds[1]
                if not embed or not embed.title or not embed.author or not embed.author.name then
                  return
                end

                if string.find(embed.title, "Renovate Action Succeeded in renovate/renovate main", 1, true) then
                  return "drop"
                end

                if embed.author.name ~= "${renovateBotUserName}" then
                  return
                end

                if string.find(embed.title, "Issue edited", 1, true) then
                  return "drop"
                end
              end
            '';
          }
          {
            name = "redirects";
            script = ''
              function(data)
                local embed = data.embeds and data.embeds[1]
                if not embed or not embed.description or not embed.author or not embed.author.name then
                  return
                end

                if embed.author.name == "mirrors" then
                  return "redirect", "discord-mirrors"
                end

                if embed.author.name == "${renovateBotUserName}" then
                  return "redirect", "discord-renovate"
                end
              end
            '';
          }
        ];
      };
    };
  };
}
