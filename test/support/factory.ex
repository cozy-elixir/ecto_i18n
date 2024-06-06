defmodule EctoI18n.Factory do
  @moduledoc false

  alias EctoI18n.Repo

  def params(:product) do
    %{
      sku: "12345-XYZ-789",
      name_i18n: %{
        en: "Isabella body wash",
        "zh-Hans": "伊莎贝拉沐浴露"
      },
      price_i18n: %{
        en: 10,
        "zh-Hans": 8
      }
    }
  end

  def build(:product) do
    %EctoI18n.Product{
      sku: "12345-XYZ-789",
      name_i18n: %EctoI18n.Product.NameI18n{
        en: "Isabella body wash",
        "zh-Hans": "伊莎贝拉沐浴露"
      },
      price_i18n: %{
        en: 10,
        "zh-Hans": 8
      }
    }
  end

  def insert!(:product) do
    build(:product)
    |> Repo.insert!()
  end
end
