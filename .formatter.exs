# Used by "mix format"
locals_without_parens = [
  field_i18n: 1,
  field_i18n: 2,
  field_i18n: 3
]

[
  import_deps: [:ecto, :ecto_sql],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [locals_without_parens: locals_without_parens]
]
