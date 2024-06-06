defmodule EctoI18n.ChangesetTest do
  use ExUnit.Case
  import EctoI18n.Factory
  alias EctoI18n.Product

  describe "cast_i18n/_" do
    test "works as expected" do
      assert %Ecto.Changeset{valid?: true} =
               %Product{}
               |> Ecto.Changeset.cast(params(:product), [:sku])
               |> EctoI18n.Changeset.cast_i18n(:name)
    end

    test "raises error with the field doesn't have i18n support" do
      assert_raise RuntimeError,
                   "`:unknown` field of `EctoI18n.Product` doesn't have i18n support",
                   fn ->
                     %Product{}
                     |> Ecto.Changeset.cast(params(:product), [:sku])
                     |> EctoI18n.Changeset.cast_i18n(:unknown)
                   end
    end
  end
end
