defmodule EctoI18n.Factory do
  @moduledoc false

  alias EctoI18n.Repo

  def params(:product) do
    %{
      sku: "12345-XYZ-789",
      name: "Isabella body wash",
      locales: %{
        "zh-Hans": %{
          name: "伊莎贝拉沐浴露"
        },
        "zh-Hant": %{
          name: "伊莎貝拉沐浴露"
        }
      }
    }
  end

  def build(:product) do
    %EctoI18n.Product{
      sku: "12345-XYZ-789",
      name: "Isabella body wash",
      locales: %EctoI18n.Product.Locales{
        "zh-Hans": %EctoI18n.Product.Locales.Fields{
          name: "伊莎贝拉沐浴露"
        },
        "zh-Hant": %EctoI18n.Product.Locales.Fields{
          name: "伊莎貝拉沐浴露"
        }
      }
    }
  end

  def insert!(:product) do
    build(:product)
    |> Repo.insert!()
  end
end
