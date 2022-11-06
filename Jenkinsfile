#!groovy

//variables
List < String > result = Arrays.asList(services.split("\\s*,\\s*"));
warPath                = ["efp": "target/efp.war"]

def buildService(service) {

    switch (service) {

        case "efp":

            echo "Starting to build $service"

            sh "pwd"
            sh "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk"
            sh "/opt/apache-maven-3.8.6/bin/mvn clean package test"

            echo "Archiving EFP War File..."
            sh "mv target/ABCtechnologies-1.0.war target/efp.war"

            def efp_war = "${warPath["$service"]}"

            archiveArtifacts fingerprint: true, onlyIfSuccessful: true,  artifacts: '' + efp_war


            withCredentials([usernamePassword(credentialsId: 'docker-login-creds', passwordVariable: 'password', usernameVariable: 'username')]){
                sh "docker login -u ${username} -p ${password}"

                src_dir = sh(script: "pwd", returnStdout: true).trim()
                ansiblePlaybook(
                    playbook: "./create_push_image_regapp.yml",
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
            buildName "#${currentBuild.number} | main:$services"
            
            git url: 'git@github.com:ajayryeruva/maven_test.git', branch: "main", changelog: true
            echo "service selected: $services"
                
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
        stage('Build') {
            if (!isSuccess) {
                Utils.markStageSkippedForConditional('Build')
            }
            else {
                
                for (service in result) {

                    buildService(service)

                } 
            }
        }
    } 
    catch (e) {
        isSuccess = false
        currentBuild.result = 'FAILURE'
    }


}

