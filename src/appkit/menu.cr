module AppKit
  # Constructeur de menu macOS natif
  #
  # Exemple :
  # ```
  # AppKit::Menu.build("Prism") do |menu|
  #   menu.app_menu("Prism") # À propos, Masquer, Quitter
  #   menu.edit_menu         # Annuler, Copier, Coller...
  #
  #   menu.submenu("Fichier") do |m|
  #     m.item("Nouveau", key: "n")
  #     m.item("Ouvrir…", key: "o")
  #     m.separator
  #     m.item("Enregistrer", key: "s")
  #     m.item("Enregistrer sous…", key: "s", shift: true)
  #   end
  #
  #   menu.window_menu # Minimiser, Zoom...
  # end
  # ```
  class Menu
    # Flags pour les modificateurs
    CMD   = 1
    SHIFT = 2
    ALT   = 4
    CTRL  = 8

    def initialize
      LibAppKit.appkit_menu_create
    end

    # Menu "app" standard (À propos, Masquer, Quitter)
    def app_menu(app_name : String)
      LibAppKit.appkit_menu_add_app_menu(app_name.to_unsafe)
    end

    # Menu Édition standard
    def edit_menu
      LibAppKit.appkit_menu_add_edit_menu
    end

    # Menu Fenêtre standard
    def window_menu
      LibAppKit.appkit_menu_add_window_menu
    end

    # Ajouter un sous-menu personnalisé
    def submenu(title : String, & : SubMenu ->) : SubMenu
      index = LibAppKit.appkit_menu_add_submenu(title.to_unsafe)
      sub = SubMenu.new(index)
      yield sub
      sub
    end

    # Builder pattern
    def self.build(app_name : String, & : Menu ->) : Menu
      menu = new
      yield menu
      menu
    end

    # Sous-menu
    class SubMenu
      def initialize(@index : Int32)
      end

      # Ajouter un item avec raccourci optionnel
      def item(title : String, key : String = "", shift : Bool = false, alt : Bool = false, ctrl : Bool = false)
        flags = 0
        flags |= CMD unless key.empty?
        flags |= SHIFT if shift
        flags |= ALT if alt
        flags |= CTRL if ctrl
        LibAppKit.appkit_menu_add_item(@index, title.to_unsafe, key.to_unsafe, flags)
      end

      # Séparateur
      def separator
        LibAppKit.appkit_menu_add_separator(@index)
      end
    end
  end
end
