
configureCustomStep() {
    local success=0
    local ping_ok=0
    local cliPlugin=$(find_step_configuration_value "cliPlugin")
    local intgs=$(find_step_configuration_value "integrations")
    local platform_intg=""

    echo "cliPlugin: $cliPlugin"
    echo "integration: $intgs"

    # look for the JFrog Platform Access Token integration
    for intg in `echo $intgs | jq -r '.[].name'`; do 
        if [[ $token -ne "" ]]; then
            platform_intg=$intg
            break
        fi
    done

    if [[ $platform_intg -eq "" ]]; then
        echo "[ERROR] One JFrog Platform Access Token is required for this step."
        exit 1
    fi

    echo "[INFO] Configuring CLI ..."
    local url="int_${platform_intg}_url"
    local token="int_${platform_intg}_accessToken"
    # echo ${!url}
    # echo ${!token}
    configure_jfrog_cli --artifactory-url "${!url}/artifactory" --access-token "${!token}" --server-name jpd
    jf c s
    jf rt ping

    jf plugin install $cliPlugin

    if [[ $? -eq 1 ]]; then
        echo "[ERROR] Could not install or find the $cliPlugin CLI plugin."
        exit 1
    fi 

    jf $cliPlugin -v 

    if [[ $? -eq 1 ]]; then
        echo "[ERROR] Could not execute the $cliPlugin CLI plugin."
        exit 1
    fi 
    
    echo 1
}
 
execute_command configureCustomStep