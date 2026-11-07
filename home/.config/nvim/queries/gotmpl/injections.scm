; extends

; The text around {{ }} in the language the template renders (set by
; lua/gotmpl.lua)
((text) @injection.content
  (#set-gotmpl-lang!)
  (#set! injection.combined))
