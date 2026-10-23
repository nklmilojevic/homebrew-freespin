class Freespinctl < Formula
  desc "Command-line tool and daemon for Logitech HID++ mice"
  homepage "https://github.com/nklmilojevic/freespin"
  url "https://github.com/nklmilojevic/freespin/releases/download/v0.2.0/freespinctl-0.2.0-macos.tar.gz"
  sha256 "34028c546780645ec078b4f70a106ad0915e66f2df6da7baf61d2752a7c90bc7"

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
        #{opt_bin}/freespinctl
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
