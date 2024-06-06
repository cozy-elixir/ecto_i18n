# EctoI18n

> Provides i18n support for Ecto.

## Notes

This package is still in its early stages, so it may still undergo significant changes, potentially leading to breaking changes.

## Installation

Add `:ecto_i18n` to the list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ecto_i18n, <requirement>}
  ]
end
```

## Usage

For more information, see the [documentation](https://hexdocs.pm/ecto_i18n).

## Terminology

Throughout the package, I will use the following terminology to avoid conceptual confusion.

### g11n (globalization)

It is a broader concept that covers the i18n and l10n processes throughout the software development lifecycle.

The goal of g11n is to make products adapted in different languages and cultural environments:

- i18n enables products to be adaptable.
- l10n lets products to be adapted.

### i18n (internationalization)

It refers to the process of designing and developing a product to be adaptable to different languages and cultural environments.

It is the preparation for l10n. When i18n is done, there's no need for further programmatic changes to the product to switch between languages.

At this stage, we are not conducting actual l10n work but rather providing the infrastructure for l10n.

### l10n (localization)

It refers to the process of adapting a product to a specific language or region. It includes:

- translating text.
- adjusting formats, such as date, time, number, currencies, etc.
- ...

At this stage, we focus on the actual l10n work.

## Thanks

This package is built or will be built on the wisdom of:

- [trans](https://github.com/crbelaus/trans) / [cldr_trans](https://github.com/elixir-cldr/cldr_trans)
- [i18n_helpers](https://github.com/mathieuprog/i18n_helpers)
  - [Announcements at ElixirForum](https://elixirforum.com/t/i18n-helpers-ease-the-use-of-embedded-translations-in-ecto-schemas/25617)
- [ecto_translate](https://github.com/smeevil/ecto_translate)

## License

[Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0)
