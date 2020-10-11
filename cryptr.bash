#!/usr/bin/env bash

set -eo pipefail; [[ $TRACE ]] && set -x

readonly VERSION="2.2.0"
readonly OPENSSL_CIPHER_TYPE="aes-256-cbc"

cryptr_version() {
  echo "cryptr $VERSION"
  echo "Designed by Shashwat__Raj"
}

cryptr_help() {
  echo "Usage: cryptr command <command-specific-options>"
  echo
  cat<<EOF | column -c2 -t -s,
  encrypt <file>, Encrypt file
  decrypt <file.aes>, Decrypt encrypted file
  help, Displays help
  version, Displays the current version
EOF
  echo
}

cryptr_encrypt() {
  local _file="$1"
  if [[ ! -f "$_file" ]]; then
    echo "File not found" 1>&2
    exit 4
  fi

  if [[ ! -z "${CRYPTR_PASSWORD}" ]]; then
    echo "[notice] using environment variable CRYPTR_PASSWORD for the password"
    openssl $OPENSSL_CIPHER_TYPE -salt -pbkdf2 -in "$_file" -out "${_file}.aes" -pass env:CRYPTR_PASSWORD
  else
    openssl $OPENSSL_CIPHER_TYPE -salt -pbkdf2 -in "$_file" -out "${_file}.aes"
  fi
}

cryptr_decrypt() {
local _file="$1"
  if [[ ! -f "$_file" ]]; then
    echo "File not found" 1>&2
    exit 5
  fi

  if [[ ! -z "${CRYPTR_PASSWORD}" ]]; then
    echo "[notice] using environment variable CRYPTR_PASSWORD for the password"
    openssl $OPENSSL_CIPHER_TYPE -d -salt -pbkdf2 -in "$_file" -out "${_file%\.aes}" -pass env:CRYPTR_PASSWORD
  else
    openssl $OPENSSL_CIPHER_TYPE -d -salt -pbkdf2 -in "$_file" -out "${_file%\.aes}"
  fi
}

cryptr_main() {
  local _command="$1"

  if [[ -z $_command ]]; then
    cryptr_version
    echo
    cryptr_help
    exit 0
  fi

  shift 1
  case "$_command" in
    "encrypt")
      cryptr_encrypt "$@"
      ;;

    "decrypt")
      cryptr_decrypt "$@"
      ;;

    "version")
      cryptr_version
      ;;

    "help")
      cryptr_help
      ;;

    *)
      cryptr_help 1>&2
      exit 3
  esac
}

if [[ "$0" == "$BASH_SOURCE" ]]; then
  cryptr_main "$@"
fi
