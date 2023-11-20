output "spinnaker" {
  description = "Attributes of generated spinnaker"
  value = {
    artifact_bucket = module.artifact.bucket.id
    halconfig       = module.spinnaker.halconfig
    irsaconfig      = module.spinnaker.irsaconfig
  }
}
