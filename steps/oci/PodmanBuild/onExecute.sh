podmanBuild() {
    local success=true

    local dockerfile_name=$(find_step_configuration_value "dockerFileName")
    local dockerfile_location=$(find_step_configuration_value "dockerFileLocation")
    local oci_img_name=$(find_step_configuration_value "ociImageName")
    local oci_img_tag=$(find_step_configuration_value "ociImageTag")
    local push_img=$(find_step_configuration_value "pushImage")
    local target_repo=$(find_step_configuration_value "artifactoryTargetRepoName")
    local build_name=$(find_step_configuration_value "buildName")
    local build_number=$(find_step_configuration_value "buildNumber")
     
    local res_name=$(get_resource_name --type GitRepo --operation IN)
    echo "Git resource: $res_name"

    res_path=$(find_resource_variable $res_name path)
    echo "Git resource path: $res_path"

    echo "Dockerfile name : $dockerfile_name"
    echo "Dockerfile location : $dockerfile_location"

    echo "Image name: $oci_img_name"
    echo "Image tag: $oci_img_tag"
    echo "Build name: $build_name"
    echo "Push Image: $push_img"

    ls -l .

    # install podman
    if ! which podman ; then 
        sudo echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${operating_system}/ /" |  sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list 
        sudo curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${operating_system}/Release.key | sudo apt-key add - 
        sudo apt update 

        local lock=0
        local cnt=1
        local wait=30 

        ps -ef | grep -i apt | grep -v "grep"

        while [ $lock -eq 0 ] do;
            echo "[iteration $cnt] waiting for $wait seconds to check the lock ... "
            sleep $wait
            lock=`ps -ef | grep -i apt | grep -v "grep"`
            let "cnt+=1"
            if [ $cnt > 4 ]; then 
                echo "[ERROR] waiting for too long, failing the step "
                exit 1
            if
        done

        sudo apt -y install podman
    fi
    podman info
    
    # install latest J  Frog CLI
    jfrog --version
    cli_path=$(dirname "$(which jfrog)") 
    curl -fL https://getcli.jfrog.io | sh &&  mv ./jfrog "$cli_path/" && ls -l "$cli_path/jfrog"  
    jfrog --version
    jfrog rt c show
    
    # add insecure registry
    #cat /etc/containers/registries.conf
    
    if ! grep "registries.insecure" /etc/containers/registries.conf; then 
        echo -e "\n[registries.insecure]\nregistries=['"$(echo $oci_img_name | cut -d"/" -f1)"']" >> /etc/containers/registries.conf
    fi  
 
    cat /etc/containers/registries.conf

    # run podman build
    podman build -t $oci_img_name:$oci_img_tag -f $dockerfile_name $res_path/$dockerfile_location 

    if [ $push_img -eq 1 ]; then
        jfrog rt podman-push $oci_img_name:$oci_img_tag $target_repo --build-name=$build_name --build-number=$build_number
        jfrog rt bp $build_name $build_number
    fi

    $success
}
 
execute_command podmanBuild