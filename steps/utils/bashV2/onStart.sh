
configureCustomStep() {
    local ping_ok=0
    local cli_plugin=$(find_step_configuration_value "cliPlugin")
    local intgs=$(find_step_configuration_value "integrations")
    local platform_intg=""
    local found=false

    echo "cliPlugin: $cli_plugin"
    echo "integration: $intgs"

    # look for the JFrog Platform Access Token integration
    for intg in `echo $intgs | jq -r '.[].name'`; do 
        token="int_${intg}_accessToken"
        # echo ${token}
        # echo ${!token}

        if [[ $found != 'true' && -n ${!token} ]]; then
            platform_intg=$intg
            found=true
        fi
    done

    # echo  "platfom integration : $platform_intg"

    if [[ ! -n $platform_intg ]]; then
        echo "[ERROR] One JFrog Platform Access Token is required for this step."
        exit 1
    fi

    echo "[INFO] Configuring CLI ..."
    local url="int_${platform_intg}_url"
    local acc_token="int_${platform_intg}_accessToken"
    # echo ${!url}
    # echo ${!token}
    configure_jfrog_cli --artifactory-url "${!url}/artifactory" --access-token "${!acc_token}" --server-name jpd
    jf c s
    jf rt ping

    if [[ -n $cli_plugin ]]; then
        jf plugin install $cli_plugin

        if [[ $? -eq 1 ]]; then
            echo "[ERROR] Could not install or find the $cli_plugin CLI plugin."
            exit 1
        fi 

        # removed the plugin version if specified
        jf $(echo $cli_plugin | cut -d"@" -f1) -v 

        if [[ $? -eq 1 ]]; then
            echo "[ERROR] Could not execute the $cli_plugin CLI plugin."
            exit 1
        fi 
    fi

    return 0
}
 
execute_command configureCustomStep