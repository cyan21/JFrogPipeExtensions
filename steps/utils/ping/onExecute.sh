
pingJPDs() {
    local success=true

    local iteration=$(find_step_configuration_value "iteration")
    local sleepBetweenIteration=$(find_step_configuration_value "sleepBetweenIteration")
    # local mylist=$(find_step_configuration_value "integrationList")
    local mylist=$(find_step_configuration_value "integrations")

    echo "iteration: $iteration"
    echo "wait: $sleepBetweenIteration"

    echo $mylist
    i=0
    for jpd in `echo $mylist | jq -r '.[]'`; do 
        url="int_${jpd}_url"
        token="int_${jpd}_accessToken"
        # echo $url
        echo ${!url}
        echo ${!token}
        let "i+=1"
        configure_jfrog_cli --artifactory-url "${!url}/artifactory" --access-token "${!token}" --server-name jpd_$i
    done

    echo "[INFO] Starting ping ..."
    
    jf -v
    jf c s
    jf rt ping --server-id jpd_1


    echo "[INFO] Cleanup done"

    $success
}
 
execute_command pingJPDs