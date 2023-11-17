package etcd

import (
	corev1 "k8s.io/api/core/v1"
)

let _cluster = cluster.metadata
let _spec = cluster.spec

for _member in cluster.members {
	let _hostname = "\(_member.name).\(_cluster.name).\(_cluster.namespace).svc.cluster.local"
	let _pod = {
		apiVersion: "v1"
		kind:       "Pod"
		metadata: {
			namespace: _cluster.namespace
			name:      _member.name
		}
		spec: volumes: [
			{
				name: "data"
				emptyDir: {
					medium:    "Memory"
					sizeLimit: _spec.storageQuota
				}
			},
			{
				name: "server-tls"
				secret: {
					secretName: _member.name + "-server-cert"
				}
			},
			{
				name: "peer-tls"
				secret: {
					secretName: _member.name + "-peer-cert"
				}
			},
		]
		spec: containers: [_container & {
			env: [
				{
					name:  "ETCD_NAME"
					value: _member.name
				},
				{
					name:  "ETCD_INITIAL_CLUSTER_TOKEN"
					value: _cluster.name
				},
				{
					name:  "ETCD_INITIAL_CLUSTER_STATE"
					value: _member.state
				},
				{
					name:  "ETCD_ADVERTISE_CLIENT_URLS"
					value: "https://\(_hostname):2379"
				},
				{
					name:  "ETCD_INITIAL_ADVERTISE_PEER_URLS"
					value: "https://\(_hostname):2380"
				},
			]
		}]
		spec: initContainers: [_initContainer & {
			env: [
				{
					name:  "SERVICE"
					value: "_etcd-server-ssl._tcp.\(_hostname)"
				},
				{
					name:  "MEMBER"
					value: _member.name
				},
				{
					name:  "TIMEOUT_READY"
					value: "120"
				},
			]
		}]
	} & corev1.#Pod

	resources: pod: (_cluster.namespace): (_member.name): _pod
}

let _container = {
	name:  "etcd"
	image: "etcd:" + _spec.version
	if _spec.runtimeClassName != _|_ {
		runtimeClassName: _spec.runtimeClassName
	}
	command: [
		"etcd",

		"--experimental-initial-corrupt-check=true",
		"--experimental-watch-progress-notify-interval=5s",

		"--data-dir=/var/lib/etcd/data",
		"--quota-backend-bytes=" + _spec.storageQuota,
		"--snapshot-count=10000",
		"--auto-compaction-mode=revision",
		"--auto-compaction-retention=1000",

		"--listen-client-urls=https://0.0.0.0:2379",
		"--listen-peer-urls=https://0.0.0.0:2380",
		"--listen-metrics-urls=http://0.0.0.0:2381",

		"--client-cert-auth=true",
		"--trusted-ca-file=/etc/etcd/pki/server/ca.crt",
		"--cert-file=/etc/etcd/pki/server/tls.crt",
		"--key-file=/etc/etcd/pki/server/tls.key",

		"--peer-client-cert-auth=true",
		"--peer-trusted-ca-file=/etc/etcd/pki/peer/ca.crt",
		"--peer-cert-file=/etc/etcd/pki/peer/tls.crt",
		"--peer-key-file=/etc/etcd/pki/peer/tls.key",
	]
	resources: _spec.resources
	volumeMounts: [
		{
			name:      "data"
			mountPath: "/var/lib/etcd"
		},
		{
			name:      "server-tls"
			mountPath: "etc/etcd/pki/server"
			readOnly:  true
		},
		{
			name:      "peer-tls"
			mountPath: "/etc/etcd/pki/peer"
			readOnly:  true
		},
	]
	startupProbe: _probe & {
		failureThreshold:    24
		initialDelaySeconds: 5
	}
	livenessProbe: _probe & {
		failureThreshold: 8
	}
} & corev1.#Container

let _initContainer = {
	name:  "check-dns-records"
	image: "busybox:1.36.0-glibc"
	command: ["/bin/sh", "-c", _checkDnsScript]
} & corev1.#Container

let _probe = {
	successThreshold: 1
	periodSeconds:    5
	timeoutSeconds:   15
	httpGet: {
		path:   "/health?serializable=true"
		port:   2381
		scheme: "HTTP"
	}
} & corev1.#Probe

let _checkDnsScript = ##"""
	while ( ! nslookup -type=SRV "${SERVICE}" | grep "${MEMBER}" )
	do
		# If TIMEOUT_READY is 0 we should never time out and exit
		TIMEOUT_READY=$(( TIMEOUT_READY-1 ))
		if [ $TIMEOUT_READY -eq 0 ];
		then
			echo "Timed out waiting for DNS entry"
			exit 1
		fi
		sleep 1
	done
	"""##
