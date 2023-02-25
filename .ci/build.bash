#!/bin/bash

set -e

job=$1
platform=$2

docker_build_and_cache() {
    docker_image=$1
    docker_file_path=$2
    docker_file_name=$3

    back=$(pwd)

    mkdir -p .cache
    
    docker load -i .cache/${docker_image}.image || (cd ${docker_file_path} && docker build -t ${docker_image} -f ${docker_file_name} .. && docker save ${docker_image} -o ${back}/.cache/${docker_image}.image && cd ${back})
}

docker_run () {
    docker_image=$1
    bash_command=$2
    output_path=.artifact/$3

    docker_build_and_cache ${docker_image} .ci ${docker_image}.dockerfile

    docker run --rm -v $(pwd):/src -v ${docker_image}_build:/build -w /build ${docker_image} bash -c "${bash_command}"
    docker create -it --name tmp -v ${docker_image}_build:/build ${docker_image} bash
    mkdir -p ${output_path}
    docker cp tmp:/build/install ${output_path}
    docker rm -f tmp
}

if [ "$job" = "build-game" ]
then
    platform_command="echo no platorm specific stuff"
    if [ "$platform" = "windows" ]
    then
        platform_ext=".exe"
    fi

    if [ "$platform" = "macos" ]
    then
        platform_ext=".zip"
        platform_command="unzip /build/install/spaceship${platform_ext} -d /build/install && rm /build/install/spaceship${platform_ext}"
    fi

    if [ "$platform" = "linux" ]
    then
        platform_ext=".x86_64"
    fi

    docker_run godot-build-env "cd /src && sh .ci/version.sh > version.gd && cd / && mkdir -p /build/ins&& godot --headless --path /src --export-release ${platform} /tmp/brawler && godot --headless --path /src --export-release ${platform} /build/install/brawler${platform_ext} && ${platform_command}" game-${platform} 
fi

exit $?
