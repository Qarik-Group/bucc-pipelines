#!/bin/bash

read -r -d '' template <<'EOF'
- type: replace
  path: /jobs/-
  value:
    name: update-((name))-pipeline
    plan:
    - get: repo
      trigger: true
      resource: repo-((name))
    - put: credhub
      resource: credhub-((name))
      params:
        schema_file: repo/((name))/schema.yml
    - put: concourse
      params:
        pipelines:
        - name: ((name))
          team: main
          config_file: repo/((name))/pipeline.yml
- type: replace
  path: /resources/-
  value:
    name: repo-((name))
    type: git
    source:
      uri: "https://github.com/starkandwayne/bucc-pipelines"
      paths: ["((name))/*"]
      branch: shield
- type: replace
  path: /resources/-
  value:
    name: credhub-((name))
    type: credhub-schema
    source:
      server: ((credhub_url))
      client_name: ((credhub_username))
      client_secret: ((credhub_password))
      ca_cert: ((credhub_ca_cert))
      path: /concourse/main/((name))
EOF

read -r -d '' base <<'EOF'
jobs:
- name: update-base-pipeline
  plan:
  - get: repo
    trigger: true
    resource: repo-base
  - task: generate-base-pipeline
    config:
      platform: linux
      image_resource: { type: docker-image, source: { repository: alpine } }
      inputs: [name: repo]
      outputs: [name: pipeline]
      run:
        path: /bin/sh
        args:
        - -exc
        - |
          apk add --no-cache curl bash > /dev/null
          curl -L -q https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.48-linux-amd64 > /usr/local/bin/bosh
          chmod +x /usr/local/bin/bosh
          cd repo && ./pipeline.sh > ../pipeline/pipeline.yml
  - put: concourse
    params:
      pipelines:
      - name: base
        team: main
        config_file: pipeline/pipeline.yml

resources:
- name: repo-base
  type: git
  source:
    uri: "https://github.com/starkandwayne/bucc-pipelines"
    branch: shield
- name: concourse
  type: concourse-pipeline
  source:
    target: ((concourse_url))
    insecure: "true"
    teams:
    - name: main
      username: ((concourse_username))
      password: ((concourse_password))

resource_types:
- name: concourse-pipeline
  type: docker-image
  source:
    repository: concourse/concourse-pipeline-resource
    tag: latest

- name: credhub-schema
  type: docker-image
  source:
    repository: rkoster/credhub-schema-resource
    tag: latest
EOF

bosh int <(echo -e "${base}") -o \
     <(for pipeline in $(find * -maxdepth 0 -type d); do
           bosh int <(echo -e "${template}") -v name="${pipeline}"
       done)
