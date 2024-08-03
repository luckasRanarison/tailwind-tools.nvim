; inherits: html

(directive_attribute
  (directive_name) @directive.name
  (#eq? @directive.name "v-bind")
  (directive_value) @directive.value
  (#eq? @directive.value "class")
  (quoted_attribute_value
    (attribute_value) @tailwind))
