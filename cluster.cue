package etcd

import (
	etcdv1 "gitlab.agodadev.io/fleet/etcd/api/v1"
)

#Member: {
	name!:  string
	state!: "new" | "existing"
}

cluster: {
	metadata!: {
		name!:     string
		namespace: string | *"default"
	}
	spec!: {
		replicas: int | >=0 & <=7
		version:  string | *"v3.5"
		resources: {
			requests: {
				cpu:    string | *"4"
				memory: string | *"4G"
			}
			limits: {
				cpu:    string | *"4"
				memory: string | *"4G"
			}
		}
		storageQuota: string | *"4G"
	} & etcdv1.#EtcdClusterSpec
	members!: [...#Member]
}
