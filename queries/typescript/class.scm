(call_expression
  function: [
    (identifier) @_ident
    (member_expression
      object: (identifier) @_object.ident)
  ]
  (#any-of? @_ident "clsx" "classnames" "tw" "css" "cva")
  (#eq? @_object.ident "tw")
  arguments: [
    ((arguments
     (_)+) @tailwind.inner._args
     (#set! @tailwind.inner._args "sort" "skip"))
    (template_string) @tailwind.inner._str
  ])
