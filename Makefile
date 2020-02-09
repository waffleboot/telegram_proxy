public_master_ip = $(shell cat public_master_ip)

mailto = $(shell cat mail)

token = $(shell cat token)

.PHONY: mail

all: apply mail python install

docker_run = docker run --rm -it -w /opt -v ${PWD}:/opt -v ~/.aws:/root/.aws

apply:
	${docker_run} --name terraform yangand/kubernetes_terraform terraform apply -auto-approve
	$(MAKE) ssh_config
	head -c 16 /dev/urandom | xxd -ps > token

destroy:
	${docker_run} --name terraform yangand/kubernetes_terraform terraform destroy -auto-approve

mail:
	osascript mail.applescript $(public_master_ip) $(token) $(mailto) &

python:
	${docker_run} yangand/kubernetes_ansible ansible-playbook --extra-vars public_master_ip=$(public_master_ip) --extra-vars token=$(token) -i inventory.yaml python.yaml -vvv

install:
	${docker_run} yangand/kubernetes_ansible ansible-playbook --extra-vars public_master_ip=$(public_master_ip) --extra-vars token=$(token) -i inventory.yaml install.yaml

ssh_config:
	~/go/bin/ssh_config ~/.ssh master $(public_master_ip) ubuntu ~/.aws/id_rsa_master