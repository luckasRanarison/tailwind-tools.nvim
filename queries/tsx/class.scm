(jsx_attribute
  (property_identifier) @_attribute_name
  (#any-of? @_attribute_name "class" "className")
  [
   (string
     (string_fragment) @_class_value)
   (jsx_expression
     (template_string
       (string_fragment) @_class_value))
   ])
