#!/usr/bin/groovy

import jenkins.model.Jenkins

timestamps {
    node {
        def server = Artifactory.server("artifactory")
        def buildInfo = Artifactory.newBuildInfo()
        def rtGradle
        def rtDocker
        def dockerImage
        def dockerImageVersion
        def repo = "development"
        def DOCKER_DEV_REPO = "docker-development"
        def ARTIFACTORY_URL = "artifactory.kaloom.io"

        stage("Checkout") {
            checkout([
                $class: "GitSCM",
                branches: scm.branches,
                extensions: scm.extensions + [$class: 'CleanBeforeCheckout'],
                userRemoteConfigs: scm.userRemoteConfigs,
                browser: [
                    $class: "GitLab",
                    repoUrl: scm.userRemoteConfigs.url[0].minus(~/\.git$/), // Strip the trailing .git from url
                    version: "8.7"
                ]
            ])
        }

        stage("Build Golicense Binary") {
            
            // The default build name comes from the Jenkins job name.
            // The default build name includes spaces, which is a problem (https://github.com/JFrogDev/jfrog-cli-go/issues/74),
            // and links to Artifactory break if there's a slash in them.
            buildInfo.name = env.JOB_NAME.replace("/", "_")
            echo buildInfo.name
            echo buildInfo.number

            rtGradle = Artifactory.newGradleBuild()
            rtGradle.usesPlugin = true
            rtGradle.useWrapper = true

            rtGradle.deployer(
                server: server,
                repo: repo
            )
            rtGradle.deployer.deployMavenDescriptors = true
            
            rtGradle.run(
                tasks: "build artifactoryPublish",
                buildInfo: buildInfo,
                switches: "--console=plain --no-daemon -si",
                rootDir: env.WORKSPACE,
                buildFile: "build.gradle"
            )
        }

        stage("Build Golicense Image") {

            dockerImage = "golicense/golicense"
            dockerImageVersion = "0.1"
            docker.build("${dockerImage}:${dockerImageVersion}", ".")

            def tag = "${DOCKER_DEV_REPO}.${ARTIFACTORY_URL}/${dockerImage}:${buildInfo.name}-${buildInfo.number}"
            sh("docker tag ${dockerImage}:${dockerImageVersion} ${tag}")

            rtDocker = Artifactory.docker(
                server: server,
                host: env.DOCKER_HOST
            )

            rtDocker.push(
                tag,
                DOCKER_DEV_REPO,
                buildInfo
            )
        }

        stage("Publish BuildInfo to Artifactory") {
            echo buildInfo.name
            echo buildInfo.number
            server.publishBuildInfo(buildInfo)
        }

        stage("Scan with Xray") {
            def scanConfig = [
                'buildName'      : buildInfo.name,
                'buildNumber'    : buildInfo.number,
                'failBuild'      : true
            ]
            echo "Sending config to Xray: " + scanConfig
            def scanResult = server.xrayScan scanConfig
            echo scanResult as String
            echo buildInfo.name as String
        }

    }
}