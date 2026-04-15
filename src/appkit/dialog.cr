module AppKit
  module Dialog
    # Alerte avec OK/Annuler. Retourne true si OK.
    def self.confirm(title : String, message : String, style : Symbol = :info) : Bool
      s = case style
          when :warning  then 1
          when :critical then 2
          else                0
          end
      LibAppKit.appkit_alert(title.to_unsafe, message.to_unsafe, s) == 0
    end

    # Alerte simple (juste OK)
    def self.info(title : String, message : String)
      LibAppKit.appkit_alert_info(title.to_unsafe, message.to_unsafe)
    end

    # Ouvrir un fichier. Retourne le chemin ou nil.
    # types: extensions séparées par des virgules ("adoc,txt,md")
    def self.open_file(title : String = "Ouvrir", types : String = "") : String?
      ptr = LibAppKit.appkit_open_panel(title.to_unsafe, types.to_unsafe)
      return nil if ptr.null?
      path = String.new(ptr)
      LibAppKit.appkit_free(ptr.as(Void*))
      path
    end

    # Ouvrir un dossier. Retourne le chemin ou nil.
    def self.open_folder(title : String = "Choisir un dossier") : String?
      ptr = LibAppKit.appkit_open_folder(title.to_unsafe)
      return nil if ptr.null?
      path = String.new(ptr)
      LibAppKit.appkit_free(ptr.as(Void*))
      path
    end

    # Sauvegarder un fichier. Retourne le chemin ou nil.
    def self.save_file(title : String = "Enregistrer", default_name : String = "") : String?
      ptr = LibAppKit.appkit_save_panel(title.to_unsafe, default_name.to_unsafe)
      return nil if ptr.null?
      path = String.new(ptr)
      LibAppKit.appkit_free(ptr.as(Void*))
      path
    end
  end
end
