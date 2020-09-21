
packageDebian() {
    local success=true
    local binary=$(find_step_configuration_value "binaryLocalLocation")

    jfrog rt ping

    if [ $? -eq 1 ]; then
        echo "[ERROR][PackageDebian] Artifactory KO"
        exit 1
    fi 
  
    # priority to  binaryLocalLocation
    if [ $(ls $binary 2> /dev/null ) -eq 1 ]; then 
    
        # couldn't be found --> look into Artifactory
        # get binary based on build props
        # build name and number only work when both are specified 
        local bname=$(find_step_configuration_value "buildName")
        local bnumber=$(find_step_configuration_value "buildNumber") 
        local blocation=$(find_step_configuration_value "binaryArtifactoryLocation") 

        echo "build name : $bname"
        echo "build number : $bnumber"
        echo "binary location : $binaryArtifactoryLocation"
        echo "packaging done :D !!!"
    fi

    $success
}
 
execute_command packageDebian