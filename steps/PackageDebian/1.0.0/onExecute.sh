
packageDebian() {
    local success=true
    local debian_b_number=0

    local debian_pkg_name=$(find_step_configuration_value "debianPkgName")
    local debian_b_name=$(find_step_configuration_value "debianBuildName")
    local app_extension=$(find_step_configuration_value "appExtension")
    local target_repo=$(find_step_configuration_value "targetDebianRepo")

    
    jfrog rt ping

    if [ $? -eq 1 ]; then
        echo "[ERROR][PackageDebian] Artifactory KO"
        exit 1
    fi 
  
    # get binary based on build props
    # build name and number only work when both are specified 
    local bname=$(find_step_configuration_value "buildName")
    local bnumber=$(find_step_configuration_value "buildNumber") 
    local blocation=$(find_step_configuration_value "binaryLocation") 
    local newprops=$(find_step_configuration_value "propsToSet")

    echo "build name : $bname"
    echo "build number : $bnumber"
    echo "binary location : $blocation"

    echo "builds.find({\"name\": \"$debian_b_name\"}).include(\"number\")"  > listBuild.aql

    local list_build_number=$(jfrog rt curl -XPOST api/search/aql -T listBuild.aql | jq '."results"')

    if [[ $list_build_number != "[]" ]]; then
        echo "list non empty"
        debian_b_number=$(echo $list_build_number | jq 'sort_by( ."build.number" | tonumber ) | last | ."build.number" | tonumber')
    fi

    echo "build number = $debian_b_number"

    # "let" handles null/nill value and can increment them !
    let "debian_b_number+=1"

    echo "new build number = $debian_b_number"

    jfrog rt dl $blocation --build="$bname/$bnumber" \
        --flat=true \
        --build-name=$debian_b_name \
        --build-number=$debian_b_number
    
    # extract version (X.Y.Z) from downloaded binary
    local version=$(ls *.$app_extension | sed "s/[a-zA-Z-]*\([0-9]*.[0-9]*.[0-9]*\).*/\1/")

    # generate debian package
    rm -rf debian_gen listBuild.aql
    mkdir -p debian_gen/${debian_pkg_name}-${version}/{DEBIAN,var}
    mkdir -p debian_gen/${debian_pkg_name}-${version}/var/myapp

    echo """
Package: app
Architecture: all
Maintainer: Yann Chaysinh
Priority: optional
Version: $version
Description: My Simple Debian package to deploy my awesome app 
""" > debian_gen/${debian_pkg_name}-${version}/DEBIAN/control

    ls -l 

    cp *.$app_extension debian_gen/${debian_pkg_name}-${version}/var/myapp/

    dpkg-deb --build debian_gen/${debian_pkg_name}-${version}

    dpkg -c debian_gen/${debian_pkg_name}-${version}.deb

    # upload debian package
#        jfrog rt curl -XPUT "ninja-debian-release/pool/${debian_pkg_name}-${version}.deb;deb.distribution=stretch;deb.component=main;deb.architecture=x86-64" -T debian_gen/${debian_pkg_name}-${version}.deb 
    echo "jfrog rt u --props=\"deb.distribution=stretch;deb.component=main;deb.architecture=x86-64\" --build-name=debian-app --build-number=$debian_b_number debian_gen/${debian_pkg_name}-${version}.deb \"ninja-debian-release/pool/\""
    jfrog rt u  \
        --props="deb.distribution=stretch;deb.component=main;deb.architecture=x86-64;${newprops}" \
        --build-name=$debian_b_name \
        --build-number=$debian_b_number \
    debian_gen/${debian_pkg_name}-${version}.deb "$target_repo/pool/"

    jfrog rt bp $debian_b_name $debian_b_number

    echo "packaging done :D !!!"

    $success
}
 
execute_command packageDebian