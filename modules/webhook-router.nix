{ self, config, ... }:
let
  ss = config.sops.secrets;

  renovateBotUserName = "renovate-bot";

  passthruFormatter = ''
    function(data)
      return data
    end
  '';
in
{
  sops.secrets = {
    webhook-router-discord-main = {
      sopsFile = "${self}/secrets/webhook-router.yaml";
      key = "discord-main";
    };
    webhook-router-discord-forgejo = {
      sopsFile = "${self}/secrets/webhook-router.yaml";
      key = "discord-forgejo";
    };

    webhook-router-input-git-kybe-xyz-system = {
      sopsFile = "${self}/secrets/webhook-router.yaml";
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
        discord-forgejo = {
          url_file = ss.webhook-router-discord-forgejo.path;
          formatter.script = passthruFormatter;
        };
      };

      inputs.forgejo-git-kybe-xyz-system = {
        token_file = ss.webhook-router-input-git-kybe-xyz-system.path;
        fallback_target = "discord-main";
        rules = [
          {
            name = "drop-forgejo-issue-edits";
            script = ''
              function(data)
                local embed = data.embeds and data.embeds[1]
                if not embed or not embed.description then
                  return
                end

                if data.username ~= "renovate-bot" then
                  return
                end

                if not string.find(embed.description, "Issue edited", 1, true) then
                  return
                end

                return "drop"
              end
            '';
          }
          {
            name = "forgejo-redirect";
            script = ''
              function(data)
                if data.username == "${renovateBotUserName}" then
                  return "redirect", "discord-forgejo"
                end
              end
            '';
          }
        ];
      };
    };
  };
}
