// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go gitlab.agodadev.io/fleet/etcd/api/v1

package v1

import (
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	corev1 "k8s.io/api/core/v1"
)

// EtcdTenantList contains a list of EtcdTenant
#EtcdTenantList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#EtcdTenant] @go(Items,[]EtcdTenant)
}

// EtcdTenant is the Schema for the etcdtenants API
#EtcdTenant: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta @go(ObjectMeta)
	spec?:     #EtcdTenantSpec    @go(Spec)
	status?:   #EtcdTenantStatus  @go(Status)
}

#EtcdTenantSpec: {
	// Target cluster
	cluster: #ObjectRef @go(Cluster)

	// Explicitly specify target secret name
	// +optional
	secretName?: string @go(SecretName)
}

#EtcdTenantStatus: {
	// Lifecycle phase
	// +optional
	phase?: #TenantConditionType @go(Phase)

	// Latest service status of tenant
	// +listType=map
	// +listMapKey=type
	// +optional
	conditions?: [...#TenantCondition] @go(Conditions,[]TenantCondition)

	// ETCD key prefix
	// +optional
	prefix?: string @go(Prefix)

	// ETCD endpoint
	// +optional
	endpoint?: string @go(Endpoint)

	// Effective credentials secret name
	// Secret is located in same namespace as tenant
	// +optional
	secretName?: string @go(SecretName)
}

#ObjectRef: {
	namespace?: string @go(Namespace)
	name?:      string @go(Name)
}

#TenantCondition: {
	type:                #TenantConditionType    @go(Type)
	status:              corev1.#ConditionStatus @go(Status)
	lastTransitionTime?: metav1.#Time            @go(LastTransitionTime)
	reason?:             string                  @go(Reason)
	message?:            string                  @go(Message)
}

#TenantConditionType: string // #enumTenantConditionType

#enumTenantConditionType:
	#TenantPending |
	#TenantIssuing |
	#TenantReady

#TenantPending: #TenantConditionType & "Pending"
#TenantIssuing: #TenantConditionType & "Issuing"
#TenantReady:   #TenantConditionType & "Ready"
