---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ include "multi-networkpolicy-nftables.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    {{- include "multi-networkpolicy-nftables.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "multi-networkpolicy-nftables.selectorLabels" . | nindent 6 }}
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "multi-networkpolicy-nftables.labels" . | nindent 8 }}
        {{- with .Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
    spec:
      enableServiceLinks: false
      hostNetwork: true
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      serviceAccountName: {{ include "multi-networkpolicy-nftables.serviceAccountName" . }}
      {{- with .Values.priorityClassName }}
      priorityClassName: {{ . }}
      {{- end }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: multi-networkpolicy-nftables
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: {{ include "multi-networkpolicy-nftables.image" . }}
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          args:
            - --zap-log-level={{ .Values.controller.logLevel }}
            - --container-runtime-endpoint={{ .Values.controller.containerRuntimeEndpoint }}
            - --network-plugins={{ .Values.controller.networkPlugins }}
            {{- if .Values.host.prefix }}
            - --host-prefix={{ .Values.host.prefix }}
            {{- end }}
            {{- if .Values.controller.acceptICMP }}
            - --accept-icmp
            {{- end }}
            {{- if .Values.controller.acceptICMPv6 }}
            - --accept-icmpv6
            {{- end }}
            {{- if .Values.customRules.enabled }}
            - --custom-v4-ingress-rule-file=/etc/multi-networkpolicy/rules/custom-v4-rules.txt
            - --custom-v4-egress-rule-file=/etc/multi-networkpolicy/rules/custom-v4-rules.txt
            - --custom-v6-ingress-rule-file=/etc/multi-networkpolicy/rules/custom-v6-rules.txt
            - --custom-v6-egress-rule-file=/etc/multi-networkpolicy/rules/custom-v6-rules.txt
            {{- end }}
            {{- range .Values.controller.extraArgs }}
            - {{ . }}
            {{- end }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
          volumeMounts:
            - name: host
              mountPath: {{ .Values.host.prefix }}
            {{- if .Values.customRules.enabled }}
            - name: custom-rules
              mountPath: /etc/multi-networkpolicy/rules
              readOnly: true
            {{- end }}
      volumes:
        - name: host
          hostPath:
            path: {{ .Values.host.path }}
        {{- if .Values.customRules.enabled }}
        - name: custom-rules
          projected:
            sources:
              - configMap:
                  name: {{ include "multi-networkpolicy-nftables.fullname" . }}-custom-v4-rules
              - configMap:
                  name: {{ include "multi-networkpolicy-nftables.fullname" . }}-custom-v6-rules
        {{- end }}
      {{- with .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with .Values.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
