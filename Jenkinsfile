pipeline{
  agent any
  stages {
    stage('Set Parameters') {
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
      }
    }
    stage('Build') {
      steps {
          // Clean before build
          //cleanWs()
          cleanWs deleteDirs: true, patterns: [[pattern: '.sh', type: 'EXCLUDE']]
          // We need to explicitly checkout from SCM here
          //checkout scm
          echo "Cleaning ${env.JOB_NAME}..."
      }
    }
    stage('1- Copy Versions to workspace') {
      parallel {
        stage('1- Copy Old version') {
          steps {
            echo 'Copy Old build: ${params.OLD}'
            //sh 'mkdir -p $WORKSPACE/OLD'
            //copyArtifacts(projectName: 'tnexus-ui-beta-3/development-ui-refactoring', selector: lastSuccessful(), target: "${env.WORKSPACE}/../../jobs/${env.JOB_NAME}/builds/${env.BUILD_NUMBER}/archive/FRONTEND")
            //copyArtifacts(projectName: "${env.JOB_BUILD_NAME}", selector: buildParameter('OLD'), target: "${env.WORKSPACE}/OLD")
            copyArtifacts(projectName: "${env.JOB_BUILD_NAME}", selector: specific(params.OLD), target: "${env.WORKSPACE}")
            //copyArtifacts projectName: 'DXB-BUILD', selector: buildParameter('OLD'), target: 'OLD'
          }
        }
        stage('2- Copy builds from original job') {
          steps {
            echo 'Copy New build:  ${params.NEW}'
            //sh 'mkdir -p $WORKSPACE/NEW'
            copyArtifacts(projectName: "${env.JOB_BUILD_NAME}", selector: specific(params.NEW), target: "${env.WORKSPACE}")
          }
        }
      }
    }
  }
  post {
    // Clean after build
    always {
        cleanWs(cleanWhenNotBuilt: true,
                deleteDirs: true,
                disableDeferredWipeout: true,
                notFailBuild: true,
                patterns: [[pattern: '.gitignore', type: 'INCLUDE'],
                            [pattern: '.sh', type: 'EXCLUDE']])
    }
  }
  options {
    // This is required if you want to clean before build
    skipDefaultCheckout(true)
  }
}
