
configureCustomStep() {
    local cli_plugin=$(find_step_configuration_value "cliPlugin")
    local intgs=$(find_step_configuration_value "integrations")
    local found=false

    echo "cliPlugin: $cli_plugin"
    echo "integration: $intgs"

    # look for the JFrog Platform Access Token integration
    for intg in `echo $intgs | jq -r '.[].name'`; do 
        token="int_${intg}_accessToken"
        # echo ${token}
        # echo ${!token}

        if [[ -n ${!token} ]]; then
            echo "[INFO]platfom integration : $intg"
            echo "[INFO] Configuring CLI ..."

            local url="int_${intg}_url"
            # echo ${!url}
            # echo ${!token}
            configure_jfrog_cli --artifactory-url "${!url}/artifactory" --access-token "${!token}" --server-name $intg
            jf c s
            jf rt ping
            
            if [[ $found != 'true' ]]; then
                found=true
            fi
        fi 
    done


    if [[ ! -n $found ]]; then
        echo "[ERROR] One JFrog Platform Access Token is required for this step."
        exit 1
    fi



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