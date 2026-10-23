class Freespinctl < Formula
  desc "Command-line tool and daemon for Logitech HID++ mice"
  homepage "https://github.com/nklmilojevic/freespin"
  url "https://github.com/nklmilojevic/freespin/releases/download/v0.3.0/freespinctl-0.3.0-macos.tar.gz"
  sha256 "9ac2895d7e86b2c39166b701916ca4dc98b66cb6b4f274975cb755c5e103c1dc"

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
      grant them again after every `brew upgrade freespinctl`.

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
