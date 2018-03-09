# How to configure the shield-pipeline for BUCC

## defaults
- static_ip: `10.244.0.34`
- domain: `10.244.0.34`
- opsfiles: `bucc-pipelines/shield/operators/bbr.yml, bucc-pipelines/shield/operators/webdav.yml, shield-deployment/manifests/operators/dev.yml`

## operator files
#### set ops_files
login to credhub with `bucc credhub`
example for setting aws
`credhub set -n /main/concourse/shield/ops_files -t json -v '{"value":["bucc-pipelines/shield/operators/bbr","bucc-pipelines/shield/operators/aws"]}'`

###### bucc-pipelines/shield/operators/bbr (required)
configures shield to backup the bosh director
###### bucc-pipelines/shield/operators/webdav
adds a webdav server, and configure shield to use it as the default store
###### bucc-pipelines/shield/operators/aws
configures shield to use the s3 as your default store
reguires:
- access_key_id
- secret_access_key
- bucket
###### bucc-pipelines/shield/operators/dev
always uses the latest shield/stemcell version (for dev purposes only)
