import os

extensions = [
    "proto", "graphql", "gql", "http", "rest", "openapi.yaml", "raml", "avsc", "thrift", "wsdl",
    "k8s.yaml", "helm.yaml", "tf", "tfvars", "hcl", "nomad", "pulumi.ts", "env", "env.example",
    "toml", "ini", "cfg", "conf", "jsonnet", "cue", "properties", "rc", "sql", "psql", "dbml",
    "migration.sql", "prisma", "cql", "neo4j", "cypher", "influxql", "mongo", "ipynb", "onnx",
    "pt", "h5", "pkl", "joblib", "tflite", "faiss", "embeddings", "model", "csv", "parquet",
    "feather", "orc", "tsv", "arrow", "jsonl", "ndjson", "xls", "xlsx", "tsx", "jsx", "scss",
    "sass", "less", "webmanifest", "htmx", "wasm", "svg", "ejs", "sh", "bash", "zsh", "ps1",
    "bat", "makefile", "justfile", "taskfile.yml", "cron", "workflow", "md", "mdx", "rst", "adoc",
    "drawio", "pem", "crt", "key", "csr", "jwt", "rs", "go", "kt", "swift"
]

directories = ["api", "infra", "ci", "config", "db", "ai", "data", "frontend", "automation", "docs", "security"]

for idx, ext in enumerate(extensions):
    d = directories[idx % len(directories)]
    os.makedirs(d, exist_ok=True)
    file_path = os.path.join(d, f"dummy_complex_file_{idx}.{ext}")
    with open(file_path, "w") as f:
        f.write("# Dummy advanced config file for ACOS ecosystem payload.\n")

print("Bombarded directory with advanced files!")
