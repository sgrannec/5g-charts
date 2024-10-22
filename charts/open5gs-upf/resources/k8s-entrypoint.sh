#!/bin/bash
set -ex

echo "Executing k8s customized entrypoint.sh"
echo "Deleting net device ogstun"
ip tuntap del ogstun mode tun

{{- range .Values.config.subnetList }}
{{- if .createDev }}
echo "Creating net device {{ .dev }}"
echo "if grep "{{ .dev }}" /proc/net/dev > /dev/null; then"
echo "    echo "Warnin: Net device {{ .dev }} already exists! may you need to set createDev: false";"
echo "    exit 1"
echo "fi"

ip tuntap add name {{ .dev }} mode tun
ip link set {{ .dev }} up
echo "Setting IP {{ .gateway }} to device {{ .dev }}"
ip addr add {{ .gateway }}/{{ .mask }} dev {{ .dev }};
sysctl -w net.ipv4.ip_forward=1;
{{- if .enableNAT }}
echo "Enable NAT for {{ .subnet }} and device {{ .dev }}"
iptables -t nat -A POSTROUTING -s {{ .subnet }} ! -o {{ .dev }} -j MASQUERADE;
iptables -I FORWARD -i ogstun -j ACCEPT;
{{- end }}
{{- end }}
{{- end }}

$@
