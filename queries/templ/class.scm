; inherits: html

(attribute
  name: (attribute_name) @_attribute
  (#eq? @_attribute "class")
  value: (expression
    (_) @tailwind._expr)
    (#set! @tailwind._expr "sort" "skip"))
