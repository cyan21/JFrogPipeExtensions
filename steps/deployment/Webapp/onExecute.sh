
deployWebApp() {
    local success=true

    local technology=$(find_step_configuration_value "technology")
    local appserver=$(find_step_configuration_value "appserver")
    local webserver=$(find_step_configuration_value "webserver")
    local ansible_deploy=$(find_step_configuration_value "ansible")

    local role=`echo $ansible_deploy | jq -r ".role"`
    local inventory=`echo $ansible_deploy | jq -r ".inventory"`

    local webhook_rsc_name=$(get_resource_name --type IncomingWebhook --operation IN)
    echo "Webhook name: $webhook_rsc_name"

    local vm_rsc_name=$(get_resource_name --type VmCluster --operation IN)
    echo "VM Cluster name: $vm_rsc_name"

    local sshkey=$(find_resource_variable $vm_rsc_name sshkey)
    echo "SSH Key name: $sshkey"

    local ips=$(find_resource_variable $vm_rsc_name targets)
    echo "target IPs : $ips"

    echo "Technology : $technology"
    echo "Application server: $appserver"
    echo "Web server: $webserver"
    echo "Ansible info : $ansible_deploy"
    echo "Ansible role : $role"
    echo "Ansible inventory : $inventory"

    echo "[INFO] Starting deployment ..."
    
    # echo "$res_wh_jenkins_payload" | jq '.' > payload.json
    # cat payload.json

    # ssh -i ~/.ssh/vm_group ec2-user@${res_vm_group_targets_0} "uname -a &&./test.sh"
    
    echo "[INFO] Deployment done"


    $success
}
 
execute_command deployWebApp