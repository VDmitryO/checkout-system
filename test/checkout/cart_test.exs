defmodule Checkout.CartTest do
  use ExUnit.Case, async: true

  alias Checkout.{Cart, LineItem, Product}

  describe "new/0" do
    test "creates an empty cart" do
      cart = Cart.new()
      assert cart.items == []
    end
  end

  describe "add_item/2" do
    test "adds a valid product as a new LineItem with quantity 1" do
      cart = Cart.new()
      assert {:ok, updated_cart} = Cart.add_item(cart, "GR1")
      assert [%LineItem{product: %Product{code: "GR1"}, quantity: 1}] = updated_cart.items
    end

    test "adds multiple different products as separate LineItems" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:ok, cart} = Cart.add_item(cart, "SR1")
      {:ok, cart} = Cart.add_item(cart, "CF1")
      assert length(cart.items) == 3
      codes = Enum.map(cart.items, & &1.product.code)
      assert codes == ["GR1", "SR1", "CF1"]
    end

    test "increments quantity when the same product is added twice" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:ok, cart} = Cart.add_item(cart, "GR1")
      assert length(cart.items) == 1
      assert hd(cart.items).quantity == 2
    end

    test "increments quantity correctly for multiple duplicates" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:ok, cart} = Cart.add_item(cart, "GR1")
      assert hd(cart.items).quantity == 3
    end

    test "keeps separate LineItems for different products even with duplicates" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:ok, cart} = Cart.add_item(cart, "SR1")
      {:ok, cart} = Cart.add_item(cart, "GR1")
      assert length(cart.items) == 2
      gr1 = Enum.find(cart.items, &(&1.product.code == "GR1"))
      sr1 = Enum.find(cart.items, &(&1.product.code == "SR1"))
      assert gr1.quantity == 2
      assert sr1.quantity == 1
    end

    test "returns error for unknown product code" do
      cart = Cart.new()
      assert {:error, :not_found} = Cart.add_item(cart, "UNKNOWN")
    end

    test "does not modify cart on error" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:error, :not_found} = Cart.add_item(cart, "UNKNOWN")
      assert length(cart.items) == 1
      assert hd(cart.items).product.code == "GR1"
    end
  end

  describe "total/1" do
    test "returns 0 for an empty cart" do
      cart = Cart.new()
      assert {:ok, 0} = Cart.total(cart)
    end

    test "returns the price of a single item" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      assert {:ok, 311} = Cart.total(cart)
    end

    test "sums prices of multiple different items" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:ok, cart} = Cart.add_item(cart, "SR1")
      # 311 + 500 = 811
      assert {:ok, 811} = Cart.total(cart)
    end

    test "sums prices of duplicate items" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:ok, cart} = Cart.add_item(cart, "GR1")
      # 311 * 2 = 622
      assert {:ok, 622} = Cart.total(cart)
    end

    test "sums all three products" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:ok, cart} = Cart.add_item(cart, "SR1")
      {:ok, cart} = Cart.add_item(cart, "CF1")
      # 311 + 500 + 1123 = 1934
      assert {:ok, 1934} = Cart.total(cart)
    end
  end
end
