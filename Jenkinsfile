pipeline {
    agent any

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'develop', description: 'Branch Name')
        string(name: 'VERSION', defaultValue: '1.0.1', description: 'Artifact version')
    }

/*     tools {
        jdk 'JDK24'
    } */

    environment {
        MAVEN_HOME = tool 'Maven 3.9.6' // Ajusta según tu configuración en Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Cloning branch ${params.BRANCH_NAME}"
                checkout([$class: 'GitSCM',
                          branches: [[name: "*/${params.BRANCH_NAME}"]],
                          userRemoteConfigs: [[url: 'https://github.com/erickperez091/inventory-server-discovery.git']]])
            }
        }

        stage('Build') {
            steps {
                configFileProvider([configFile(fileId: 'nexus-settings', variable: 'MAVEN_SETTINGS')]) {
                    echo "Building version ${params.VERSION}"
                    sh "${MAVEN_HOME}/bin/mvn clean package -s $MAVEN_SETTINGS"
                }
            }
        }

        stage('Upload to Nexus') {
            steps {
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: 'nexus:8081',
                    groupId: 'com.example',
                    version: "${params.VERSION}",
                    repository: 'maven-test-releases',
                    credentialsId: 'nexus-creds', // Asegúrate que existe en Jenkins
                    artifacts: [
                        [
                            artifactId: 'server-discovery',
                            classifier: '',
                            file: "target/server-discovery-${params.VERSION}.jar",
                            type: 'jar'
                        ],
                        [
                            artifactId: 'server-discovery',
                            classifier: '',
                            file: 'pom.xml',
                            type: 'pom'
                        ]
                    ]
                )
            }
        }
    }
}
