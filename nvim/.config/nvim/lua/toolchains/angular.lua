-- Angular (angular toolchain): the Angular language server, alongside
-- typescript's vtsls. It prefers the project's own @angular/language-service.
---@type Toolchain
return {
  servers = { angularls = { executable = "ngserver" } },
}
