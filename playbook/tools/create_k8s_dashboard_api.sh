#!/usr/bin/env bash
curl -X POST -H "Content-Type: application/json" -d '{"name":"k8s-dashboard", "uris":"/dashboard/", "upstream_url":"https://kubernetes-dashboard.kube-system"}' $1:8001/apis/
