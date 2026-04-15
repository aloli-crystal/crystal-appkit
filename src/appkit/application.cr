module AppKit
  # Initialise NSApplication en mode app régulière
  def self.init
    LibAppKit.appkit_init
  end

  # Active l'application (met au premier plan)
  def self.activate
    LibAppKit.appkit_activate
  end
end
