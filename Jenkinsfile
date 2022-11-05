#!groovy

//variables
appName                = ["efp": "Efp-App"]
List < String > result = Arrays.asList(services.split("\\s*,\\s*"));
warPath                = ["efp": "target/ABCtechnologies-1.0.war"]


def buildService(service) {

    switch (service) {

        case "efp":

            echo "Starting to build $service"

            sh "pwd"
            sh "export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk"

            sh "/opt/apache-maven-3.8.6/bin/mvn clean package test"

            echo "Archiving EFP War File..."
            sh "mv target/ABCD.war target/efp.war"

            def efp_war = "${warPath["$service"]}"

            archiveArtifacts fingerprint: true, onlyIfSuccessful: true,  artifacts: '' + efp_war

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
    } catch (e) {
        isSuccess = false
        currentBuild.result = 'FAILURE'
    }


}

