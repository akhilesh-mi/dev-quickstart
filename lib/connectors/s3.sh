# shellcheck shell=bash
# S3 raw-archive (read-only) — for fetching raw archived API responses.

c_s3_status() { [ -f "$HOME/.mi_s3_creds.env" ]; }

c_s3_setup() {
  pointer s3
  local ak sk region
  prompt_value  ak     "AWS access key id"
  prompt_secret sk     "AWS secret access key"
  prompt_value  region "AWS region" "ap-south-1"
  [ -z "$ak" ] || [ -z "$sk" ] && { err "access key and secret are both required"; return 1; }

  write_kv "$HOME/.mi_s3_creds.env" AWS_ACCESS_KEY_ID     "$ak"
  write_kv "$HOME/.mi_s3_creds.env" AWS_SECRET_ACCESS_KEY "$sk"
  write_kv "$HOME/.mi_s3_creds.env" AWS_DEFAULT_REGION    "$region"
  ok "Saved → ~/.mi_s3_creds.env (0600)"
  dim "Use read-only keys only. These archives can contain sensitive data — handle with care."
}
