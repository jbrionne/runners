#!/bin/bash

docker run --rm --net kind -it -v ~/.kube/config:/runner/kubeconfig -v /var/run/docker.sock:/var/run/docker.sock -v $PWD/../:/runner -v /etc/hosts:/etc/hosts -e PS1='\[\033[1;33m\][DEV \u@RUNNER \w]\[\033[0;0m\] \$ ' ansible-kubernetes-terraform:0.0.1 /bin/bash

