class Mdsmedia < Formula
  desc "Send and test SMS through the MDS Media gateway"
  homepage "https://github.com/sudhi001/mdsmedia"
  url "https://github.com/sudhi001/mdsmedia/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "a75fb7df1dcf792b969a72af6ba7bf71fc392f019a27c6b8c6d6b273178f7839"
  license "MIT"
  head "https://github.com/sudhi001/mdsmedia.git", branch: "main"

  depends_on "rust" => :build

  def install
    # The binary lives behind the "cli" feature so the library stays lean.
    system "cargo", "install", "--features", "cli", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mdsmedia --version")

    creds = "--username XXXXXX --api-key SECRET --sender-id SENDER"

    # Config validation is offline and must not print the key in full.
    output = shell_output("#{bin}/mdsmedia #{creds} check")
    assert_match "configuration OK", output
    assert_match "https://mdssend.in/api.php", output
    refute_match "SECRET", output

    # Number normalization is offline: a bare local number gains the
    # country code, and a short one is rejected with a non-zero exit.
    output = shell_output("#{bin}/mdsmedia #{creds} --country-code 91 normalize 9876543210")
    assert_match "919876543210", output

    output = shell_output("#{bin}/mdsmedia #{creds} normalize 12345", 1)
    assert_match "invalid phone number", output

    # --dry-run builds the request without contacting the gateway.
    output = shell_output("#{bin}/mdsmedia #{creds} --country-code 91 --dry-run " \
                          "otp --to 9876543210 --code 482913")
    assert_match "DRY RUN", output
    assert_match "919876543210", output
  end
end
