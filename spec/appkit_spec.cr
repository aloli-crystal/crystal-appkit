require "./spec_helper"

describe AppKit do
  it "has a version" do
    AppKit::VERSION.should eq("0.1.0")
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
