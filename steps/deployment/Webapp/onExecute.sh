
deployWebApp() {
    local success=true

    local dry_run=$(find_step_configuration_value "dryRun")
    local comment=$(find_step_configuration_value "comment")

    local web_app=$(find_step_configuration_value "webApp")
    local container=$(find_step_configuration_value "container")
    local ansible_deploy=$(find_step_configuration_value "ansible")

    local role=`echo $ansible_deploy | jq -r ".role"`
    local inventory=`echo $ansible_deploy | jq -r ".inventory"`

    local repo=`echo $container | jq -r ".repo"`
    local tag=`echo $container | jq -r ".tag"`

    local repo=`echo $web_app | jq -r ".path"`
    local tag=`echo $web_app | jq -r ".technology"`

    local webhook_rsc_name=$(get_resource_name --type IncomingWebhook --operation IN)
    echo "Webhook name: $webhook_rsc_name"

    local payload=$(find_resource_variable $webhook_rsc_name payload)
    echo "Webhook payload: $payload"

    local vm_rsc_name=$(get_resource_name --type VmCluster --operation IN)
    echo "VM Cluster name: $vm_rsc_name"

    local sshkey=$(find_resource_variable $vm_rsc_name sshKey)
    echo "SSH Key name: $sshkey"

    local ips=$(find_resource_variable $vm_rsc_name targets)
    echo "target IPs : $ips"

    echo "Dry run mode : $dry_run"
    echo "Comment : $comment"

    echo "Webapp: $container"
    echo "repo: $repo"
    echo "tag: $tag"

    echo "Container info: $container"
    echo "repo: $repo"
    echo "tag: $tag"

    echo "Ansible info : $ansible_deploy"
    echo "Ansible role : $role"
    echo "Ansible inventory : $inventory"

    echo "[INFO] Starting deployment ..."
    
    # echo "$res_wh_jenkins_payload" | jq '.' > payload.json
    # cat payload.json

    for curr_ip in `echo $ips | jq -r '.[]'`; do
        echo ${curr_ip}
        ssh -i ~/.ssh/$vm_rsc_name ec2-user@${curr_ip} "uname -a &&./test.sh"
    done

    echo "[INFO] Deployment done"


    $success
}
 
execute_command deployWebApp