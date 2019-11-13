#!/usr/bin/env bash

cd "$(dirname "$0")"
HOMEBREW_BUNDLE_NO_LOCK=1 brew bundle
