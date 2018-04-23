#!/usr/bin/env bash
curl -X POST -H "Content-Type: application/json" -d '{"name":"kong-dashborad", "uris":"/kong-dashborad/", "upstream_url":"http://kong-dashboard.default:8080"}' $1:8001/apis/
