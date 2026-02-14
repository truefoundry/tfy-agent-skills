#!/usr/bin/env bash
# shellcheck disable=SC2030,SC2031
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TFY_API_SH="$REPO_ROOT/skills/_shared/scripts/tfy-api.sh"

TMP_DIR="$(mktemp -d)"
cleanup() {
  if [[ -n "${SERVER_PID:-}" ]]; then
    kill "$SERVER_PID" >/dev/null 2>&1 || true
    wait "$SERVER_PID" >/dev/null 2>&1 || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

assert_exit_code() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  if [[ "$expected" != "$actual" ]]; then
    echo "FAIL: $label expected exit=$expected got=$actual" >&2
    exit 1
  fi
}

assert_contains() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if ! grep -Fq "$needle" "$file"; then
    echo "FAIL: $label expected '$needle' in $file" >&2
    exit 1
  fi
}

# Start local mock HTTP server on an ephemeral port.
PORT_FILE="$TMP_DIR/port.txt"
python3 - "$PORT_FILE" <<'PY' &
import json
import pathlib
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer

port_file = pathlib.Path(sys.argv[1])

class Handler(BaseHTTPRequestHandler):
    def _write(self, code, payload):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path == "/ok":
            self._write(200, {"ok": True})
        elif self.path == "/notfound":
            self._write(404, {"error": "not found"})
        else:
            self._write(400, {"error": "bad request"})

    def log_message(self, *_):
        return

server = HTTPServer(("127.0.0.1", 0), Handler)
port_file.write_text(str(server.server_port))
server.serve_forever()
PY
SERVER_PID=$!

for _ in $(seq 1 50); do
  if [[ -s "$PORT_FILE" ]]; then
    break
  fi
  sleep 0.1
done

if [[ ! -s "$PORT_FILE" ]]; then
  echo "FAIL: mock server did not start" >&2
  exit 1
fi

PORT="$(cat "$PORT_FILE")"

# 1) Missing env var should fail fast.
(
  cd "$TMP_DIR"
  unset TFY_BASE_URL TFY_API_KEY
  set +e
  "$TFY_API_SH" GET /ok >"$TMP_DIR/out1" 2>"$TMP_DIR/err1"
  ec=$?
  set -e
  assert_exit_code 1 "$ec" "missing env"
  assert_contains 'TFY_BASE_URL not set' "$TMP_DIR/err1" "missing env message"
)

# 2) Validate method handling.
(
  cd "$TMP_DIR"
  export TFY_BASE_URL="http://127.0.0.1:$PORT"
  export TFY_API_KEY="dummy"
  set +e
  "$TFY_API_SH" TRACE /ok >"$TMP_DIR/out2" 2>"$TMP_DIR/err2"
  ec=$?
  set -e
  assert_exit_code 1 "$ec" "invalid method"
  assert_contains 'METHOD must be GET, POST, PUT, PATCH, or DELETE' "$TMP_DIR/err2" "invalid method message"
)

# 3) Happy path returns body and exits 0.
(
  cd "$TMP_DIR"
  export TFY_BASE_URL="http://127.0.0.1:$PORT"
  export TFY_API_KEY="dummy"
  "$TFY_API_SH" GET /ok >"$TMP_DIR/out3"
  assert_contains '"ok": true' "$TMP_DIR/out3" "success response"
)

# 4) HTTP 404 must exit non-zero.
(
  cd "$TMP_DIR"
  export TFY_BASE_URL="http://127.0.0.1:$PORT"
  export TFY_API_KEY="dummy"
  set +e
  "$TFY_API_SH" GET /notfound >"$TMP_DIR/out4" 2>"$TMP_DIR/err4"
  ec=$?
  set -e
  if [[ "$ec" -eq 0 ]]; then
    echo "FAIL: 404 should return non-zero" >&2
    exit 1
  fi
)

echo "tfy-api.sh tests passed."
