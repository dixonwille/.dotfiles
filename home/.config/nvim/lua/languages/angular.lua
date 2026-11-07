-- Angular: the Angular language server, alongside typescript's vtsls. It
-- prefers the project's own @angular/language-service.
---@type Language
return {
  servers = { angularls = { executable = "ngserver" } },
}
