require "./appkit/lib_appkit"
require "./appkit/application"
require "./appkit/menu"
require "./appkit/dialog"
require "./appkit/notification"

module AppKit
  # Lue au compile-time depuis `shard.yml` via le macro `read_file` —
  # cf. `feedback_shard_version_macro.md` (mémoire ALOLI). Évite la
  # désynchronisation entre la constante Crystal et le `version:` du
  # `shard.yml`.
  VERSION = {{
              (read_file("#{__DIR__}/../shard.yml")
                .lines
                .find(&.starts_with?("version:")) || "version: 0.0.0")
                .gsub(/^version:\s*/, "")
                .chomp
            }}
end
