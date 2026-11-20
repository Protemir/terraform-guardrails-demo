# Общий слой для всех правил.
# Нормализует два вида входа в один список ресурсов:
#   1) JSON-план (terraform show -json plan.out / tofu show -json) — основной режим в CI;
#   2) HCL, разобранный conftest --parser hcl2 — статическая проверка чужого кода (TerraGoat, модули реестра).
package lib.iac

import rego.v1

is_plan if input.resource_changes

# ---------- ресурсы ----------

# {address, type, name, values, unknown, mode}
resources contains r if {
	some rc in input.resource_changes
	rc.mode == "managed"
	not rc.change.actions == ["delete"]
	r := {
		"address": rc.address,
		"type": rc.type,
		"name": rc.name,
		"values": object.get(rc.change, "after", {}),
		"unknown": object.get(rc.change, "after_unknown", {}),
	}
}

resources contains r if {
	not is_plan
	some rtype, byname in obj(input, "resource")
	some name, blocks in byname
	some b in blocks
	r := {
		"address": sprintf("%s.%s", [rtype, name]),
		"type": rtype,
		"name": name,
		"values": b,
		"unknown": {},
	}
}

of_type(t) := {r | some r in resources; r.type == t}

of_types(ts) := {r | some r in resources; r.type in ts}

# Первый элемент вложенного блока (в JSON блоки — это списки).
block(o, key) := b if {
	l := object.get(o, key, [])
	is_array(l)
	count(l) > 0
	b := l[0]
} else := b if {
	b := object.get(o, key, {})
	is_object(b)
} else := {}

# Значение атрибута; null и отсутствие дают default.
val(o, key, d) := v if {
	v := object.get(o, key, d)
	v != null
} else := d

# Список-атрибут; null, отсутствие или выражение дают [].
arr(o, key) := v if {
	v := object.get(o, key, [])
	is_array(v)
} else := []

# Объект-атрибут (labels, tags); null или выражение дают {}.
obj(o, key) := v if {
	v := object.get(o, key, {})
	is_object(v)
} else := {}

# Настройки пакета (списки разрешённых источников и т.п.), см. policies/config.yaml.
default config := {}

config := data.config

# Литерал, а не выражение HCL вида "${...}".
is_literal(v) if {
	is_string(v)
	not contains(v, "${")
}

is_literal(v) if not is_string(v)

# ---------- вызовы модулей ----------

# {name, source, version}
module_calls contains m if {
	is_plan
	walk(object.get(input, "configuration", {}), [path, v])
	n := count(path)
	n >= 2
	path[n - 2] == "module_calls"
	m := {"name": path[n - 1], "source": object.get(v, "source", ""), "version": object.get(v, "version_constraint", "")}
}

module_calls contains m if {
	not is_plan
	some name, blocks in obj(input, "module")
	some b in blocks
	m := {"name": name, "source": object.get(b, "source", ""), "version": object.get(b, "version", "")}
}

# ---------- провайдеры ----------

# {name, version}
providers contains p if {
	is_plan
	some key, cfg in obj(object.get(input, "configuration", {}), "provider_config")
	p := {"name": object.get(cfg, "full_name", key), "version": object.get(cfg, "version_constraint", "")}
}

providers contains p if {
	not is_plan
	some t in arr(input, "terraform")
	some rp in arr(t, "required_providers")
	some name, spec in rp
	version := provider_version(spec)
	p := {"name": name, "version": version}
}

provider_version(spec) := object.get(spec, "version", "") if is_object(spec)

provider_version(spec) := spec if is_string(spec)

# ---------- Kubernetes: поды и контейнеры ----------

workload_types := {
	"kubernetes_deployment_v1", "kubernetes_deployment",
	"kubernetes_stateful_set_v1", "kubernetes_stateful_set",
	"kubernetes_daemon_set_v1", "kubernetes_daemonset",
	"kubernetes_replication_controller_v1",
	"kubernetes_job_v1", "kubernetes_job",
}

# {address, spec, res}
pod_specs contains p if {
	some r in of_types(workload_types)
	some s in arr(r.values, "spec")
	some t in arr(s, "template")
	some ps in arr(t, "spec")
	p := {"address": r.address, "spec": ps, "res": r}
}

pod_specs contains p if {
	some r in of_types({"kubernetes_pod_v1", "kubernetes_pod"})
	some ps in arr(r.values, "spec")
	p := {"address": r.address, "spec": ps, "res": r}
}

pod_specs contains p if {
	some r in of_types({"kubernetes_cron_job_v1", "kubernetes_cron_job"})
	some s in arr(r.values, "spec")
	some jt in arr(s, "job_template")
	some js in arr(jt, "spec")
	some t in arr(js, "template")
	some ps in arr(t, "spec")
	p := {"address": r.address, "spec": ps, "res": r}
}

# {address, c, pod, kind}
containers contains x if {
	some p in pod_specs
	some kind in ["container", "init_container"]
	some c in arr(p.spec, kind)
	x := {"address": p.address, "c": c, "pod": p.spec, "kind": kind}
}

container_name(c) := object.get(c, "name", "?")

# securityContext контейнера (может отсутствовать)
csc(c) := block(c, "security_context")

podsc(pod) := block(pod, "security_context")

metadata(r) := block(r.values, "metadata")

labels(r) := obj(metadata(r), "labels")

# ---------- пространства имён ----------

namespaces contains n if {
	some r in of_types({"kubernetes_namespace_v1", "kubernetes_namespace"})
	name := val(metadata(r), "name", "")
	n := {"address": r.address, "name": name, "res": r}
}

# Ссылается ли значение на пространство имён: литералом имени или выражением HCL.
ns_ref(ns, v) if v == ns.name

ns_ref(ns, v) if {
	is_string(v)
	contains(v, sprintf("%s.%s.", [ns.res.type, ns.res.name]))
}

# Пространство имён, в котором создан объект.
object_ns(r) := val(metadata(r), "namespace", "default")

# ---------- облака ----------

cidr_open(c) if c in {"0.0.0.0/0", "::/0", "*", "Internet", "any", "Any"}

admin_ports := {22, 3389, 5432, 3306, 1433, 6379, 27017, 9200}

# Попадает ли диапазон портов [from, to] на админ-порты или «все порты».
ports_risky(from, to) if {
	f := to_number(from)
	t := to_number(to)
	some p in admin_ports
	f <= p
	p <= t
}

ports_risky(from, to) if {
	to_number(from) == 0
	to_number(to) == 0
}

ports_risky(from, _) if {
	to_number(from) == -1
}

# ---------- исключения ----------

default exceptions := []

exceptions := data.exceptions

exception_valid(e) if {
	count(trim_space(object.get(e, "reason", ""))) >= 15
	object.get(e, "owner", "") != ""
	expires_ns(e) > time.now_ns()
	expires_ns(e) - time.now_ns() <= ((180 * 24) * 3600) * 1000000000
}

expires_date(e) := substring(sprintf("%v", [object.get(e, "expires", "")]), 0, 10)

expires_ns(e) := time.parse_rfc3339_ns(sprintf("%sT23:59:59Z", [expires_date(e)]))

excepted(f) if {
	some e in exceptions
	e.rule == f.id
	glob.match(e.resource, [], f.address)
	exception_valid(e)
}
