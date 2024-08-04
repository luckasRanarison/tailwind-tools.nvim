; inherits: tsx

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
