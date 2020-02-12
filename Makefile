public_master_ip = $(shell cat public_master_ip)

mailto = $(shell cat mail)

token = $(shell cat token)

.PHONY: mail open

all:
	@if ssh -i ~/.aws/id_rsa_master -o StrictHostKeyChecking=no -o ConnectTimeout=5 ubuntu@$(public_master_ip) -p 22 echo ok 2>&1; then \
		$(MAKE) destroy;        \
	else                        \
		$(MAKE) create install; \
	fi

docker_run = docker run --rm -it -w /opt -v ${PWD}:/opt -v ~/.aws:/root/.aws

create:
	@echo create aws infrastructure
	@${docker_run} --name terraform yangand/kubernetes_terraform terraform apply -auto-approve
	@$(MAKE) ssh_config
	@echo generate token
	@head -c 16 /dev/urandom | xxd -ps > token
	@echo "tg://proxy?server=$(public_master_ip)&port=443&secret=$(token)"

install: mail python mtproxy

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

mtproxy:
	@echo install mtproxy
	@${docker_run} yangand/kubernetes_ansible ansible-playbook --extra-vars public_master_ip=$(public_master_ip) --extra-vars token=$(token) -i inventory.yaml install.yaml

ssh_config:
	@echo update .ssh/config
	@~/go/bin/ssh_config ~/.ssh master $(public_master_ip) ubuntu ~/.aws/id_rsa_master
