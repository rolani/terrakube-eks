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


# API TOKEN
# eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJUZXJyYWt1YmUiLCJzdWIiOiJBZG1pbiAoVG9rZW4pIiwiYXVkIjoiVGVycmFrdWJlIiwianRpIjoiYjQ5NWZmMWQtYTBlNS00YmVjLThkNDEtY2E4ZGM1MGU0ZjNiIiwiZW1haWwiOiJhZG1pbkBleGFtcGxlLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJuYW1lIjoiQWRtaW4gKFRva2VuKSIsImdyb3VwcyI6WyJURVJSQUtVQkVfQURNSU4iLCJURVJSQUtVQkVfREVWRUxPUEVSUyJdLCJpYXQiOjE3Mzg0NTU3NTAsImV4cCI6MTczOTMxOTc1MH0.La38at21iHh5k1lQQCvWCIM8DhfE6HakuNQskM5TLb0
