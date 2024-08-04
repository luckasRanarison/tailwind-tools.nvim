((postcss_statement
   (at_keyword) @_keyword
   (#eq? @_keyword "@apply")
   (plain_value)+) @tailwind.inner ; the actual class range is extracted in the code
 (#set! @tailwind.inner "start" 1))
