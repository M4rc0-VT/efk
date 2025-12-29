{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "efk-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "efk-stack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "efk-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "efk-stack.labels" -}}
helm.sh/chart: {{ include "efk-stack.chart" . }}
{{ include "efk-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "efk-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "efk-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* ============================================================================ */}}
{{/* CUSTOM HELPERS FOR EFK STACK                                        */}}
{{/* ============================================================================ */}}

{{/*
Generate the comma-separated list of Elasticsearch discovery hosts.
Result: es-cluster-0.elasticsearch,es-cluster-1.elasticsearch,...
*/}}
{{- define "elasticsearch.discoveryHosts" -}}
{{- $replicas := .Values.elasticsearch.replicaCount | int -}}
{{- $serviceName := "elasticsearch" -}}
{{- range $i, $e := until $replicas -}}
es-cluster-{{ $i }}.{{ $serviceName }}{{ if ne (add1 $i) $replicas }},{{ end }}
{{- end -}}
{{- end -}}

{{/*
Generate the comma-separated list of initial Elasticsearch master nodes.
Result: es-cluster-0,es-cluster-1,...
*/}}
{{- define "elasticsearch.masterNodes" -}}
{{- $replicas := .Values.elasticsearch.replicaCount | int -}}
{{- range $i, $e := until $replicas -}}
es-cluster-{{ $i }}{{ if ne (add1 $i) $replicas }},{{ end }}
{{- end -}}
{{- end -}}

{{/*
Create the regex pattern for excluded Fluentd containers.
Result: kafka|nginx|controller
*/}}
{{- define "fluentd.excludePattern" -}}
{{- .Values.fluentd.excludeContainers | join "|" -}}
{{- end -}}