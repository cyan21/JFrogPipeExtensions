
pingJPDs() {
    local success=0

    local iteration=$(find_step_configuration_value "iteration")
    local sleepBetweenIteration=$(find_step_configuration_value "sleepBetweenIteration")
    local mylist=$(find_step_configuration_value "integrations")

    echo "iteration: $iteration"
    echo "wait: $sleepBetweenIteration"

    # echo $mylist
    i=1
    for jpd in `echo $mylist | jq -r '.[].name'`; do 
        url="int_${jpd}_url"
        token="int_${jpd}_accessToken"
        # echo ${!url}
        # echo ${!token}

        echo "[INFO] Configuring CLI ..."
        configure_jfrog_cli --artifactory-url "${!url}/artifactory" --access-token "${!token}" --server-name jpd_$i
        # jf -v
        echo "[INFO] Pinging jpd_$i ..."
        cnt=1
        while [[ $success -eq 0 && $cnt -le $iteration ]]; do  
            jf rt ping --server-id jpd_$i
            if [[ $? -eq 0 ]]; then 
                echo "[INFO] Ping tentative $cnt / $iteration = OK"
                success=1
            else 
                echo "[INFO] Ping tentative $cnt / $iteration = KO, will retry in  $sleepBetweenIteration second(s)..."
                sleep $sleepBetweenIteration
                let "cnt+=1"
            fi
        done
        
        if [[ $success -eq 0 ]]; then 
            break
        else
            let "i+=1"
        fi
    done    

    $success
}
 
execute_command pingJPDs