# Runners

Speed up your dev

## Runner ansible-kubernetes-terraform

### Docker

Install docker locally

### Create Kind k8s cluster

Create kind-config.yaml (change the hostPath)

```
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
  - role: control-plane
    kubeadmConfigPatches:
    - |
      kind: InitConfiguration
      nodeRegistration:
        kubeletExtraArgs:
          node-labels: "ingress-ready=true"
    extraPortMappings:
    - containerPort: 80
      hostPort: 80
      protocol: TCP
    - containerPort: 443
      hostPort: 443
      protocol: TCP
    extraMounts:
      - hostPath: /your/workspace/kind
        containerPath: /runner
```

kind create cluster --config kind-config.yaml

Replace in the "vi ~/.kube/config" kind-kind context the line:
```
    server: https://127.0.0.1:36309 (it's a random port)
```
by
```
    server: https://172.18.0.2:6443 (it's the ip of the k8s node)
```

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
### Set ingress

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
```

Wait until pod creation

```
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

Check

```
[DEV-DEV root@RUNNER /runner] # kubectl get pods --all-namespaces
NAMESPACE            NAME                                         READY   STATUS      RESTARTS   AGE
ingress-nginx        ingress-nginx-admission-create-mpcn4         0/1     Completed   0          2m16s
ingress-nginx        ingress-nginx-admission-patch-6r9cm          0/1     Completed   0          2m16s
ingress-nginx        ingress-nginx-controller-77758b5777-knjj5    1/1     Running     0          2m17s
kube-system          coredns-74ff55c5b-b4k26                      1/1     Running     0          6m
kube-system          coredns-74ff55c5b-q7j47                      1/1     Running     0          6m
kube-system          etcd-kind-control-plane                      1/1     Running     0          6m10s
kube-system          kindnet-nv8n6                                1/1     Running     0          5m57s
kube-system          kube-apiserver-kind-control-plane            1/1     Running     0          6m10s
kube-system          kube-controller-manager-kind-control-plane   1/1     Running     0          6m10s
kube-system          kube-proxy-l7x4c                             1/1     Running     0          6m
kube-system          kube-scheduler-kind-control-plane            1/1     Running     0          6m10s
local-path-storage   local-path-provisioner-78776bfc44-cctzz      1/1     Running     0          5m55s
```


## Run ansible

```
mkdir my_ansible_project
mkdir ansible_collections
cd ansible_collections
ansible-galaxy collection init my_namespace.my_collection
cd my_namespace/my_collection/roles
molecule init role my-new-role --driver-name docker
```

Add in the task yaml the following lines:

```
- name: Ensure the myapp Namespace exists.
  community.kubernetes.k8s:
    api_version: v1
    kind: Namespace
    name: myapp
    state: present
```

```
ansible-galaxy collection install community.kubernetes
```

Create the "ansible.cfg" file with at least the collection paths:
```
[defaults]
collections_paths = ~/.ansible/collections:/usr/share/ansible/collections:/runner/my_ansible_project
```

Create the playbook test.yml


```
- hosts: localhost
  gather_facts: true
  connection: local
  collections:
    - my_namespace.my_collection
  tasks:
      - import_role:
          name: my-new-role
```

Run

```
ansible-playbook test.yml
```

## Run argocd


Install argocd

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```


Http ingress

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-http-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: argocd-server
          servicePort: http
    host: argocd.example.com
  tls:
  - hosts:
    - argocd.example.com
    secretName: argocd-secret # do not change, this is provided by Argo CD
```

Grpc ingress

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-grpc-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/backend-protocol: "GRPC"
spec:
  rules:
  - http:
      paths:
      - backend:
          serviceName: argocd-server
          servicePort: https
    host: grpc.argocd.example.com
  tls:
  - hosts:
    - grpc.argocd.example.com
    secretName: argocd-secret # do not change, this is provided by Argo CD

```


The API server should then be run with TLS disabled. Edit the argocd-server deployment to add the --insecure flag to the argocd-server command:


```
spec:
  template:
    spec:
      containers:
      - name: argocd-server
        command:
        - argocd-server
        - --staticassets
        - /shared/app
        - --repo-server
        - argocd-repo-server:8081
        - --insecure
```
Get password

```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

```
argocd login argocd.example.com
```
admin
and passwd

To change the password

```
argocd account update-password
```

Connect to argo https://argocd.example.com

