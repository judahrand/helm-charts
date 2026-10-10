# multi-networkpolicy-nftables

Deploys the MultiNetworkPolicy controller, which enforces NetworkPolicy semantics on secondary (net-attach-def) interfaces with nftables, together with the MultiNetworkPolicy CRD.

**Homepage:** <https://github.com/home-operations/helm-charts>

## Usage

```sh
helm install multi-networkpolicy-nftables oci://ghcr.io/home-operations/charts/multi-networkpolicy-nftables \
  --namespace kube-system
```

The chart deploys the [multi-networkpolicy-nftables](https://github.com/k8snetworkplumbingwg/multi-networkpolicy-nftables)
controller as a DaemonSet. It watches `MultiNetworkPolicy` objects and programs
nftables rules inside the network namespace of the pods they select, covering the
secondary interfaces that standard Kubernetes `NetworkPolicy` cannot reach.

This is the nftables implementation of the
[network plumbing working group](https://github.com/k8snetworkplumbingwg/multi-networkpolicy)
multi-network policy API; the CRD ships in the chart's `crds/` directory.

### Host prerequisites

The controller runs privileged on the host network and reads the host root
filesystem, so it needs:

- the `nf_tables` kernel module (`modprobe nf_tables`; built into the Talos
  kernel),
- the CRI socket reachable under `host.prefix`. The chart defaults to containerd
  at `/run/containerd/containerd.sock`; set `controller.containerRuntimeEndpoint`
  to `/run/crio/crio.sock` for CRI-O or another runtime.

The controller connects to the CRI socket at `host.prefix + controller.containerRuntimeEndpoint`
and resolves pod network namespaces at `host.prefix + /proc/<pid>/ns/net`, which is
why the host root is mounted at `host.prefix`.

## CRDs

The MultiNetworkPolicy CRD ships in the chart's `crds/` directory, vendored
unmodified from the [multi-networkpolicy](https://github.com/k8snetworkplumbingwg/multi-networkpolicy)
release pinned in `vendir.yml` (`mise run crds`). Helm's native CRD handling
applies: the CRD is installed on first install (skip with `--skip-crds`), and
`helm upgrade` and `helm uninstall` never touch it, so your MultiNetworkPolicies
survive chart removal. Because Helm does not upgrade CRDs, apply the one matching
the chart after upgrading across a vendir bump:

```sh
helm show crds oci://ghcr.io/home-operations/charts/multi-networkpolicy-nftables | kubectl apply --server-side -f -
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| home-operations | <contact@home-operations.com> |  |

## Source Code

* <https://github.com/k8snetworkplumbingwg/multi-networkpolicy-nftables>
* <https://github.com/k8snetworkplumbingwg/multi-networkpolicy>

## Requirements

Kubernetes: `>=1.25.0-0`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity rules for pod scheduling. |
| controller.acceptICMP | bool | `true` | Accept all ICMP traffic (path MTU discovery). |
| controller.acceptICMPv6 | bool | `true` | Accept all ICMPv6 traffic (IPv6 neighbour discovery). |
| controller.containerRuntimeEndpoint | string | `"/run/containerd/containerd.sock"` | Path to the CRI socket, relative to `host.prefix`. Defaults to containerd; set `/run/crio/crio.sock` on CRI-O. |
| controller.extraArgs | list | `[]` | Additional arguments passed to the controller. |
| controller.logLevel | int | `2` | zap log level (higher is more verbose). |
| controller.networkPlugins | string | `"macvlan,ipvlan"` | Comma-separated CNI plugins whose net-attach-defs are enforced (the upstream deploy manifest enables macvlan and ipvlan). |
| customRules.enabled | bool | `true` | Create and mount the custom-rule ConfigMaps (common rules applied to every policy; the files are read once at controller start). |
| customRules.ipv4 | string | `"# Add custom IPv4 rules here if needed\n"` | Custom IPv4 ingress and egress rules. |
| customRules.ipv6 | string | `"# Add custom IPv6 rules here if needed\n"` | Custom IPv6 ingress and egress rules. |
| fullnameOverride | string | `""` | Override the full release name. |
| host.path | string | `"/"` | Host root filesystem path mounted at `host.prefix`. |
| host.prefix | string | `"/host"` | Prefix under which the host root filesystem is mounted; the controller reads the CRI socket and pod network namespaces beneath it. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"ghcr.io/k8snetworkplumbingwg/multi-networkpolicy-nftables"` | Image repository. |
| image.tag | string | `""` | Overrides the image tag; defaults to the chart appVersion. |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries. |
| nameOverride | string | `""` | Override the chart name used in resource names. |
| nodeSelector | object | `{}` | Node selector for pod scheduling. |
| podAnnotations | object | `{}` | Annotations added to the pod. |
| podLabels | object | `{}` | Labels added to the pod. |
| podSecurityContext | object | `{}` | Pod-level securityContext (the controller enters pod network namespaces and must run as root on the host network). |
| priorityClassName | string | `"system-node-critical"` | Priority class name for pod scheduling (node infrastructure: must not be evicted from any node). |
| rbac.annotations | object | `{}` | Annotations for the RBAC resources. |
| rbac.create | bool | `true` | Create the ClusterRole/ClusterRoleBinding (rules mirror the upstream deploy.yaml). |
| resources | object | `{}` | Pod resource requests/limits. |
| securityContext | object | `{"capabilities":{"add":["SYS_ADMIN","NET_ADMIN"]},"privileged":true}` | Container securityContext (privileged: the controller uses setns and writes nftables rules inside pod network namespaces). |
| serviceAccount.annotations | object | `{}` | Annotations for the ServiceAccount. |
| serviceAccount.automount | bool | `true` | Automount the API token (on by default: the controller watches the cluster API). |
| serviceAccount.create | bool | `true` | Create a ServiceAccount. |
| serviceAccount.name | string | `""` | ServiceAccount name; generated from the release name if empty. |
| tolerations | list | `[{"key":"CriticalAddonsOnly","operator":"Exists"}]` | Tolerations for pod scheduling (defaults keep the DaemonSet on critical-addons-only nodes). |

---

_This README is generated by [helm-docs](https://github.com/norwoodj/helm-docs) from `Chart.yaml` and `values.yaml`. Edit those (or `README.md.gotmpl`) and run `mise run helm-docs`._
