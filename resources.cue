package etcd

import (
	corev1 "k8s.io/api/core/v1"
)

resources: all: corev1.#List

resources: pod: [_namespace=string]: [_name=string]: corev1.#Pod

resources: all: {
    apiVersion: "v1"
    kind: "List" 
    items: _all
}

let _all = _pods
let _pods = [ for _, _pods in resources.pod for _, _pod in _pods {_pod}]
