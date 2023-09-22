onePasswordAccounts=$(op account list)

function getOnePasswordAccount() {
    local shortName="$1"

    $VERBOSE_RUN _i "Getting 1Password Account for %s" "$shortName"
    echo "$onePasswordAccounts" | grep "^$shortName\\s" || echo ""
}

function accurateOnePasswordAccount() {
    local shortName="$1"
    local address="$2"
    local email="$3"

    $VERBOSE_RUN _i "Checking accuracy of 1Password account for %s" "$shortName"
    local accurate=$(echo "$(getOnePasswordAccount "$shortName")" | grep "^$shortName\\s\\+https://$address\\s\\+$email\\s" || echo "")
    if [[ -z "$accurate" ]]; then
        _iError "1Password account '%s' already exists but with different configuration" "$shortName"
        _iError "Please remove the account before applying"
        exit 1
    fi
}
