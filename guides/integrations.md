# Integrations

## Phoenix LiveView

### Form

Take `EctoI18n.Product` schema located at `test/support/schemas.ex` as an example. If you want to create a form for it, try something like:

```heex
<.input field={@form[:sku]} type="text" label="SKU" />
<.inputs_for :let={name} field={@form[:name_i18n]}>
  <%= for locale <- EctoI18n.locales(@form.data) do %>
    <.input field={name[locale]} type="text" label={"Name(#{locale})"} />
  <% end %>
</.inputs_for>
<.inputs_for :let={price} field={@form[:price_i18n]}>
  <%= for locale <- EctoI18n.locales(@form.data) do %>
    <.input field={price[locale]} type="number" label={"Price(#{locale})"} />
  <% end %>
</.inputs_for>
```
