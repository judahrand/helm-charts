{{- if .Values.rbac.create -}}
{{/* Rules mirror upstream deploy.yaml. */}}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ include "multi-networkpolicy-nftables.fullname" . }}
  labels:
    {{- include "multi-networkpolicy-nftables.labels" . | nindent 4 }}
  {{- with .Values.rbac.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
rules:
  - apiGroups: ["k8s.cni.cncf.io"]
    resources: ["*"]
    verbs: ["*"]
  - apiGroups: [""]
    resources: ["pods", "pods/status", "namespaces"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["networkpolicies"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ include "multi-networkpolicy-nftables.fullname" . }}
  labels:
    {{- include "multi-networkpolicy-nftables.labels" . | nindent 4 }}
  {{- with .Values.rbac.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ include "multi-networkpolicy-nftables.fullname" . }}
subjects:
  - kind: ServiceAccount
    name: {{ include "multi-networkpolicy-nftables.serviceAccountName" . }}
    namespace: {{ .Release.Namespace }}
{{- end }}
