node {
    stage('Cleaning Workspace') {
        if (env.CLEANWS == 'True') {
            print('[!] Cleaning Workspace as requested.')
            cleanWs(cleanWhenNotBuilt: false,
                    deleteDirs: true,
                    disableDeferredWipeout: true,
                    notFailBuild: true,
                    patterns: [[pattern: '.hgignore', type: 'INCLUDE'],
                               [pattern: '.propsfile', type: 'EXCLUDE']])
            cleanWs()
        }
    }
    stage('SCM repo checkout') {
        if (env.OLDREV != '') {
            if (env.OLDREV.matches("[*a-zA-Z]")) {
                print("[!] Variable can not contain any character.")
                System.exit(0)
            }
            else{
                sh label: '', script: '''cd $WORKSPACE
                [ -e yellowhammer-web/src/main/webapp/api-definitions/private/v2.0.9/yh-restapi.json ] && rm yellowhammer-web/src/main/webapp/api-definitions/private/v2.0.9/yh-restapi.json
                hg pull
                hg update $OLDREV
                '''
            }
        }
        else {
             
        sh label: '', script: '''cd $WORKSPACE
		hg pull "http://smakhija:Rxx:Av57@192.168.1.40:8001/scm/hg/yhprod"
        hg update $Revision'''
		 
		
   
        }
        if (env.HGTAG != '') {
            withEnv(['user=jenkins-user', 'pass=Equ4t0r$2022']) {
                sh label: '', script: '''cd $WORKSPACE
                hg update "$REVISION"
                hg pull "http://jenkins-user:$pass@192.168.1.40:8001/scm/hg/yhprod"
                hg tag $HGTAG
            '''
            System.exit(0)
            }
        }
    }
    stage('collecting-changelogs') {
       def changeLogSets = currentBuild.changeSets
        for (int i = 0; i < changeLogSets.size(); i++) {
            def entries = changeLogSets[i].items
            for (int j = 0; j < entries.length; j++) {
        def entry = entries[j]
        echo "${entry.commitId} by ${entry.author} on ${new Date(entry.timestamp)}: ${entry.msg}"
        def files = new ArrayList(entry.affectedFiles)
        for (int k = 0; k < files.size(); k++) {
            def file = files[k]
            echo "  ${file.editType.name} ${file.path}"
                }
            }
        }
   }
   stage('clean-build') {
        //office365ConnectorSend message: 'started ${JOB_NAME} ${BUILD_NUMBER} (<${BUILD_URL}|Open>)', webhookUrl: 'https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/597f3d71653a4a79a85f9f9817dab3e5/d8146787-3eaa-4062-b82f-845f245f689f'
        echo "clean-build"
        sh label: '', script: '''cd $WORKSPACE
        cd yellowhammer-suite; mvn clean install; cd -
        cd yellowhammer-common; mvn clean install; cd -
        ./cleanbuild.sh'''
    }
    parallel server: {
        stage ('YellowHammer-Server') {
            echo 'server-build'
            sh label: '', script: 
            './prod-build-server.sh'
        }
    } 
    webclient: {
        stage ('YellowHammer-Webclient') {
            echo "webclient build "
            sh label: '', script: 
            './jar-build-webclient.sh'
        }
    } 
    clibuild: {
        stage ('CLI') {
            echo "CLI build "
            sh label: '', script: '''cd ${WORKSPACE}/yellowhammer-cli-adaptor/
            mvn install'''
        }
    }
    stage('collecting-build-files') {
      echo "Running build collection script"
        sh label: '', script: '''cd /home/Jenkins-Build-Files/  
        ./yh-build-collection.sh'''
    } 
    parallel rpmbuild: {
        stage ('rpmbuild') {
            if (env.CREATERPM == 'true'){
                println("[+] Starting RPMBUILD process as requested")
                build 'RPMBUILD'
            }
            else {
                println("[-] RPMBUILD not requested.")
            }
        }
    } 
    Deployment108: {
        stage ('Deploy-on-108') {
            if (env.DEPLOY108 == 'true'){
                println("[+] Starting deployment on 108 server")
                sh label: '', script: '''cd /home/Jenkins-Build-Files/publish-over-ssh  
                ./upgrade-yhbuild.sh'''
            }
            else {
                println("[-] Deployment on 108-server isn't requested.")
            }
        }
    } 
    QADeployment: {
        stage ('Deploy-on-QA(73)') {
            if (env.DEPLOYQA == 'true'){
                    println("[+] Starting deployment on QA-(73) server")
                    sshPublisher(publishers: [sshPublisherDesc(configName: '1.73-Ubuntu', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''cd /home/ubuntu/upgrade-files/
                    sudo sh upgrade-yhbuild.sh''', execTimeout: 300000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: 'yellowhammer-upgrade.zip')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
            else{
                println("[-] Deployment on QA-(73) server isn't requested.")
            }
        }
    } 
    CHVQARIG: {
        stage ('Deploy-on-CHV-RIG(2.145)') 
            {
            if (env.CHVQARIG == 'true'){
                println("[+] Starting deployment on CHV-QA-(2.145) server")
                sshPublisher(publishers: [sshPublisherDesc(configName: 'QA-2.145', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''cd /home/sigmastream/upgrade-files/
                sudo sh upgrade-yhbuild.sh''', execTimeout: 300000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: 'yellowhammer-upgrade.zip')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
            else{
                println("[-] Deployment on CHV-QA-(2.145) server isn't requested.")
            }
        }
    }
    CHVQACORP: {
        stage ('Deploy-on-CHV-CORP(2.135)') {
            if (env.CHVQACORP == 'true'){
                println("[+] Starting deployment on CHV-QA-(2.135) server")
                sshPublisher(publishers: [sshPublisherDesc(configName: 'QA-2.135', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''cd /home/sigmastream/upgrade-files/
                sudo sh upgrade-yhbuild.sh''', execTimeout: 300000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: 'yellowhammer-upgrade.zip')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
            else{
                println("[-] Deployment on CHV-QA-(2.135) server isn't requested.")
            }
        }
    } 
    QA104: {
        stage ('Deploy-on-QA104(1.104)') {
            if (env.QA104 == 'true'){
                println("[+] Starting deployment on QA-104(1.104) server")
                sshPublisher(publishers: [sshPublisherDesc(configName: 'QA-104', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''cd /home/sigmastream/upgrade-files/
                sudo sh upgrade-yhbuild.sh''', execTimeout: 300000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: 'yellowhammer-upgrade.zip')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
            else{
                println("[-] Deployment on QA-104(1.104) server isn't requested.")
            }
        }
    } 
    QA107: {
        stage ('Deploy-on-QA107(1.107)') {
            if (env.QA107 == 'true'){
                println("[+] Starting deployment on QA-107(1.107) server")
                sshPublisher(publishers: [sshPublisherDesc(configName: 'QA-107', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''cd /home/sigmastream/upgrade-files/
                sudo sh upgrade-yhbuild.sh''', execTimeout: 300000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: 'yellowhammer-upgrade.zip')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
            else{
                println("[-] Deployment on QA-107(1.107) server isn't requested.")
            }
        }
    } 
    EC2Prod: {
        stage ('Deploy-on-EC2Prod(yh.ss.com)') {
            if (env.EC2Prod == 'true'){
                println("[+] Starting deployment on Ec2Prod(yellowhammer.sigmastream.com)")
                sshPublisher(publishers: [sshPublisherDesc(configName: 'EC2-Prod', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''cd /apps/upgrade-files/
                sudo sh upgrade-yhbuild.sh''', execTimeout: 300000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: 'yellowhammer-upgrade.zip')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
            else{
                println("[-] Deployment on EC2-Prod server isn't requested.")
            }
        }
    } 
    QA131: {
        stage ('Deploy-on-QA131(1.131)') {
            if (env.QA131 == 'true'){
                println("[+] Starting deployment on 131(QA-131)")
                sshPublisher(publishers: [sshPublisherDesc(configName: 'QA-131', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''cd /apps/upgrade-files/
                sudo sh upgrade-yhbuild.sh''', execTimeout: 300000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '', remoteDirectorySDF: false, removePrefix: '', sourceFiles: 'yellowhammer-upgrade.zip')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
            }
            else{
                println("[-] Deployment on QA-131 server isn't requested.")
            }
        }
    }            
    stage('email') {
      //office365ConnectorSend message: 'Completed ${JOB_NAME} ${BUILD_NUMBER} (<${BUILD_URL}|Open>)', webhookUrl: 'https://sigmastreamcom.webhook.office.com/webhookb2/8c78ee27-09f8-47d9-a0ba-80cc98d76acb@9c6e8818-9573-4af1-a3f4-2d19bf10a063/IncomingWebhook/597f3d71653a4a79a85f9f9817dab3e5/d8146787-3eaa-4062-b82f-845f245f689f'
        emailext attachLog: true, body: '''${SCRIPT, template="yellowhammer-email-template.template"}''', recipientProviders: [brokenBuildSuspects(), requestor()], subject: '$DEFAULT_SUBJECT'     
    }
}