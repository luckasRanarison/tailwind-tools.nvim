(call_expression
  function: [
    (identifier) @ident
    (member_expression
      object: (identifier) @object-ident)
  ]
  (#any-of? @ident "clsx" "classnames" "tw" "css")
  (#eq? @object-ident "tw")
  arguments: [
    (arguments
      (_)+) @tailwind ; the actual class range is extracted in the code
    (template_string
      (string_fragment) @tailwind)
  ])

(jsx_attribute
  (property_identifier) @_attribute_name
  (#any-of? @_attribute_name "class" "className" "style" "css" "tw")
  [
    (string
      (string_fragment) @tailwind)
    (jsx_expression
      (_) @tailwind)
  ])
