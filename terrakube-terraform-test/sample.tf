terraform {
  cloud {
    organization = "sandbox"
    hostname = "terrakube-api.richolaniyan.com"

    workspaces {
      tags = ["myplayground", "example"]
    }
  }
}

# This resource will destroy (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait_5_seconds" {
  depends_on = [null_resource.previous]

  create_duration = "5s"
}

# This resource will create (at least) 30 seconds after null_resource.previous
resource "null_resource" "next" {
  depends_on = [time_sleep.wait_5_seconds]
}
