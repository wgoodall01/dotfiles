#!/usr/bin/env bash

export CFG_GUI=false   # no GUI in container
export CFG_SSH=false   # don't decrypt 
export CFG_CLOUD=true  # Enable installing of cloud stuff?

# Language configuration
export CFG_LANG_NODEJS=true 
export CFG_LANG_GOLANG=true
export CFG_LANG_RUBY=false
export CFG_LANG_JAVA=false
export CFG_LANG_CPP=true

# Disabled, this should be set on first boot in container
export CRYPTO_PW="" 
