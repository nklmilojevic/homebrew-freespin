#!/usr/bin/env bash
# Regenerates Casks/freespin.rb and Formula/freespinctl.rb for the given
# release tag (e.g. v0.2.0) from the release's SHA256SUMS asset.
set -euo pipefail

tag="${1:?usage: bump.sh vX.Y.Z}"
if ! [[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid release tag: $tag" >&2
  exit 1
fi
version="${tag#v}"
repo="nklmilojevic/freespin"
dmg="Freespin-${version}.dmg"
tarball="freespinctl-${version}-macos.tar.gz"

sums="$(gh release download "$tag" --repo "$repo" --pattern SHA256SUMS --output -)"
checksum() {
  local sum
  sum="$(awk -v f="$1" '$2 == f || $2 == "*" f { print $1 }' <<<"$sums")"
  if ! [[ "$sum" =~ ^[0-9a-f]{64}$ ]]; then
    echo "No checksum for $1 in SHA256SUMS of $tag" >&2
    exit 1
  fi
  echo "$sum"
}
dmg_sha="$(checksum "$dmg")"
tarball_sha="$(checksum "$tarball")"

cat > Casks/freespin.rb <<EOF
cask "freespin" do
  version "${version}"
  sha256 "${dmg_sha}"

  url "https://github.com/${repo}/releases/download/v#{version}/Freespin-#{version}.dmg"
  name "Freespin"
  desc "Native replacement for Logi Options+"
  homepage "https://github.com/${repo}"

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
EOF

cat > Formula/freespinctl.rb <<EOF
class Freespinctl < Formula
  desc "Command-line tool and daemon for Logitech HID++ mice"
  homepage "https://github.com/${repo}"
  url "https://github.com/${repo}/releases/download/${tag}/${tarball}"
  sha256 "${tarball_sha}"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :macos

  def install
    bin.install "freespinctl"
  end

  def caveats
    <<~EOS
      The freespinctl daemon needs Accessibility and Input Monitoring access.
      Grant both to the freespinctl binary in System Settings > Privacy & Security:
        #{rack}/#{pkg_version}/bin/freespinctl
      macOS ties these grants to the binary's real (versioned Cellar) path, so
      grant them again after every \`brew upgrade freespinctl\`.

      Do not run the daemon while Freespin.app is running.

      Configuration lives at ~/.config/freespin/config.json.
    EOS
  end

  service do
    run [opt_bin/"freespinctl", "daemon"]
    keep_alive true
    log_path var/"log/freespinctl.log"
    error_log_path var/"log/freespinctl.log"
  end

  test do
    assert_match "usage: freespinctl", shell_output("#{bin}/freespinctl 2>&1", 64)
  end
end
EOF
