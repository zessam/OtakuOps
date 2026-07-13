package main

import rego.v1

# Policy-as-code for the model bucket. Evaluated by conftest against the
# Terraform HCL source (conftest --parser hcl2), BEFORE plan.

# Buckets must block all public access.
deny contains msg if {
	some name
	bucket := input.resource.google_storage_bucket[name][_]
	bucket.public_access_prevention != "enforced"
	msg := sprintf("google_storage_bucket.%s: must set public_access_prevention = \"enforced\"", [name])
}

# Buckets must use uniform bucket-level access (no legacy ACLs).
deny contains msg if {
	some name
	bucket := input.resource.google_storage_bucket[name][_]
	bucket.uniform_bucket_level_access != true
	msg := sprintf("google_storage_bucket.%s: must enable uniform_bucket_level_access", [name])
}
