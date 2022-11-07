#!groovy

//variables
warPath                = ["efp": "target/ABCtechnologies-1.0.war"]

def buildService(service) {

    switch (service) {

        case "efp":

            echo "Starting to build $service"

            sh "pwd"
            sh "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk"
            sh "/opt/maven/bin/mvn clean package test"

            def efp_war = "${warPath["$service"]}"

            archiveArtifacts fingerprint: true, onlyIfSuccessful: true,  artifacts: '' + efp_war


            withCredentials([usernamePassword(credentialsId: 'docker-login-creds', passwordVariable: 'password', usernameVariable: 'username')]){
                sh "docker login -u ${username} -p ${password}"

                src_dir = sh(script: "pwd", returnStdout: true).trim()

                ansiblePlaybook(
                    playbook: "./create_push_image_regapp.yml",
                    forks: 6,
                    colorized: true,
                    hostKeyChecking: false
                )

                withEnv(["KUBECONFIG=/var/lib/jenkins/.kube/admin.conf"]) {
                    ansiblePlaybook(
                        playbook: "./ansible-k8s/K8S-efp-Deployment.yml",
                        forks: 6,
                        colorized: true,
                        hostKeyChecking: false
                    )
                }

                withEnv(["KUBECONFIG=/var/lib/jenkins/.kube/admin.conf"]) {
                    ansiblePlaybook(
                        playbook: "./ansible-k8s/K8S-efp-Service.yml",
                        forks: 6,
                        colorized: true,
                        hostKeyChecking: false
                    )
                }

            }

            break;

        default:
            echo "Service not found"
            break;
    }
}

node('build_and_deploy') {

    def isSuccess = true


    stage('Clear Workspace') {
        cleanWs()
    }
    
    try {
        stage('Checkout') {
            
            git url: 'https://github.com/ajayryeruva/edureka_final_project.git', branch: "main", changelog: true
            echo "service selected: efp"
                
        }
    } catch (e) {
        isSuccess = false
        currentBuild.result = 'FAILURE'
    }
    
    
    try {
        stage('Build And Deploy') {
            if (!isSuccess) {
                Utils.markStageSkippedForConditional('Build And Deploy')
            }
            else {

                buildService("efp")

                } 
            }
    }
    catch (e) {
        isSuccess = false
        currentBuild.result = 'FAILURE'
    }


}

