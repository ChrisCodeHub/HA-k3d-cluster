# AIM

k3d would appear tobe ranchers alternative to KIND, but it is well documented on how you can create :  
- a 3 node HA cluster that just has 3 control-planes.  Not planning on putting much into the nodes, so don't need workers  
- add metallb to the cluster  
- add a provate registry to the setup. This is handy in that it minimises the pulls of images, & mimics an air gapped deploy  


Assumed - 
- using Ubuntu, or WSl with Ubuntu  
- Docker deployed  
- kubectl installed

## Install K3D
__NOTE__ it can be dangerous to just install direct from a script, wise people look inside them after download, and before install

```bash
$ wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
$ k3d --version
k3d version v5.8.3
k3s version v1.31.5-k3s1 (default)
```

```bash
# create a HA cluster that just has the 3 control plane nodes, no ingress, no load balancers
k3d cluster create my-ha-cluster \
  --servers 3 \
  --agents 0 \
  --k3s-arg "--disable=traefik@server:0" \
  --k3s-arg "--disable=traefik@server:1" \
  --k3s-arg "--disable=traefik@server:2" \k3d cluster create my-ha-cluster \
  --servers 3 \
  --agents 0 \
  --k3s-arg "--disable=traefik@server:0" \
  --k3s-arg "--disable=traefik@server:1" \
  --k3s-arg "--disable=traefik@server:2" \
  --k3s-arg "--disable=servicelb@server:0" \
  --k3s-arg "--disable=servicelb@server:1" \
  --k3s-arg "--disable=servicelb@server:2" \
  --port "30080:30080@server:0" \
  --wait

  
  ```
k3d cluster create my-ha-cluster --servers 3 --no-agents --k3s-arg "--disable=traefik@server:0" --wait


### Explanation of Parameters

Creates 3 control plane nodes, ensuring High Availability (HA). K3s will automatically use an embedded etcd cluster for data storage across these nodes.  

--servers 3  

Ensures no separate worker nodes are created. The server nodes will also handle workloads (since K3s allows control planes to schedule workloads).  

--no-agents

Disables Traefik, K3s' default ingress controller. Useful if you want to install NGINX, Istio or another ingress controller.

--k3s-arg "--disable=traefik@server:0"  --no-deploy traefik


Ensures the cluster is fully ready before returning.

--wait

```bash
docker ps
```

__What This Cluster Looks Like__


| Node    | Role             | Docker Container Name  | 
|---------|------------------|------------------------|
| Node    | Role             | Docker Container Name  | 
| Control | Plane (Server 1) | k3d-local-k8s-server-0 | 
| Control | Plane (Server 2) | k3d-local-k8s-server-1 | 
| Control | Plane (Server 3) | k3d-local-k8s-server-2 | 

Since K3s allows control plane nodes to also run workloads, you don't need separate worker nodes unless you want to scale out later.




# To clean up 

```bash
# check cluster names
k3d cluster list

# delete clusters
k3d cluster delete [NAME [NAME ...] | --all] [flags]

#Options
#  -a, --all             Delete all existing clusters
#  -c, --config string   Path of a config file to use
#  -h, --help            help for delete

```
|     Role                 | name                   |
|--------------------------|------------------------|
| Control Plane (Server 1) | k3d-local-k8s-server-0 | 
| Control Plane (Server 2) | k3d-local-k8s-server-1 | 
| Control Plane (Server 3) | k3d-local-k8s-server-2 | 


# TEST
to test, a simple hello world  nginx container seems like a good idea - aka `test-nginx-deployment.yaml`

```bash
kubectl apply -f test-nginx-deployment.yaml
```

```bash
# to install a sandbox with curl and be dropped to bash inside for poking around
kubectl run curlpod --image=radial/busyboxplus:curl -i --tty --rm

```

