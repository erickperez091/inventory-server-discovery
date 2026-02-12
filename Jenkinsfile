pipeline {
    agent { label 'docker-agent' }

    parameters {
        string(
            name: 'BRANCH_NAME',
            defaultValue: 'develop',
            description: 'Branch to build'
        )
    }

    environment {
        GIT_REPO     = 'https://github.com/erickperez091/inventory-server-discovery.git'
        DOCKER_IMAGE = 'erickperez091/dev-server-discovery'
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Cloning branch: ${params.BRANCH_NAME}"
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: "*/${params.BRANCH_NAME}"]],
                    userRemoteConfigs: [[url: env.GIT_REPO]]
                ])
            }
        }

        stage('Read version from POM') {
            steps {
                script {
                    env.PROJECT_VERSION = sh(
                        script: '''
                            mvn -q -DforceStdout \
                                -Dexpression=project.version \
                                help:evaluate
                        ''',
                        returnStdout: true
                    ).trim()

                    echo "Detected version: ${env.PROJECT_VERSION}"
                }
            }
        }

        stage('Build & Deploy to Nexus') {
            steps {
                configFileProvider([
                    configFile(
                        fileId: 'nexus-settings',
                        variable: 'MAVEN_SETTINGS'
                    )
                ]) {
                    sh '''
                        mvn -s $MAVEN_SETTINGS \
                            clean deploy \
                            -DskipTests \
                            -DallowInsecureProtocol=true \
                            -U
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build \
                      --build-arg JAR_FILE=target/server-discovery-${PROJECT_VERSION}.jar \
                      -t ${DOCKER_IMAGE}:${PROJECT_VERSION} \
                      -t ${DOCKER_IMAGE}:latest \
                      .
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}:${PROJECT_VERSION}
                        docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS → ${params.BRANCH_NAME} → ${env.PROJECT_VERSION}"
        }
        failure {
            echo "FAILED → ${params.BRANCH_NAME}"
        }
        always {
            sh 'docker logout || true'
        }
    }
}

