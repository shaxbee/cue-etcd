# Cue ETCD Reconciler

## Example

Given cluster spec in [cluster.yaml](cluster.yaml) and members in [members.yaml](members.yaml) generate cluster pods.

```sh
cue eval . -l cluster: *.yaml -e resources --out=yaml
```