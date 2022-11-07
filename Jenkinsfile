#!groovy

//variables
List < String > result = Arrays.asList(services.split("\\s*,\\s*"));
warPath                = ["efp": "target/ABCtechnologies-1.0.war"]

def buildService(service) {

    switch (service) {

        case "efp":

            echo "Starting to build $service"

            sh "pwd"
            sh "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk"
            sh "id"
            // sh "/opt/apache-maven-3.8.6/bin/mvn clean package test"
            sh "/opt/maven/bin/mvn clean package test"

            def efp_war = "${warPath["$service"]}"

            archiveArtifacts fingerprint: true, onlyIfSuccessful: true,  artifacts: '' + efp_war


            withCredentials([usernamePassword(credentialsId: 'docker-login-creds', passwordVariable: 'password', usernameVariable: 'username')]){
                sh "docker login -u ${username} -p ${password}"

                src_dir = sh(script: "pwd", returnStdout: true).trim()

                ansiblePlaybook(
                    playbook: "./create_push_image_regapp.yml",
                    extras: "--extra-vars src_dir=${src_dir}",
                    forks: 6,
                    colorized: true,
                    hostKeyChecking: false
                )

                ansiblePlaybook(
                    playbook: "./ansible/K8S-efp-Deployment.yml",
                    // inventory: "./.hosts",
                    extras: "--extra-vars src_dir=${src_dir}",
                    forks: 6,
                    colorized: true,
                    hostKeyChecking: false
                )

                ansiblePlaybook(
                    playbook: "./ansible/K8S-efp-Service.yml",
                    // inventory: "./.hosts",
                    extras: "--extra-vars src_dir=${src_dir}",
                    forks: 6,
                    colorized: true,
                    hostKeyChecking: false
                )

            }

            break;

        default:
            echo "Service not found"
            break;
    }
}

node('test_build') {

    def isSuccess = true


    stage('Clear Workspace') {
        cleanWs()
    }
    
    try {
        stage('Checkout') {
            // buildName "#${currentBuild.number} | main:efp"
            
            git url: 'https://github.com/ajayryeruva/maven_test.git', branch: "main", changelog: true
            echo "service selected: efp"
                
        }
    } catch (e) {
        isSuccess = false
        currentBuild.result = 'FAILURE'
    }
    

    // try {
    //     stage('Login to Docker Hub') {

    //         if (!isSuccess) {
    //             Utils.markStageSkippedForConditional('Login to Docker Hub')
    //         }
    //         else {
    //             steps{                       	
    //                 sh 'echo $DOCKERHUB_CREDENTIALS_PSW | sudo docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'                		
    //                 echo 'Login Completed'      
    //             }
    //         }
    //     }
    // } catch (e) {
    //     isSuccess = false
    //     currentBuild.result = 'FAILURE'
    // }
    
    
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

