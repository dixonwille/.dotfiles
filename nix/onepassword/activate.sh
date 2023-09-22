function addOnePasswordAccountIfNotExists() {
    local shortName="$1"
    local address="$2"
    local email="$3"

    local account=$(getOnePasswordAccount "$shortName")
    if [[ -z "$account" ]]; then
        $VERBOSE_RUN _i "Adding 1Password account for %s" "$shortName"
        "$DRY_RUN_CMD" op account add --address "$address" --email "$email" --shorthand "$shortName" > "$DRY_RUN_NULL"
    fi
}

function signinOnePasswordAccount() {
    local shortName="$1"

    $VERBOSE_RUN _i "Signing in to 1Password account for %s" "$shortName"
    eval "$(op signin --account "$shortName")"
}

function injectOnePasswordIntoFile() {
    local fromFile="$1"
    local toFile="$2"
    if [ -v DRY_RUN ]; then
        toFile=/dev/stdout
    fi

    $VERBOSE_RUN _i "Injecting 1Password secrets from %s to %s" "$fromFile" "$toFile"
    cat "$fromFile" | "$DRY_RUN_CMD" op inject >> "$toFile"
}
