# defmodule EctoI18n.TypeTest do
#   use EctoI18n.DataCase

#   defmodule Product do
#     @moduledoc false

#     use Ecto.Schema

#     schema "products" do
#       field :name, :string
#       # field :name_i18n, EctoI18n.Type, inner_type: :string, locales: ["en", "zh-Hans"]
#       # field :name_i18n, EctoI18n.Type,
#       #   inner_type: {:parameterized, Ecto.Enum, values: [:good, :bad]},
#       #   locales: ["en", "zh-Hans"]
#       field :name_i18n, EctoI18n.Type,
#         inner_type: :integer,
#         locales: ["en", "zh-Hans"]

#       field :state, Ecto.Enum, values: [:good, :bad]
#     end
#   end

#   test "x" do
#     %Product{}
#     |> Ecto.Changeset.cast(
#       %{state: "good", name_i18n: %{"en" => "good", "zh-Hans" => "1"}},
#       [:state, :name_i18n]
#     )
#     |> Repo.insert()
#     |> IO.inspect()

#     Repo.all(Product)
#     |> IO.inspect()
#   end
# end
