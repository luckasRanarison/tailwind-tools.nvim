; inherits: html

(directive_attribute
  (directive_name) @_directive.name
  (#eq? @_directive.name "v-bind")
  (directive_value) @_directive.value
  (#eq? @_directive.value "class")
  (quoted_attribute_value
    (attribute_value) @tailwind._expr)
    (#set! @tailwind._expr "sort" "skip"))
