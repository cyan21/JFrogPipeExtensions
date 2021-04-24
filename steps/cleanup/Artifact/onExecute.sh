
cleanupArtifact() {
    local success=true

    local cleanup_policy=$(get_resource_name --type cleanup/Policy/latest --operation IN)
    local dry_run=$(find_step_configuration_value "dryRun")

    echo "[INFO] Starting cleanup ..."

    echo "DRY RUN MODE: $dry_run"
    
    echo "Cleanup policy name: $cleanup_policy"

    # res_timeUnit_workaround=$(find_resource_variable my_cleanup_policy timeUnit)
    # echo "timeUnit: $res_timeUnit_workaround"

    # res_timeUnit=$(find_resource_variable $cleanup_policy timeUnit)    
    # echo "timeUnit: $res_timeUnit"
    
    # repos=$(find_resource_variable my_cleanup_policy repositories)
    # echo "repositories: $repos"
    # echo "repository 1: ${repos[0]}"
    # echo "number of repositories: ${#repos[@]}"

    res_policies=$(find_resource_variable my_cleanup_policy cleanupPolicies)
    echo "list of policies: $res_policies"

    echo "[INFO] Cleanup done"

    $success
}
 
execute_command cleanupArtifact