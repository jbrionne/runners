# Runners

Speed up your dev

## Runner ansible-kubernetes-terraform

### Docker

Install docker locally

### Create Kind k8s cluster

Create kind-config.yaml

```
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
  - role: control-plane
    extraMounts:
      - hostPath: /your/workspace/kind
        containerPath: /runner
```

kind create cluster --config kind-config.yaml

Replace in the "vi ~/.kube/config" kind-kind context the line:
    server: https://127.0.0.1:36309 (random port)
by
    server: https://172.18.0.2:6443

### Build runner

```
cd ansible-kubernetes-terraform
docker build -t ansible-kubernetes-terraform:0.0.1 .
```
### Run

```
./ansible-kubernetes-terraform.sh
```

Check (The first command could be slow)

```
[DEV root@RUNNER /runner] # kubectl get pods --all-namespaces
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
kube-system          coredns-74ff55c5b-9ps62                      1/1     Running   0          87s
kube-system          coredns-74ff55c5b-tgs4j                      1/1     Running   0          87s
kube-system          etcd-kind-control-plane                      1/1     Running   0          99s
kube-system          kindnet-wqxv6                                1/1     Running   0          87s
kube-system          kube-apiserver-kind-control-plane            1/1     Running   0          99s
kube-system          kube-controller-manager-kind-control-plane   1/1     Running   0          99s
kube-system          kube-proxy-jt9k7                             1/1     Running   0          87s
kube-system          kube-scheduler-kind-control-plane            1/1     Running   0          99s
local-path-storage   local-path-provisioner-78776bfc44-b995k      1/1     Running   0          85s
```

## Run ansible

```
ansible-galaxy collection init my_namespace.my_collection
cd my_namespace/my_collection/roles
molecule init role my-new-role --driver-name docker
```
