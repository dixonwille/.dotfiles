-- Go (go1_<minor> toolchains): gopls, which also formats (gofmt).
---@type Toolchain
return {
  servers = { gopls = {} },
}
