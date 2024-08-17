; inherits: html

(attribute
  (attribute_name) @_attribute_name
  (#eq? @_attribute_name "class")
  (expression
    (expression_value) @tailwind._expr)
  (#set! @tailwind._expr "sort" "skip"))
