# Enable Firestore API
resource "null_resource" "firestore_database_default" {
  triggers = {
    firestore_database_name = data.terraform_remote_state.shared.outputs.firestore_database_name
  }
}
