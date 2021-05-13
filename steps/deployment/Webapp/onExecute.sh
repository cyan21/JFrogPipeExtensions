
cleanupArtifact() {
    local success=true

    local technology=$(find_step_configuration_value "technology")
    local appserver=$(find_step_configuration_value "appserver")
    local webserver=$(find_step_configuration_value "webserver")
    local ansible_deploy=$(find_step_configuration_value "ansible")

    local role=`echo $ansible_deploy | jq -r ".role"`
    local inventory=`echo $ansible_deploy | jq -r ".inventory"`

    echo "Technology : $technology"
    echo "Application server: $appserver"
    echo "Web server: $webserver"
    echo "Ansible info : $ansible_deploy"
    echo "Ansible role : $role"
    echo "Ansible inventory : $inventory"

    echo "[INFO] Starting deployment ..."
    
    # res_timeUnit_workaround=$(find_resource_variable my_cleanup_policy timeUnit)
    # echo "timeUnit: $res_timeUnit_workaround"

    # res_timeUnit=$(find_resource_variable $cleanup_policy timeUnit)    
    # echo "timeUnit: $res_timeUnit"
    
    echo "[INFO] Deployment done"


    $success
}
 
execute_command cleanupArtifact