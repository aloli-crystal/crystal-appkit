@[Link(ldflags: "#{__DIR__}/../../ext/appkit_helper.o -framework AppKit -framework Foundation -framework UniformTypeIdentifiers -framework UserNotifications -lobjc")]
lib LibAppKit
  # Application
  fun appkit_init
  fun appkit_activate
  fun appkit_set_app_name(name : UInt8*)

  # Menu
  alias MenuActionCallback = (UInt8*) ->
  fun appkit_menu_create
  fun appkit_menu_set_callback(callback : MenuActionCallback)
  fun appkit_menu_add_submenu(title : UInt8*) : Int32
  fun appkit_menu_add_item(submenu_index : Int32, title : UInt8*, key : UInt8*, modifier_flags : Int32, action_id : UInt8*)
  fun appkit_menu_add_separator(submenu_index : Int32)
  fun appkit_menu_add_app_menu(app_name : UInt8*)
  fun appkit_menu_add_edit_menu
  fun appkit_menu_add_window_menu

  # Alert
  fun appkit_alert(title : UInt8*, message : UInt8*, style : Int32) : Int32
  fun appkit_alert_info(title : UInt8*, message : UInt8*)

  # Open / Save panels
  fun appkit_open_panel(title : UInt8*, types : UInt8*) : UInt8*
  fun appkit_open_folder(title : UInt8*) : UInt8*
  fun appkit_save_panel(title : UInt8*, default_name : UInt8*) : UInt8*

  # Notification
  fun appkit_notify(title : UInt8*, message : UInt8*)

  # Cleanup
  fun appkit_free(ptr : Void*)
end
