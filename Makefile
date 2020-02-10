public_master_ip = $(shell cat public_master_ip)

mailto = $(shell cat mail)

token = $(shell cat token)

.PHONY: mail open

all: apply mail python install

docker_run = docker run --rm -it -w /opt -v ${PWD}:/opt -v ~/.aws:/root/.aws

apply:
	@echo create aws infrastructure
	@${docker_run} --name terraform yangand/kubernetes_terraform terraform apply -auto-approve
	@$(MAKE) ssh_config
	@echo generate token
	@head -c 16 /dev/urandom | xxd -ps > token

destroy:
	@echo destroy aws infrastructure
	@${docker_run} --name terraform yangand/kubernetes_terraform terraform destroy -auto-approve

mail:
	@echo send mail
	@osascript mail.applescript $(public_master_ip) $(token) $(mailto) &

open:
	@open "tg://proxy?server=$(public_master_ip)&port=443&secret=$(token)"

python:
	@echo install ansible
	@${docker_run} yangand/kubernetes_ansible ansible-playbook --extra-vars public_master_ip=$(public_master_ip) --extra-vars token=$(token) -i inventory.yaml python.yaml

install:
	@echo install mtproxy
	@${docker_run} yangand/kubernetes_ansible ansible-playbook --extra-vars public_master_ip=$(public_master_ip) --extra-vars token=$(token) -i inventory.yaml install.yaml

ssh_config:
	@echo update .ssh/config
	@~/go/bin/ssh_config ~/.ssh master $(public_master_ip) ubuntu ~/.aws/id_rsa_master
