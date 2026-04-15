module AppKit
  module Notification
    # Envoyer une notification système macOS
    def self.send(title : String, message : String)
      LibAppKit.appkit_notify(title.to_unsafe, message.to_unsafe)
    end
  end
end
