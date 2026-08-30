class LoggerServer < Formula
  desc "Self-hosted remote logger for mobile apps, with a live browser tail"
  homepage "https://github.com/sudhi001/logger_server"
  url "https://github.com/sudhi001/logger_server/archive/refs/tags/v3.3.0.tar.gz"
  sha256 "3a033ed97881b69c9a2cf0501d0ccd1e61cc197e7f51b7174126f4f7f30ae652"
  license "MIT"
  head "https://github.com/sudhi001/logger_server.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  def caveats
    <<~EOS
      Start it with an admin token of your choosing; that token is how you sign
      in to the dashboard:

        LOGGER_ADMIN_TOKEN=$(openssl rand -hex 24) logger_server

      Then open http://localhost:8080, sign in, and create a device under
      "Devices" to get a token for your app.

      Without LOGGER_ADMIN_TOKEN the server generates one and prints it at
      startup, but it changes on every restart.

      Logs are stored in ./logs.db relative to the working directory. Set
      LOGGER_DB_PATH to keep them somewhere stable, for example:

        LOGGER_DB_PATH=#{var}/logger-server/logs.db
    EOS
  end

  service do
    run [opt_bin/"logger_server"]
    keep_alive true
    working_dir var/"logger-server"
    log_path var/"log/logger-server.log"
    error_log_path var/"log/logger-server.log"
    environment_variables LOGGER_DB_PATH: var/"logger-server/logs.db"
  end

  test do
    port = free_port
    db = testpath/"test.db"

    pid = spawn({ "LOGGER_PORT" => port.to_s,
                  "LOGGER_DB_PATH" => db.to_s,
                  "LOGGER_ADMIN_TOKEN" => "lgra_brew_test_token" },
                bin/"logger_server")

    begin
      # Wait for it to bind rather than sleeping a fixed amount.
      30.times do
        sleep 0.2
        break if quiet_system("curl", "-sf", "http://127.0.0.1:#{port}/healthz")
      end

      assert_equal "ok", shell_output("curl -s http://127.0.0.1:#{port}/healthz")

      # Reads are gated: no credential must be refused.
      code = shell_output("curl -s -o /dev/null -w '%{http_code}' " \
                          "http://127.0.0.1:#{port}/api/v1/logs/recent")
      assert_equal "401", code

      # With the admin token, registering a device returns a one-time token.
      device = shell_output("curl -s -X POST http://127.0.0.1:#{port}/api/v1/devices " \
                            "-H 'x-admin-token: lgra_brew_test_token' " \
                            "-H 'content-type: application/json' " \
                            "-d '{\"name\":\"brew-test\"}'")
      assert_match "lgrd_", device

      assert_predicate db, :exist?
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
