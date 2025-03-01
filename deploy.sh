#! /bin/sh
k3d cluster create my-ha-cluster \
  --servers 3 \
  --agents 0 \
  --k3s-arg "--disable=traefik@server:0" \
  --k3s-arg "--disable=traefik@server:1" \
  --k3s-arg "--disable=traefik@server:2" \
  --k3s-arg "--disable=servicelb@server:0" \
  --k3s-arg "--disable=servicelb@server:1" \
  --k3s-arg "--disable=servicelb@server:2" \
  --wait