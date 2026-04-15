module AppKit
  # Constructeur de menu macOS natif avec callback
  #
  # Exemple :
  # ```
  # AppKit::Menu.build("Prism") do |menu|
  #   menu.app_menu("Prism") # À propos, Masquer, Quitter
  #   menu.edit_menu         # Annuler, Copier, Coller...
  #
  #   menu.submenu("Fichier") do |m|
  #     m.item("Nouveau", key: "n", action: "new")
  #     m.item("Ouvrir…", key: "o", action: "open")
  #     m.separator
  #     m.item("Enregistrer", key: "s", action: "save")
  #   end
  #
  #   menu.window_menu # Minimiser, Zoom...
  # end
  #
  # AppKit::Menu.on_action do |action_id|
  #   case action_id
  #   when "new"  then do_new
  #   when "open" then do_open
  #   end
  # end
  # ```
  class Menu
    CMD   = 1
    SHIFT = 2
    ALT   = 4
    CTRL  = 8

    # Stocker le callback Crystal pour éviter le GC
    @@callback_box : Pointer(Void)? = nil
    @@handler : Proc(String, Nil)? = nil

    def initialize
      LibAppKit.appkit_menu_create
    end

    # Enregistrer un callback pour les actions de menu
    def self.on_action(&block : String ->) : Nil
      @@handler = block
      boxed_callback = ->(action_id : UInt8*) {
        if handler = @@handler
          handler.call(String.new(action_id))
        end
      }
      # Stocker pour empêcher le GC
      @@callback_box = Box.box(boxed_callback)
      LibAppKit.appkit_menu_set_callback(boxed_callback)
    end

    def app_menu(app_name : String)
      LibAppKit.appkit_menu_add_app_menu(app_name.to_unsafe)
    end

    def edit_menu
      LibAppKit.appkit_menu_add_edit_menu
    end

    def window_menu
      LibAppKit.appkit_menu_add_window_menu
    end

    def submenu(title : String, & : SubMenu ->) : SubMenu
      index = LibAppKit.appkit_menu_add_submenu(title.to_unsafe)
      sub = SubMenu.new(index)
      yield sub
      sub
    end

    def self.build(app_name : String, & : Menu ->) : Menu
      menu = new
      yield menu
      menu
    end

    class SubMenu
      def initialize(@index : Int32)
      end

      # Item avec action callback
      def item(title : String, key : String = "", action : String = "",
               shift : Bool = false, alt : Bool = false, ctrl : Bool = false)
        flags = 0
        flags |= CMD unless key.empty?
        flags |= SHIFT if shift
        flags |= ALT if alt
        flags |= CTRL if ctrl
        action_ptr = action.empty? ? Pointer(UInt8).null : action.to_unsafe
        LibAppKit.appkit_menu_add_item(@index, title.to_unsafe, key.to_unsafe, flags, action_ptr)
      end

      def separator
        LibAppKit.appkit_menu_add_separator(@index)
      end
    end
  end
end
