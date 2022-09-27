
configureCustomStep() {
    local success=0
    local ping_ok=0
    local cli_plugin=$(find_step_configuration_value "cliPlugin")
    local intgs=$(find_step_configuration_value "integrations")
    local platform_intg=""

    echo "cliPlugin: $cli_plugin"
    echo "integration: $intgs"

    # look for the JFrog Platform Access Token integration
    for intg in `echo $intgs | jq -r '.[].name'`; do 
        token="int_${platform_intg}_accessToken"
        echo ${token}
        echo ${!token}

        if [[ ${!token} -ne "" ]]; then
            platform_intg=$intg
            break
        fi
    done

    echo  "platfom integration : $platform_intg"

    if [[ $platform_intg -eq "" ]]; then
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

    jf plugin install $cli_plugin

    if [[ $? -eq 1 ]]; then
        echo "[ERROR] Could not install or find the $cli_plugin CLI plugin."
        exit 1
    fi 

    jf $cli_plugin -v 

    if [[ $? -eq 1 ]]; then
        echo "[ERROR] Could not execute the $cli_plugin CLI plugin."
        exit 1
    fi 
    
    echo 1
}
 
execute_command configureCustomStep