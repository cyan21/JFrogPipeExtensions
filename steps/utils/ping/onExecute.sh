
pingJPDs() {
    local success=true

    local iteration=$(find_step_configuration_value "iteration")
    local sleepBetweenIteration=$(find_step_configuration_value "sleepBetweenIteration")
    local mylist=$(find_step_configuration_value "integrationList")

    echo "iteration: $iteration"
    echo "wait: $sleepBetweenIteration"

    echo $mylist
    for jpd in `echo $mylist | jq -r '.[]'`; do 
        echo $jpd
        url="int_${jpd}_url"
        echo $url
        echo ${!url}
    done

    echo "[INFO] Starting ping ..."
    
    jf -v


    echo "[INFO] Cleanup done"

    $success
}
 
execute_command pingJPDs