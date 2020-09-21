
packageDebian() {
    local success=true
#    local binary=$(find_step_configuration_value "binaryLocalLocation")
    local debian_b_name="my-new-debian-app"
    local debian_b_number=0

    local target_repo="ninja-debian-release"
    local version=0.0.5

    jfrog rt ping

    if [ $? -eq 1 ]; then
        echo "[ERROR][PackageDebian] Artifactory KO"
        exit 1
    fi 
  
    # priority to  binaryLocalLocation
#    if [ $(ls $binary 2> /dev/null ) -eq 1 ]; then 
    
        # couldn't be found --> look into Artifactory
        # get binary based on build props
        # build name and number only work when both are specified 
        local bname=$(find_step_configuration_value "buildName")
        local bnumber=$(find_step_configuration_value "buildNumber") 
        local blocation=$(find_step_configuration_value "binaryArtifactoryLocation") 

        echo "build name : $bname"
        echo "build number : $bnumber"
        jq --version
        echo "binary location : $blocation"

        echo "builds.find({\"name\": \"$debian_b_name\"}).include(\"number\")"  > listBuild.aql

        local list_build_number=$(jfrog rt curl -XPOST api/search/aql -T listBuild.aql | jq '."results"')

        if [[ $list_build_number != "[]" ]]; then
            echo "list non empty"
            debian_b_number=$(echo $list_build_number | jq 'sort_by( ."build.number" | tonumber ) | last | ."build.number" | tonumber')
#        local debian_b_number=$(jfrog rt curl -XPOST api/search/aql -T listBuild.aql | jq '[."results"[]] | sort_by( ."build.number" | tonumber ) | last | ."build.number" | tonumber')
        fi

        echo "build number = $debian_b_number"

        # "let" handles null/nill value and can increment them !
        let "debian_b_number+=1"

        echo "new build number = $debian_b_number"

        jfrog rt dl $blocation --build="$bname/$bnumber" \
            --flat=true \
            --build-name=$debian_b_name \
            --build-number=$debian_b_number
        
        ls -l 

        # generate debian package
        mv multi-module-application-1.0.0.jar multi-module-application-${version}.jar

        rm -rf debian_gen listBuild.aql
        mkdir -p debian_gen/myapp_${version}/{DEBIAN,var}
        mkdir -p debian_gen/myapp_${version}/var/myapp

        ls -l debian_gen/myapp_${version}/        

        echo """
Package: app
Architecture: all
Maintainer: Yann Chaysinh
Priority: optional
Version: $version
Description: My Simple Debian package to deploy my awesome app 
""" > debian_gen/myapp_${version}/DEBIAN/control

        cp *.jar debian_gen/myapp_${version}/var/myapp/

        dpkg-deb --build debian_gen/myapp_${version}

        dpkg -c debian_gen/myapp_${version}.deb

        # upload debian package
#        jfrog rt curl -XPUT "ninja-debian-release/pool/myapp_${version}.deb;deb.distribution=stretch;deb.component=main;deb.architecture=x86-64" -T debian_gen/myapp_${version}.deb 
        echo "jfrog rt u --props=\"deb.distribution=stretch;deb.component=main;deb.architecture=x86-64\" --build-name=debian-app --build-number=$debian_b_number debian_gen/myapp_${version}.deb \"ninja-debian-release/pool/\""
        jfrog rt u  \
            --props="deb.distribution=stretch;deb.component=main;deb.architecture=x86-64" \
            --build-name=$debian_b_name \
            --build-number=$debian_b_number \
        debian_gen/myapp_${version}.deb "$target_repo/pool/"

        jfrog rt bp $debian_b_name $debian_b_number

        echo "packaging done :D !!!"
#    fi

    $success
}
 
execute_command packageDebian