
cleanupArtifact() {
    local success=true

    local dry_run=$(find_step_configuration_value "dryRun")
    local policies=$(find_step_configuration_value "policies")
    local time_unit=`echo $policies | jq -r ".[].timeUnit"`
    local time_interval=`echo $policies | jq -r ".[].timeInterval"`

    echo "DRY RUN MODE: $dry_run"
    echo "list of policies: $policies"
    echo "Time Unit: $time_unit"
    echo "Time Interval: $time_interval"

    echo "[INFO] Starting cleanup ..."
    
    # res_timeUnit_workaround=$(find_resource_variable my_cleanup_policy timeUnit)
    # echo "timeUnit: $res_timeUnit_workaround"

    # res_timeUnit=$(find_resource_variable $cleanup_policy timeUnit)    
    # echo "timeUnit: $res_timeUnit"
    
    jfrog --version

    jfrog plugin install rt-cleanup

    for repo in `echo $policies | jq -r ".[].repositories[]"`; do 
        echo "jfrog rt-cleanup clean $repo --time-unit=$time_unit --no-dl=$time_interval"; 

        if [[ $dry_run == "false" ]]; then
            jfrog rt-cleanup clean $repo --time-unit=$time_unit --no-dl=$time_interval
        else
            echo "No exec"
        fi 
    done

    echo "[INFO] Cleanup done"

    $success
}
 
execute_command cleanupArtifact