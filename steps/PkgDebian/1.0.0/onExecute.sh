
packageDebian() {
    local success=true
#    local binary=$(find_step_configuration_value "binaryLocalLocation")

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
        echo "binary location : $blocation"

        jfrog rt dl $blocation --build="$bname/$bnumber" --flat=true

        ls -l 

        # generate debian package
        version=0.0.1
        rm -rf debian_gen
        mkdir -p debian_gen/myapp_${version}/{DEBIAN,var}
        mkdir -p debian_gen/myapp_${version}/var/myapp

        ls -l debian_gen/myapp_${version}/        

        echo """
Package: app
Architecture: all
Maintainer: Yann Chaysinh
Priority: optional
Version: $version
Description: My Simple Debian package to deploy my super app
        """ > debian_gen/myapp_${version}/DEBIAN/control

        cp *.jar debian_gen/myapp_${version}/var/myapp/

        dpkg-deb --build debian_gen/myapp_${version}

        dpkg -c debian_gen/myapp_${version}.deb

        # upload debian package
        jfrog rt curl -XPUT "ninja-debian-release/pool/myapp_${version}.deb;deb.distribution=stretch;deb.component=main;deb.architecture=x86-64" -T debian_gen/myapp_${version}.deb 

        echo "packaging done :D !!!"
#    fi

    $success
}
 
execute_command packageDebian