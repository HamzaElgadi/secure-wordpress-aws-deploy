pipeline {
    agent any

    environment {
        REMOTE_USER = 'car'
        REMOTE_HOST = '192.168.195.148'
        REMOTE_DIR  = '/home/car/wordpress'
        SSH_CRED_ID = 'key07'
    }

    triggers {
        githubPush() 
    }

    stages {
        stage('Cloner le dépôt GitHub') {
            steps {
                git branch: 'master', url: 'git@github.com:jnane-abdelhakim/website_on_Ec2.git'
            }
        }

        stage('Copier les fichiers vers la VM') {
            steps {
                sshagent (credentials: [env.SSH_CRED_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_DIR}"
                        scp -o StrictHostKeyChecking=no deploy_wordpress.yml docker-compose_WS.yml ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/
                    """
                }
            }
        }

        stage('Exécuter le playbook Ansible') {
            steps {
                sshagent (credentials: [env.SSH_CRED_ID]) {
                    sh """
                        ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR} && ansible-playbook deploy_wordpress.yml"
                    """
                }
            }
        }

        stage('Lancer les conteneurs Docker') {
            steps {
                sshagent (credentials: [env.SSH_CRED_ID]) {
                    sh """
                        ssh ${REMOTE_USER}@${REMOTE_HOST} "cd ${REMOTE_DIR} && docker-compose -f docker-compose_WS.yml up -d"
                    """
                }
            }
        }
    }
}
