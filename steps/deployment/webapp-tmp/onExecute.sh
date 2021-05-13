
cleanupArtifact() {
    local success=true

    local technology=$(find_step_configuration_value "technology")
    local appserver=$(find_step_configuration_value "appserver")
    local webserver=$(find_step_configuration_value "webserver")
    local ansible_deploy=$(find_step_configuration_value "ansible")

    local time_unit=`echo $policies | jq -r ".[].timeUnit"`
    local time_interval=`echo $policies | jq -r ".[].timeInterval"`

    echo "Technology : $technology"
    echo "Application server: $appserver"
    echo "Web server: $webserver"
    echo "Ansible info : $ansible_deploy"

    echo "[INFO] Starting cleanup ..."
    
    # res_timeUnit_workaround=$(find_resource_variable my_cleanup_policy timeUnit)
    # echo "timeUnit: $res_timeUnit_workaround"

    # res_timeUnit=$(find_resource_variable $cleanup_policy timeUnit)    
    # echo "timeUnit: $res_timeUnit"
    
    $success
}
 
execute_command cleanupArtifact