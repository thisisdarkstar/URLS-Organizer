#!/usr/bin/env bats

load 'bats-support/load'
load 'bats-assert/load'

SCRIPT="$BATS_TEST_DIRNAME/organize_domains.sh"

setup() {
  TMPDIR="$(mktemp -d)"
  cd "$TMPDIR"
}

teardown() {
  rm -rf "$TMPDIR"
}

@test "Extracts hostname from URL and groups by root domain" {
  echo "https://blog.example.com/path" > input.txt
  run "$SCRIPT" input.txt
  assert_success

  run test -d "example.com"
  assert_success

  run test -f "example.com/subdomains.txt"
  assert_success

  run cat example.com/subdomains.txt
  assert_line "blog.example.com"
}

@test "Handles ports, paths, query, and fragments properly" {
  echo "https://api.dev.example.com:8443/v1?token=abc#fragment" > input.txt
  run "$SCRIPT" input.txt
  assert_success

  run test -f "example.com/subdomains.txt"
  assert_success

  run cat example.com/subdomains.txt
  assert_line "api.dev.example.com"
}

@test "Groups multiple subdomains and deduplicates" {
  cat <<EOF > input.txt
shop.site.com
https://shop.site.com/path
dev.shop.site.com
shop.site.com?ref=1
EOF

  run "$SCRIPT" input.txt
  assert_success

  run test -f "site.com/subdomains.txt"
  assert_success

  run wc -l site.com/subdomains.txt
  assert_output --partial "2"

  run cat site.com/subdomains.txt
  assert_line "shop.site.com"
  assert_line "dev.shop.site.com"
}

@test "Identifies root domain with SLDs like .co.uk" {
  echo "cdn.test.example.co.uk" > input.txt
  run "$SCRIPT" input.txt
  assert_success

  run test -f "example.co.uk/subdomains.txt"
  assert_success

  run cat example.co.uk/subdomains.txt
  assert_line "cdn.test.example.co.uk"
}

@test "Handles raw subdomain with query string (no protocol)" {
  echo "mail.example.com?utm=campaign" > input.txt
  run "$SCRIPT" input.txt
  assert_success

  run test -f "example.com/subdomains.txt"
  assert_success

  run cat example.com/subdomains.txt
  assert_line "mail.example.com"
}

@test "Skips IPs, localhost, and comments" {
  cat <<EOF > input.txt
# comment
localhost
http://127.0.0.1
EOF

  run "$SCRIPT" input.txt
  assert_success
  assert_output --partial "No valid domains were processed."

  run bash -c "find . -type f -name 'subdomains.txt' | wc -l"
  assert_success
  assert_output "0"
}

@test "Reads from stdin if no input file is provided" {
  run bash -c 'echo "one.example.com" | '"$SCRIPT"
  assert_success

  run test -f "example.com/subdomains.txt"
  assert_success

  run cat example.com/subdomains.txt
  assert_line "one.example.com"
}

@test "Handles credentials and ports in URL" {
  echo "https://user:pass@secure.login.dev.io:8080" > input.txt
  run "$SCRIPT" input.txt
  assert_success

  run test -f "dev.io/subdomains.txt"
  assert_success

  run cat dev.io/subdomains.txt
  assert_line "secure.login.dev.io"
}

@test "shows usage message when no arguments and no stdin" {
  run bash -c "$SCRIPT"
  assert_failure
  assert_output --partial "Usage:"
  assert_output --partial "<input_file>"
}
