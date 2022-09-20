
pingJPDs() {
    local success=false

    local iteration=$(find_step_configuration_value "iteration")
    local sleepBetweenIteration=$(find_step_configuration_value "sleepBetweenIteration")
    local mylist=$(find_step_configuration_value "integrations")

    echo "iteration: $iteration"
    echo "wait: $sleepBetweenIteration"

    # echo $mylist
    i=0
    for jpd in `echo $mylist | jq -r '.[].name'`; do 
        url="int_${jpd}_url"
        token="int_${jpd}_accessToken"
        # echo ${!url}
        # echo ${!token}
        let "i+=1"
        echo "[INFO] Configuring CLI ..."
        configure_jfrog_cli --artifactory-url "${!url}/artifactory" --access-token "${!token}" --server-name jpd_$i
        jf -v

        echo "[INFO] Configuration done"
        echo "[INFO] Pinging jpd_$i ..."
        i=1
        while [[ !success && i <= $iteration ]]; do  
            jf rt ping --server-id jpd_$i
            if [[ $? -eq 0 ]]; then 
                success=true
            else 
                echo "[INFO] Ping tentative $1 / $iteration = KO, will retry in  $sleepBetweenIteration second(s)..."
                sleep $sleepBetweenIteration
                let "i+=1"
            fi
        done
        
        if [[ !success ]]; then break; fi

    done    

    $success
}
 
execute_command pingJPDs