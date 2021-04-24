
cleanupArtifact() {
    local success=true

    local cleanup_policy=$(get_resource_name --type cleanupPolicy --operation IN)
    local dry_run=$(find_step_configuration_value "dryRun")

    echo "[INFO] Starting cleanup ..."

    echo "DRY RUN MODE: $dry_run"
    
    echo "Cleanup policy name: $cleanup_policy"

    res_timeUnit=$(find_resource_variable $cleanup_policy timeUnit)
    echo "timeUnit: $res_timeUnit"
    
    echo "[INFO] Cleanup done"

    $success
}
 
execute_command cleanupArtifact