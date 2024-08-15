; inherits: tsx

(call_expression
  function: [
    (identifier) @ident
    (member_expression
      object: (identifier) @object.ident)
  ]
  (#any-of? @ident "clsx" "classnames" "tw" "css")
  (#eq? @object.ident "tw")
  arguments: [
    (arguments
      (_)+) @tailwind.inner
    (template_string) @tailwind.inner
  ])
