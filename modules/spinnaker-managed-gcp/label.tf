# frigga naming rule
locals {
  name            = join("-", compact(["spinnaker", "managed", var.desc]))
  credential_json = join("-", [local.name, "credential.json"])
}
