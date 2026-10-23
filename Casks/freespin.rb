cask "freespin" do
  version "0.3.0"
  sha256 "03042ee14e95793d63da34c4c02d8bf7bd06da2074cefdf0f93fc101664c7787"

  url "https://github.com/nklmilojevic/freespin/releases/download/v#{version}/Freespin-#{version}.dmg"
  name "Freespin"
  desc "Native replacement for Logi Options+"
  homepage "https://github.com/nklmilojevic/freespin"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :sonoma

  app "Freespin.app"

  uninstall quit: "dev.nkl.freespin"

  zap trash: "~/Library/Application Support/Freespin"
end
