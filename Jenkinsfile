pipeline{
  agent any
  stages {
    stage('Setting Parameters') {
      steps {
        script {
          properties([
            parameters([
              string(name: 'JOB_BUILD_NAME', defaultValue: 'DXB-BUILD', description: 'The Job build name'),
              [$class: 'CascadeChoiceParameter',
              choiceType: 'PT_SINGLE_SELECT',
              description: 'Select the old build version',
              name: 'OLD',
              referencedParameters: 'JOB_BUILD_NAME' ,
              script:
              [$class: 'GroovyScript',
              fallbackScript: [
                classpath: [],
                sandbox: true,
                script: "return['Could not versions']"
              ],
              script: [
                classpath: [],
                sandbox: true,
                script: '''
                def builds = []
                def job = jenkins.model.Jenkins.instance.getItemByFullName(JOB_BUILD_NAME)
                job.builds.each {
                if (it.result == hudson.model.Result.SUCCESS) {
                builds.add(it.displayName[0..-1].tokenize("/")[0])
                }
                }
                println builds
                builds.remove(0)
                builds.removeAll { it.toLowerCase().startsWith('#') }
                return builds.unique()
                '''
                  ]
                ]
              ],
              [$class: 'CascadeChoiceParameter',
              choiceType: 'PT_SINGLE_SELECT',
              description: 'Select the New build version',
              name: 'NEW',
              referencedParameters: 'JOB_BUILD_NAME' ,
              script:
              [$class: 'GroovyScript',
              fallbackScript: [
                classpath: [],
                sandbox: true,
                script: "return['Could not versions']"
              ],
              script: [
                classpath: [],
                sandbox: true,
                script: '''
                def builds = []
                def job = jenkins.model.Jenkins.instance.getItemByFullName(JOB_BUILD_NAME)
                job.builds.each {
                if (it.result == hudson.model.Result.SUCCESS) {
                builds.add(it.displayName[0..-1].tokenize("/")[0])
                }
                }
                println builds
                builds.removeAll { it.toLowerCase().startsWith('#') }
                return builds.unique()
                '''
                  ]
                ]
              ]
            ])
          ])
        }
        echo "Old build: '${params.OLD}' "
        echo "New build:  '${params.NEW}' "
        sh './TestInputOldNew.sh $OLD $NEW'
        // Clean before build
        //cleanWs()
        echo "Cleaning ${env.JOB_NAME}..." 
        cleanWs deleteDirs: true, patterns: [[pattern: '*.sh', type: 'EXCLUDE']]
        // We need to explicitly checkout from SCM here
        //checkout scm
      }
    }
    stage('1- Copy Versions to workspace:') {
      parallel {
        stage('1.1- Copy OLD version') {
          steps {
            echo 'Copy Old build: ${params.OLD}'
            //sh 'mkdir -p $WORKSPACE/OLD'
            //copyArtifacts(projectName: 'tnexus-ui-beta-3/development-ui-refactoring', selector: lastSuccessful(), target: "${env.WORKSPACE}/../../jobs/${env.JOB_NAME}/builds/${env.BUILD_NUMBER}/archive/FRONTEND")
            //copyArtifacts(projectName: "${env.JOB_BUILD_NAME}", selector: buildParameter('OLD'), target: "${env.WORKSPACE}/OLD")
            copyArtifacts(projectName: "${env.JOB_BUILD_NAME}", selector: specific(params.OLD), target: "${env.WORKSPACE}")
            //copyArtifacts projectName: 'DXB-BUILD', selector: buildParameter('OLD'), target: 'OLD'
            sh 'mv *$OLD $OLD'
            sh 'tree --du -h $OLD'
          }
        }
        stage('1.2- Copy NEW version') {
          steps {
            echo 'Copy New build:  ${params.NEW}'
            //sh 'mkdir -p $WORKSPACE/NEW'
            copyArtifacts(projectName: "${env.JOB_BUILD_NAME}", selector: specific(params.NEW), target: "${env.WORKSPACE}")
            sh 'mv *$NEW $NEW'
            sh 'tree --du -h $NEW'
          }
        }
      }
    }

    stage('2- Create patch structure:') {
      steps {
        echo 'Create Patch folder structure '
        echo 'Copy newly added 3rd parties jars and non-jar files'
        sh './createPatchWithNewFiles.sh $OLD $NEW'
      }
    }
    stage('3- Process non-jar files:') {
      steps {
        echo 'Copy commun non-jars files having changes'
        sh './CommunChangedNonJarFiles.sh $OLD $NEW'
        sh 'tree --du -h PATCH'
      }
    }
    stage('4- Process Tnexus jars:') {
      steps {
        echo 'Copy empty tnexus jars files having changes'
        sh './CopyTnexusJarsToPatch.sh $OLD $NEW'
        echo 'Deeply compare tnexus jars having same names(ignoring META-INF)'
        sh ' ./CommunChangedJarFiles.sh  $OLD $NEW'
        echo 'Removing compact folder from patch'
        sh 'rm -rf PATCH/$NEW/delivery/compact'
      }
    }
    stage('5- Complete 3rd parties jars ') {
      steps {
        echo 'Complete 3rd parties jars from local thirdparties folder'
        echo 'Replace the dummy-empty jars with real ones'
        sh './Complete3rdPJars.sh PATCH /var/lib/jenkins/thirdparties/lib/'
      }
    }
    stage('6- Create Deleted file report ') {
      steps {
        echo 'Create deleted-files-report.txt file: it contains the list of files that should removed from the deployment'
        sh './createDeletedFileReport.sh $OLD $NEW'
        sh 'cp deleted-files-report.txt PATCH/$NEW'
      }
    }
    stage('7- Finalizing patch folder ') {
      steps {
        echo "Rename the Patch to be : '${params.OLD}''${params.OLD}' " 
        sh ''' 
        NAME=$(echo $OLD-$NEW | tr -d ' ') 
        mv PATCH/$NEW PATCH/$NAME
        cd PATCH
        zip -r $NAME.zip $NAME
        '''
      }
    }
    stage('8- Generate Patch reports ') {
      steps {
        sh '''
        echo 'Generate Patch tree'
        tree --du -h PATCH || echo 'Empty'
        mkdir -p Reports
        tree --du -h PATCH > Reports/Patch-tree.txt
        '''
        sh '''
        ./keepOnlyUsefulDiff.sh
        '''
      }
    }
  }
  post {
    // Clean after build
    always {
        archiveArtifacts artifacts: 'PATCH/*.zip , Reports/**', onlyIfSuccessful: true
        echo 'Cleaning'
        cleanWs deleteDirs: true, notFailBuild: true, patterns: [[pattern: '*.sh', type: 'EXCLUDE']]
    }
  }
  options {
    // This is required if you want to clean before build
    skipDefaultCheckout(true)
  }
}
