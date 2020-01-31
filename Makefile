public_master_ip  = $(shell cat public_master_ip)

all: apply install

docker_run = docker run --rm -it -w /opt -v ${PWD}:/opt -v ~/.aws:/root/.aws

apply:
	${docker_run} --name terraform yangand/kubernetes_terraform terraform apply -auto-approve
	sleep 15

destroy:
	${docker_run} --name terraform yangand/kubernetes_terraform terraform destroy -auto-approve

install:
	${docker_run} --name ansible yangand/kubernetes_ansible ansible-playbook --extra-vars public_master_ip=$(public_master_ip) -i inventory.yaml install.yaml

ssh_config:
	~/go/bin/ssh_config ~/.ssh master $(public_master_ip) ubuntu ~/.aws/id_rsa_master