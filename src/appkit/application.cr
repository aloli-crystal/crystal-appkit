module AppKit
  # Initialise NSApplication en mode app régulière
  def self.init
    LibAppKit.appkit_init
  end

  # Forcer le nom affiché dans la barre de menu macOS
  def self.set_app_name(name : String)
    LibAppKit.appkit_set_app_name(name.to_unsafe)
  end

  # Active l'application (met au premier plan)
  def self.activate
    LibAppKit.appkit_activate
  end
end
