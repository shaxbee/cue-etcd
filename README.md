# Cue ETCD Reconciler

## Example

Cluster is defined in [cluster.yaml](cluster.yaml) and members in [members.yaml](members.yaml).

List all resources in format accepted by `kubectl`:
```sh
cue eval . -l cluster: *.yaml -e 'resources.all' --out yaml    
```

Get single member pod:
```sh
cue eval . -l cluster: *.yaml -e 'resources.pod["test"]["foo-uy653"]' --out yaml 
```