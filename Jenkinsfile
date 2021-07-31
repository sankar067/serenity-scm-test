int BATCH_COUNT = 2
int FORK_COUNT = 2
def serenityBatches = [:]
//List a = ['Test1','Test2']
def full_string = "Test1 Test2"
def arr = full_string.split(" ")

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

stage("automated tests") {
   def RESULT_ARCHIVE="${BUILD_TAG}.zip"
   def RESULT_PATH="target/site/serenity"
   parallel serenityBatches

}

stage("report aggregation") {
    node {
        // unstash each of the batches
	echo "Batch Count - ${BATCH_COUNT}"
        for (int i = 1; i <= BATCH_COUNT; i++) {
            def batchName = "batch-${i}"
            echo "Unstashing serenity reports for ${batchName}"
            unstash batchName
        }

	//build report
	  
	  bat "C:\\Sankar\\JenkinsSetUp\\apache-maven-3.5.3\\bin\\mvn.cmd serenity:aggregate"
	   
	script {
		def output = powershell(returnStdout: true, script: '''
		$File = get-content "target/site/serenity/results.csv"
		$testArray = New-Object System.Collections.Generic.List[System.Object]
		foreach ($line in $File){
			$Arr = $line.Split(',')
			if($Arr[2].indexof("SUCCESS") -gt 0){
				$var = $Arr[1].split(" ")[0]
				$var = $var -replace '"','+'
				$testArray.Add($var)
			}
		}
		Write-Host  $testArray
	    '''
	    println(output)
	    /*Prints:
	    value1
	    */
	    env.failedtags = output.tokenize('\n')[0].trim()  \\value1
   }
// 	    env.JAVA_HOME="C:\\Sankar\\JenkinsSetUp\\openlogic-openjdk-8u262-b10-win-32"
// 	    env.PATH="${env.JAVA_HOME}/bin:${env.PATH}"
            bat "C:\\Sankar\\JenkinsSetUp\\apache-maven-3.5.3\\bin\\mvn.cmd  verify \"-Dmetafilter=+${env.failedtags}\" -Dwebdriver.driver=chrome -Dmaven.surefire.debug=true"
	    
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
stage("send email"){
	node{
	emailext attachmentsPattern: 'target/site/serenity/serenity-summary.html', body: '''Results HTML Report file at ${JOB_URL}/artifact/Serenity
	
	-----------------------------------------------------------------------------------------------------------------------------------------------------------
	RESULT SUMMARY:

	${FILE,path="target/site/serenity/summary.txt"}''', subject: 'Test Atomation Result of ${BUILD_NUMBER}', to: 'sankar067github@outlook.com'
	}
   }	
}
