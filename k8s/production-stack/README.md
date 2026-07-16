# vLLM production-stack on CPU — guide

This runs the [vLLM production-stack](https://github.com/vllm-project/production-stack)
on our **CPU-only** GKE cluster to serve `Qwen/Qwen2.5-1.5B-Instruct`, and points the
anime-recommender app at it.

---

## 1. What the production-stack actually is

It's a Helm chart that deploys **three** things:

```
                 ┌──────────────────────────────────────────┐
  client ─────▶  │  ROUTER  (Deployment + Service, :80)      │
  (our app)      │  - one OpenAI-compatible endpoint         │
                 │  - load-balances across engine replicas   │
                 │  - KV-cache / session aware routing        │
                 └───────────────────┬──────────────────────┘
                                     │ discovers engine pods by label (pod-ip)
                                     ▼
                 ┌──────────────────────────────────────────┐
  ENGINE SERVICE │  SERVING ENGINE (Deployment + Service)    │
                 │  - vLLM pods (:8000), one per replicaCount │
                 │  - actually run the model, expose /v1      │
                 └──────────────────────────────────────────┘
     OBSERVABILITY (optional): Prometheus scrapes engine metrics → Grafana
```

**Request flow:** `app → router Service (:80) → router pod → picks an engine pod → vLLM → response`.

**Why the router (not just talk to vLLM directly)?** With more than one replica it
does **KV-cache-aware routing** — sending the same prompt prefix / session to the
same engine pod so the cache is reused (big latency win). With our single CPU
replica it's just a clean, stable OpenAI endpoint — but you learn the real
architecture and can scale replicas later without changing the app.

**Kubernetes objects it creates:** a Deployment + Service for the router, a
Deployment + Service (+ optional PVC) for each `modelSpec`, and ConfigMaps.

---

## 2. What we changed for CPU (and why)

The upstream chart assumes NVIDIA GPUs. [`values-cpu.yaml`](values-cpu.yaml) flips
every GPU assumption. Each change is marked `[CPU]` in the file:

| Change | Why |
|--------|-----|
| `repository: vllm/vllm-openai-cpu` | the default image is CUDA-only; this is the CPU build |
| `requestGPU: 0` | we have no GPUs to request |
| `runtimeClassName: ""` | default `"nvidia"` needs a GPU runtime class our nodes don't have |
| `requestMemory: 14Gi` / `limitMemory: 26Gi` | 3B on CPU needs weights (~6GB) + KV cache + overhead |
| `VLLM_CPU_KVCACHE_SPACE=4` | CPU backend's KV-cache pool size (GiB) |
| `--enforce-eager` | skips CUDA graphs, lowers memory and speeds CPU startup |
| `tolerations` + `nodeSelectorTerms` | pins the engine to our tainted/labeled **serve pool** (`e2-highmem-4`) |

> ⚠️ CPU inference of a 3B model is **slow** (a few tokens/sec) and CPU serving is
> an unsupported path for this stack. It's great for learning/demo, not throughput.

---

## 3. Prerequisites

```bash
# cluster is up (terraform applied); get credentials
gcloud container clusters get-credentials anime-rec-cluster --zone us-central1-c --project <PROJECT_ID>

# tools
helm version && kubectl version --client
```

---

## 4. Deploy

```bash
# 1. add the chart repo
helm repo add vllm https://vllm-project.github.io/production-stack
helm repo update

# 2. install the stack with our CPU values (into the default namespace)
helm install vllm vllm/vllm-stack -f k8s/production-stack/values-cpu.yaml

# 3. watch it come up — the serve pool scales 0->1, then the model downloads (slow)
kubectl get pods -w
```

You'll see the GKE **cluster autoscaler add the serve node** (0→1), then the engine
pod pulls the image + downloads the model. First start takes several minutes.

Check the router is serving:

```bash
kubectl get svc | grep router          # e.g. vllm-router-service  ClusterIP  ...  80/TCP
kubectl port-forward svc/vllm-router-service 8000:80 &
curl http://localhost:8000/v1/models   # OpenAI-compatible; lists qwen15b
```

---

## 5. Point the app at the router

The app already speaks the OpenAI API (`src/llm_provider.py`). In the production
stack, the app talks to the **router**, not the engine directly. Set:

```
LLM_PROVIDER=vllm
VLLM_BASE_URL=http://vllm-router-service.default.svc.cluster.local:80/v1
VLLM_MODEL_NAME=Qwen/Qwen2.5-1.5B-Instruct
```

(That's the same env the app reads in `config/config.py` — only the URL/model change
to the router service + the served model.)

---

## 6. Observability (choose one)

The stack ships an optional Prometheus + Grafana. On the free tier that stack is
heavy (it's what caused the earlier `Insufficient cpu`). Two options:

- **Bundled:** follow the repo's observability install. The app pool autoscales
  1→2 to fit it (peak ≈ 8 vCPU = free-tier quota).
- **Recommended for free tier:** skip the bundled stack and enable **GKE Managed
  Prometheus** (offloads scraping to Google, ~no node CPU cost). vLLM exposes
  `/metrics` on the engine pods either way.

---

## 7. Cost / lifecycle

- Engine runs on the **serve pool (scales 0→1)**. `helm uninstall vllm` (or scale
  the engine Deployment to 0) drains the `e2-highmem-4` node → billing stops.
- Router is tiny and lives on the always-on app pool.
- Tear the whole cluster down between sessions with **Infra Destroy** to stay well
  within the $300 credit.

```bash
helm uninstall vllm     # remove the stack (keeps the cluster)
```

---

## 8. Mental model recap

- **You deploy a Helm release**, not raw pods → repeatable, declarative.
- **Router = the API**, **engine = the model**, **replicas scale the model**.
- **The app never changes** when you scale from 1 CPU replica to many GPU replicas —
  that decoupling is the whole point of the production-stack.
