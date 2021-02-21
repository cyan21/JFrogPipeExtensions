checkImagesReadiness() {
    local success=true

    local is_prop_search=$(find_step_configuration_value "propSearch")
    local prop_back_img=$(find_step_configuration_value "propBackImage")
    local prop_front_img=$(find_step_configuration_value "propBackImage")
    local retry=$(find_step_configuration_value "retry")
    local wait_time=$(find_step_configuration_value "waitTime")

    local webhook_rsrc=$(get_resource_name --type IncomingWebhook --operation IN)

    echo "Incoming webhook: $webhook_rsrc"

    res_payload=$(find_resource_variable $webhook_rsrc payload)
    echo "Webhook Payload: $res_payload"

    echo "Prop search: $is_prop_search"
    echo "Prop Back: $prop_back_img"
    echo "Prop Front: $prop_front_img"
    echo "Retry: $retry"
    echo "wait time: $wait_time"

    # Locate Helm Chart
    repo=`jq -r '.data.repo_key' payload.json`
    chart=`jq -r '.data.name' payload.json`
    echo '{"files": [{"pattern": "${repo}/${chart}"}]}' > helmChart.filespec
    cat helmChart.filespec

    if [ "$is_prop_search" = true ]; then

        # Get props 
        for img in $prop_back_img $prop_front_img; do

            count=1
            found=0

            img=`jfrog rt s --spec=helmChart.filespec --spec-vars="repo=${repo};chart=${chart}" | jq -r '.[].props."$prop_back_img"[]'` 
            echo $img

            img_name=`echo $img | cut -d/ -f1`
            img_tag=`echo $img | cut -d/ -f2`
            echo "result = $img_name;$img_tag"
            
            # Get image repo in Edge node
            echo "{\"files\": [{\"pattern\": \"**/$img/manifest.json\"}]}" > docker.filespec
            cat docker.filespec
            dockerRepo=`jfrog rt s --spec=docker.filespec | jq -r ".[].path" | cut -d/ -f1`
            echo $dockerRepo
            
            # Check if image exists
            while [ $count -lt $retry && $found -ne 1 ]; do
                
                # returns 0 if tag found    
                jfrog rt curl api/docker/${dockerRepo}/v2/${img_name}/tags/list --silent | grep "$img_tag"
                
                if [ $? -eq 0 ]; then
                    found=1
                else
                    "[DEBUG][Tentative=$retry] Image container not found ... testing again in $wait_time"
                    sleep $wait_time
                    let "count+=1"
                fi
            done 
        done 
    # else
        # extract images names from values.yml in Helm Chart
        # TO DO 
        # Download Helm Chart

        # Extract content and parse Values.yml with yq client
    fi

    $success
}
 
execute_command podmanBuild