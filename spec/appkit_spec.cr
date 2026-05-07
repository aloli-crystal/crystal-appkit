require "./spec_helper"
require "yaml"

describe AppKit do
  it "VERSION matche shard.yml (compile-time read, pas de désynchro possible)" do
    yml = YAML.parse(File.read(File.join(__DIR__, "..", "shard.yml")))
    AppKit::VERSION.should eq(yml["version"].as_s)
  end
end

describe AppKit::Menu do
  it "creates a menu builder" do
    # On ne peut pas tester le rendu graphique en CI,
    # mais on vérifie que les classes existent
    AppKit::Menu::SubMenu.should_not be_nil
    AppKit::Menu::CMD.should eq(1)
    AppKit::Menu::SHIFT.should eq(2)
  end
end
