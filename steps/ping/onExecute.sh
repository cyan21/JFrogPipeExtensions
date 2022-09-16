
pingJPDs() {
    local success=true

    local iteration=$(find_step_configuration_value "iteration")
    local sleepBetweenIteration=$(find_step_configuration_value "sleepBetweenIteration")
    local mylist=$(find_step_configuration_value "integrationList")

    echo "iteration: $iteration"
    echo "wait: $sleepBetweenIteration"

    echo $mylist
    echo "[INFO] Starting ping ..."
    
    jf -v


    echo "[INFO] Cleanup done"

    $success
}
 
execute_command pingJPDs