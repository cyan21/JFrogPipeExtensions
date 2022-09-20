
pingJPDs() {
    local success=0
    cnt=0
    i=0
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
        echo "start round : cnt = $cnt"

        echo "[INFO] Configuring CLI ..."
        configure_jfrog_cli --artifactory-url "${!url}/artifactory" --access-token "${!token}" --server-name jpd_$cnt
        let "cnt+=1"
    done

    jf c s

    for (( rt=0; rt < $cnt; rt++ )); do
        echo "[INFO] Pinging jpd_${rt} ..."

        # for retries
        while [[ $ping_ok -eq 0 && $i -le $iteration ]]; do  
            jf rt ping --server-id jpd_$rt
            if [[ $? -eq 0 ]]; then 
                echo "[INFO] Ping tentative $i / $iteration = OK"
                ping_ok=1
                success=1
            else 
                echo "[INFO] Ping tentative $i / $iteration = KO, will retry in  $sleepBetweenIteration second(s)..."
                sleep $sleepBetweenIteration
                let "i+=1"
            fi
        done
        
        if [[ $ping_ok -eq 0 ]]; then 
            success=0
            break
        fi
        ping_ok=0
        i=0
        echo "end round rt : $rt"
    done    

    echo $success
}
 
execute_command pingJPDs