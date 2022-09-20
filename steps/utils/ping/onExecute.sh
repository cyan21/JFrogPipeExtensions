
pingJPDs() {
    local success=0
    local i=1
    local ping_ok=0
    local iteration=$(find_step_configuration_value "iteration")
    local sleepBetweenIteration=$(find_step_configuration_value "sleepBetweenIteration")
    local mylist=$(find_step_configuration_value "integrations")

    echo "iteration: $iteration"
    echo "wait: $sleepBetweenIteration"

    # echo $mylist

    for jpd in `echo $mylist | jq -r '.[].name'`; do 
        url="int_${jpd}_url"
        token="int_${jpd}_accessToken"
        # echo ${!url}
        # echo ${!token}
        echo "start round : i = $i"

        echo "[INFO] Configuring CLI ..."
        configure_jfrog_cli --artifactory-url "${!url}/artifactory" --access-token "${!token}" --server-name jpd_$i
        jf c s
        echo "[INFO] Pinging jpd_$i ..."
        cnt=1
        while [[ $ping_ok -eq 0 && $cnt -le $iteration ]]; do  
            jf rt ping --server-id jpd_$i
            if [[ $? -eq 0 ]]; then 
                echo "[INFO] Ping tentative $cnt / $iteration = OK"
                ping_ok=1
                success=1
            else 
                echo "[INFO] Ping tentative $cnt / $iteration = KO, will retry in  $sleepBetweenIteration second(s)..."
                sleep $sleepBetweenIteration
                let "cnt+=1"
            fi
        done
        
        if [[ $ping_ok -eq 0 ]]; then 
            success=0
            break
        fi
        ping_ok=0
        let "i+=1"
        echo "end round i : $i"
    done    

    echo $success
}
 
execute_command pingJPDs