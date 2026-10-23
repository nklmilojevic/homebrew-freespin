cask "freespin" do
  version "0.2.0"
  sha256 "5b5805bbb0cc1b42f8afa6dd00921ce50327afd38fd3b2e3f4a9d10e155b9baa"

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
