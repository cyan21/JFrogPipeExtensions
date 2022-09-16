
pingJPDs() {
    local success=true

    local iteration=$(find_step_configuration_value "iteration")
    local sleepBetweenIteration=$(find_step_configuration_value "sleepBetweenIteration")
    local mylist=$(find_step_configuration_value "integrationList")

    echo "iteration: $iteration"
    echo "wait: $sleepBetweenIteration"

    echo $mylist
    for jpd in `echo $mylist | jq '.[]'`; do 
        echo $jpd
        echo ${int_yann_platform_token_url}
    done

        echo "[INFO] Starting ping ..."
    myurl=$(find_integration_variable yann_platform_token url)
    
    jf -v


    echo "[INFO] Cleanup done"

    $success
}
 
execute_command pingJPDs