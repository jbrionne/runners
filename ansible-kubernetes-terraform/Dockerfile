FROM centos:centos7.9.2009

RUN yum install -y epel-release
RUN yum install -y net-tools git gcc jq python-dns yum-utils iproute

RUN yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

RUN yum install -y docker-ce docker-ce-cli containerd.io

ADD requirements.txt /requirements.txt

RUN yum install -y python3 python3-devel
RUN pip3 install --upgrade pip
RUN pip3 install -U python-openstackclient python-octaviaclient
RUN pip3 install -r requirements.txt

RUN curl -L -s --fail https://dl.k8s.io/v1.19.7/kubernetes-client-linux-amd64.tar.gz -o kubernetes-client-linux-amd64.tar.gz && \
    tar xvf kubernetes-client-linux-amd64.tar.gz --strip-components 3 kubernetes/client/bin/ && \
    rm kubernetes-client-linux-amd64.tar.gz && \
    mv /kubectl /usr/bin/

RUN mkdir -p /root/.terraform.d/plugins/linux_amd64/

RUN yum install -y unzip

RUN curl -L -s --fail https://releases.hashicorp.com/terraform/0.12.30/terraform_0.12.30_linux_amd64.zip -o terraform_0.12.30_linux_amd64.zip && \
    unzip terraform_0.12.30_linux_amd64.zip && \
    rm terraform_0.12.30_linux_amd64.zip && \
    mv /terraform /usr/bin/

RUN curl -L -s --fail https://releases.hashicorp.com/terraform-provider-null/2.1.2/terraform-provider-null_2.1.2_linux_amd64.zip -o terraform-provider-null_2.1.2_linux_amd64.zip && \
    unzip terraform-provider-null_2.1.2_linux_amd64.zip && \
    rm terraform-provider-null_2.1.2_linux_amd64.zip && \
    mkdir -p /root/.terraform.d/plugins/linux_amd64/ && \
    mv /terraform-provider-null_v2.1.2_x4 /root/.terraform.d/plugins/linux_amd64/terraform-provider-null


RUN curl -L -s --fail https://releases.hashicorp.com/terraform-provider-openstack/1.24.0/terraform-provider-openstack_1.24.0_linux_amd64.zip -o terraform-provider-openstack_1.24.0_linux_amd64.zip && \
    unzip terraform-provider-openstack_1.24.0_linux_amd64.zip && \
    rm terraform-provider-openstack_1.24.0_linux_amd64.zip && \
    mkdir -p /root/.terraform.d/plugins/linux_amd64/ && \
    mv /terraform-provider-openstack_v1.24.0_x4 /root/.terraform.d/plugins/linux_amd64/


RUN chmod +x /usr/bin/kubectl \
    && chmod +x /usr/bin/terraform \
    && chmod +x /root/.terraform.d/plugins/linux_amd64/ -R

RUN curl -L -s --fail https://raw.githubusercontent.com/viczem/ansible-keepass/main/keepass.py -o keepass.py && \
    mkdir -p /usr/share/ansible/plugins/lookup && \
    mv keepass.py /usr/share/ansible/plugins/lookup/keepass.py

RUN export VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/') && \
    curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd

RUN mkdir -p /runner /root/.kube
ENV KUBECONFIG /runner/kubeconfig
WORKDIR /runner
