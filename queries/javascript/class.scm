(call_expression
  function: [
    (identifier) @ident (#any-of? @ident "clsx" "classnames" "tw" "css")
    (member_expression
      object: (identifier) @object-ident (#eq? @object-ident "tw"))
  ]
  arguments: [
    (arguments
      (_)+) @tailwind ; the actual class range is extracted in the code
    (template_string
      (string_fragment) @tailwind)
  ])
