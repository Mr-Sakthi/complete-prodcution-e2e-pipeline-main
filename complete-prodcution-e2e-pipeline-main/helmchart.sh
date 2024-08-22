#!/bin/bash

# Create Helm chart directory structure
mkdir -p sakthi-chart/templates

# Create Chart.yaml
cat <<EOF > sakthi-chart/Chart.yaml
apiVersion: v2
name: sakthi
description: A Helm chart for deploying your Kubernetes application
version: 1.0.0
appVersion: "1.0"
EOF

# Create values.yaml
cat <<EOF > sakthi-chart/values.yaml
image:
  repository: mrsakthi
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

resources: {}
EOF

# Create templates/deployment.yaml
cat <<EOF > sakthi-chart/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "sakthi.fullname" . }}
  labels:
    app: {{ include "sakthi.name" . }}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {{ include "sakthi.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "sakthi.name" . }}
    spec:
      containers:
      - name: {{ include "sakthi.name" . }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: 80
        resources:
{{- toYaml .Values.resources | nindent 12 }}
EOF

# Create templates/service.yaml
cat <<EOF > sakthi-chart/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "sakthi.fullname" . }}
spec:
  type: {{ .Values.service.type }}
  ports:
    - port: {{ .Values.service.port }}
  selector:
    app: {{ include "sakthi.name" . }}
EOF

# Create templates/_helpers.tpl
cat <<EOF > sakthi-chart/templates/_helpers.tpl
{{- define "sakthi.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- define "sakthi.fullname" -}}
{{ include "sakthi.name" . }}-{{ .Release.Name }}
{{- end -}}
EOF

# Install the Helm chart
helm install sakthi-release ./sakthi-chart
