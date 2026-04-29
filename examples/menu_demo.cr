require "../src/appkit"

# Démo : menu natif macOS en Crystal
#
# Ce programme crée une barre de menu macOS native
# avec un menu app, un menu Fichier, un menu Édition,
# et un menu Fenêtre.

AppKit.init

AppKit::Menu.build("Demo") do |menu|
  menu.app_menu("Demo")
  menu.edit_menu

  menu.submenu("Fichier") do |m|
    m.item("Nouveau", key: "n")
    m.item("Ouvrir…", key: "o")
    m.separator
    m.item("Enregistrer", key: "s")
    m.item("Enregistrer sous…", key: "s", shift: true)
  end

  menu.submenu("Affichage") do |m|
    m.item("Sidebar", key: "b")
    m.item("Prévisualisation", key: "p")
    m.item("Minimap", key: "m")
    m.separator
    m.item("Thème clair/sombre", key: "d")
    m.item("Mode zen", key: "\r")
  end

  menu.window_menu
end

AppKit.activate

# Normalement ici on lancerait la boucle principale,
# mais pour cette démo on affiche juste une alerte
AppKit::Dialog.info("appkit", "Le menu natif macOS est en place !\nRegardez la barre de menu.")
