{
  enable = true;
  settings = {
    "webgl.disabled" = false;
    "privacy.resistFingerprinting" = false;
    "privacy.clearOnShutdown.history" = false;
    "privacy.clearOnShutdown.cookies" = false;
    "network.cookie.lifetimePolicy" = 0;
  };
  profiles.default = {
    name = "Default";
    search = {
      force = true;
      default = "g-us";
      privateDefault = "g-us";

      engines = {
        "g-us" = {
          urls = [
            {
              template = "https://www.google.com/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "https://www.google.com/favicon.ico";
          definedAliases = [ "@g" ];
        };
      };
    };
    settings = {
      "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";

      "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      "browser.search.suggest.enabled" = true;
      "browser.urlbar.suggest.searches" = true;
      # "browser.tabs.drawInTitlebar" = true;
      "svg.context-properties.content.enabled" = true;
    };
    userChrome = ''
      @import "firefox-gnome-theme/userChrome.css";
      @import "firefox-gnome-theme/theme/colors/dark.css"; 
    '';
  };
}
