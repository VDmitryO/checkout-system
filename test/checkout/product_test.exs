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

  describe "format_price/1" do
    test "formats 311 as £3.11" do
      assert Product.format_price(311) == "£3.11"
    end

    test "formats 500 as £5.00" do
      assert Product.format_price(500) == "£5.00"
    end

    test "formats 1123 as £11.23" do
      assert Product.format_price(1123) == "£11.23"
    end

    test "formats 0 as £0.00" do
      assert Product.format_price(0) == "£0.00"
    end

    test "formats single-digit pence with leading zero" do
      assert Product.format_price(101) == "£1.01"
      assert Product.format_price(109) == "£1.09"
    end
  end
end
