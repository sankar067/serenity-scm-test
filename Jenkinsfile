
int BATCH_COUNT = 2
int FORK_COUNT = 2
def serenityBatches = [:]
def full_string = "Test1 Test2"
def arr = full_string.split(" ")
environment{
	RESULT_ARCHIVE=${BUILD_TAG}.zip
	RESULT_PATH=target/site/serenity
        }

for (int i = 1; i <= BATCH_COUNT; i++) {
    def batchNumber = i
    def batchName = "batch-${batchNumber}"
    def tagName = "${arr[i-1]}"
    serenityBatches[batchName] = {
	node {
	    checkout scm
	    try {
		if(isUnix()) {
			sh "mvn clean"
			sh "rm -rf target/site/serenity"
			sh "clean verify -Dwebdriver.driver=chrome \"-Dmetafilter=+${tagName}\" -Dparallel.tests=${FORK_COUNT} -Dserenity.batch.count=${BATCH_COUNT} -Dserenity.batch.number=${batchNumber} -Dserenity.test.statistics.dir=/statistics -f pom.xml"
		}else{
			env.JAVA_HOME="C:\\Sankar\\JenkinsSetUp\\openlogic-openjdk-8u262-b10-win-32"
			env.PATH="${env.JAVA_HOME}/bin:${env.PATH}"
			bat "C:\\Sankar\\JenkinsSetUp\\apache-maven-3.5.3\\bin\\mvn.cmd  clean verify \"-Dmetafilter=+${tagName}\" -Dwebdriver.driver=chrome -Dparallel.tests=${FORK_COUNT} -Dserenity.batch.count=${BATCH_COUNT} -Dserenity.batch.number=${batchNumber} -Dserenity.test.statistics.dir=/statistics -f pom.xml -Dmaven.surefire.debug=true"
		}
	    } catch (Throwable e) {
		throw e
	    } finally {
		stash name: batchName,
		    includes: "target/site/serenity/**/*",
		    allowEmpty: true
	    }
	}
    }
}

pipeline {
agent any
    stages {

        stage("automated tests") {
            steps{
                    parallel serenityBatches
            }
        }

	stage("report aggregation") {
		steps{
	    node {
		// unstash each of the batches
		echo "Batch Count - ${BATCH_COUNT}"
		    steps{
                for (int i = 1; i <= BATCH_COUNT; i++) {
                    def batchName = "batch-${i}"
                    echo "Unstashing serenity reports for ${batchName}"
                    unstash batchName
                }
		    }
	    }
			
	steps{
	 //build report
	 bat "C:\\Sankar\\JenkinsSetUp\\apache-maven-3.5.3\\bin\\mvn.cmd serenity:aggregate"
	}
        		
	steps{
	     // publish the Serenity report
	     publishHTML(target: [
			reportName : 'Serenity',
			reportDir:   'target/site/serenity',
			reportFiles: 'index.html',
			keepAll:     true,
			alwaysLinkToLastBuild: true,
			allowMissing: false
		])
	 }
	}
	  post {
		always {
		    echo 'ExecutionResult'

		emailext attachmentsPattern: '${env.RESULT_PATH}/serenity-summary.html', body: '''Results HTML Report file at ${env.BUILD_URL}/artifact/${RESULT_PATH}/index.html
		-----------------------------------------------------------------------------------------------------------------------------------------------------------
		RESULT SUMMARY:

		${FILE,path="${env.RESULT_PATH}/summary.txt"}''', subject: 'Test Atomation Result of ${env.BUILD_NUMBER}', to: 'sk,behera@live.com'
		}
	    }
	}
}
}
