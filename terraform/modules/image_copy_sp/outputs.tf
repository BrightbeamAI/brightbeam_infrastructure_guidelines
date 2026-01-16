output "image_copy_client_id" {
  description = "Client ID (Application ID) of the image-copy service principal"
  value       = var.create_image_copy_service_principal ? azuread_application.image_copy[0].client_id : ""
  sensitive   = false
}

output "image_copy_client_secret" {
  description = "Client secret for the image-copy service principal"
  value       = var.create_image_copy_service_principal ? azuread_application_password.image_copy[0].value : ""
  sensitive   = true
}

output "image_copy_service_principal_object_id" {
  description = "Object ID of the image-copy service principal"
  value       = var.create_image_copy_service_principal ? azuread_service_principal.image_copy[0].object_id : ""
}
