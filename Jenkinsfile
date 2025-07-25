pipeline {
    agent { label 'docker-agent' }

    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'develop', description: 'Branch Name')
        string(name: 'VERSION', defaultValue: '1.0.1', description: 'Artifact version')
    }

    environment {
        MAVEN_HOME = tool 'Maven 3.9.6'
        DOCKER_IMAGE = "erickperez091/dev-server-discovery"
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
        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build \
                          --build-arg JAR_FILE=target/server-discovery-${params.VERSION}.jar \
                          -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                          -f Dockerfile .
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest
                    """
                }
            }
        }
    }
    post {
        success { echo 'inventory-service published successfully' }
        failure { echo 'Error publishing inventory-service' }
    }
}
