defmodule Checkout.ProductTest do
  use ExUnit.Case, async: true

  alias Checkout.Product

  describe "fetch/1" do
    test "returns the product for a known code" do
      assert {:ok, %Product{code: "GR1", name: "Green tea", price: 311}} =
               Product.fetch("GR1")
    end

    test "returns all known products" do
      assert {:ok, %Product{code: "SR1", name: "Strawberries", price: 500}} =
               Product.fetch("SR1")

      assert {:ok, %Product{code: "CF1", name: "Coffee", price: 1123}} =
               Product.fetch("CF1")
    end

    test "returns error for unknown code" do
      assert {:error, :not_found} = Product.fetch("UNKNOWN")
    end

    test "returns error for empty string" do
      assert {:error, :not_found} = Product.fetch("")
    end

    test "is case-sensitive" do
      assert {:error, :not_found} = Product.fetch("gr1")
      assert {:error, :not_found} = Product.fetch("Gr1")
    end
  end

  describe "all/0" do
    test "returns all 3 products" do
      products = Product.all()
      assert length(products) == 3
    end

    test "all products have required fields" do
      for product <- Product.all() do
        assert is_binary(product.code)
        assert is_binary(product.name)
        assert is_integer(product.price)
        assert product.price > 0
      end
    end
  end

end
