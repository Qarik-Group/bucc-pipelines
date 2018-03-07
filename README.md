# BUCC Pipelines
This repo contains a collection of concourse pipelines which have been tested to work with [BUCC](https://github.com/starkandwayne/bucc).

## Install
First make sure you have a by following the instructions [here](https://github.com/starkandwayne/bucc#boot-your-bucc-vm).

To start using bucc-pipelines with your bucc run:

```
git clone https://github.com/starkandwayne/bucc-pipelines
cd bucc-pipelines
source <(../bucc/bin/bucc env)
bucc fly
fly -t bucc set-pipeline -p base -c <(./pipeline.sh)
```

# Usage
Next login to the concourse UI using the details from:

```
bucc info
```

You should see a pipeline called `base` which has jobs for updating every supported pipeline.

To install a pipeline just kick of a build for the pipeline you want to use.
