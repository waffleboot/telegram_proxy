public_master_ip  = $(shell cat public_master_ip)

all: apply start install stop

apply:
	docker run --rm --name terraform -w /opt -v ${PWD}:/opt -v ~/.aws:/root/.aws yangand/kubernetes_terraform terraform apply -auto-approve
	sleep 15

destroy:
	docker run --rm --name terraform -w /opt -v ${PWD}:/opt -v ~/.aws:/root/.aws yangand/kubernetes_terraform terraform destroy -auto-approve

start:
	docker run --rm --name ansible -d -v ${PWD}:/opt -v ~/.aws:/.aws yangand/kubernetes_ansible tail -f /dev/null

stop:
	docker stop ansible

run_ansible = docker exec -it -w /opt ansible ansible-playbook --extra-vars public_master_ip=$(public_master_ip) -i inventory.yaml

install:
	${run_ansible} install.yaml

ssh_config:
	~/go/bin/ssh_config ~/.ssh master $(public_master_ip) ubuntu ~/.aws/id_rsa_master