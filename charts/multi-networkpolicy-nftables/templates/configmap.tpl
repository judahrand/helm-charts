{{- if .Values.customRules.enabled -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "multi-networkpolicy-nftables.fullname" . }}-custom-v4-rules
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "multi-networkpolicy-nftables.labels" . | nindent 4 }}
data:
  custom-v4-rules.txt: |
    {{- .Values.customRules.ipv4 | trimSuffix "\n" | nindent 4 }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "multi-networkpolicy-nftables.fullname" . }}-custom-v6-rules
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "multi-networkpolicy-nftables.labels" . | nindent 4 }}
data:
  custom-v6-rules.txt: |
    {{- .Values.customRules.ipv6 | trimSuffix "\n" | nindent 4 }}
{{- end }}
