int BATCH_COUNT = 2
int FORK_COUNT = 2
def serenityBatches = [:]

for (int i = 1; i <= BATCH_COUNT; i++) {
    def batchNumber = i
    def batchName = "batch-${batchNumber}"

    serenityBatches[batchName] = {
        node {
            checkout scm
            try {
				if(isUnix()) {
                sh "mvn clean"
                sh "rm -rf target/site/serenity"
                sh "verify -Dwebdriver.driver=chrome -Dparallel.tests=${FORK_COUNT}-Dserenity.batch.count=${BATCH_COUNT} -Dserenity.batch.number=${batchNumber} -Dserenity.test.statistics.dir=/statistics -f pom.xml"
				}else{
				   env.JAVA_HOME="C:\\Sankar\\JenkinsSetUp\\openlogic-openjdk-8u262-b10-win-32"
				   env.PATH="${env.JAVA_HOME}/bin:${env.PATH}"
				   bat "C:\\Sankar\\JenkinsSetUp\\apache-maven-3.5.3\\bin\\mvn.cmd  clean verify -Dwebdriver.driver=chrome -Dparallel.tests=${FORK_COUNT} -Dserenity.batch.count=${BATCH_COUNT} -Dserenity.batch.number=${batchNumber} -Dserenity.test.statistics.dir=/statistics -f pom.xml -Dmaven.surefire.debug=true"
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