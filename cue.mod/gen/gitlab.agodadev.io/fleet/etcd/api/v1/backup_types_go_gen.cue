// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go gitlab.agodadev.io/fleet/etcd/api/v1

package v1

import metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

// +kubebuilder:object:root=true
// BackupRequestList contains a list of BackupRequest
#BackupRequestList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#BackupRequest] @go(Items,[]BackupRequest)
}

// +kubebuilder:object:root=true
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="Status",type=string,JSONPath=`.status.phase`
// +kubebuilder:printcolumn:name="Object",type=string,JSONPath=`.status.object`
// +kubebuilder:printcolumn:name="Age",type="date",JSONPath=".metadata.creationTimestamp"
#BackupRequest: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta   @go(ObjectMeta)
	spec:      #BackupRequestSpec   @go(Spec)
	status?:   #BackupRequestStatus @go(Status)
}

#BackupRequestSpec: {
	etcd: #EtcdSpec   @go(Etcd)
	s3?:  #ObjectSpec @go(S3)
}

#BackupRequestStatus: {
	// Lifecycle phase
	// +optional
	phase?: string @go(Phase)

	// Latest job status
	// +listType=map
	// +listMapKey=type
	// +optional
	conditions?: [...#JobCondition] @go(Conditions,[]JobCondition)

	// Effective S3 backup object path
	object?: string @go(Object)
}

// +kubebuilder:object:root=true
// RestoreRequestList contains a list of RestoreRequest
#RestoreRequestList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta)
	items: [...#RestoreRequest] @go(Items,[]RestoreRequest)
}

// +kubebuilder:object:root=true
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="Status",type=string,JSONPath=`.status.phase`
// +kubebuilder:printcolumn:name="Age",type="date",JSONPath=".metadata.creationTimestamp"
#RestoreRequest: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta    @go(ObjectMeta)
	spec:      #RestoreRequestSpec   @go(Spec)
	status?:   #RestoreRequestStatus @go(Status)
}

#RestoreRequestSpec: {
	clusterName: string           @go(ClusterName)
	clusterSpec: #EtcdClusterSpec @go(ClusterSpec)
	s3?:         #ObjectSpec      @go(S3)
}

#RestoreRequestStatus: {
	// Lifecycle phase
	// +optional
	phase?: string @go(Phase)

	// Latest job status
	// +listType=map
	// +listMapKey=type
	// +optional
	conditions?: [...#JobCondition] @go(Conditions,[]JobCondition)
}

// BackupSpec defines the backup configuration of EtcdCluster
#BackupSpec: {
	enabled?:  bool   @go(Enabled)
	schedule?: string @go(Schedule)

	#S3Spec
}

#ObjectSpec: {
	#S3Spec

	// +kubebuilder:validation:Pattern=`^[A-Za-z0-9_]*$`
	id?:     string @go(ID)
	object?: string @go(Object)
}

#S3Spec: {
	endpoint?:   string @go(Endpoint)
	bucket?:     string @go(Bucket)
	secretName?: string @go(SecretName)
}

#EtcdSpec: {
	endpoint?:    string @go(Endpoint)
	clusterName?: string @go(ClusterName)
	memberName?:  string @go(MemberName)
	secretName?:  string @go(SecretName)
}
