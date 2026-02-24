defmodule Checkout.CartTest do
  use ExUnit.Case, async: true

  alias Checkout.Cart

  describe "new/0" do
    test "creates an empty cart" do
      cart = Cart.new()
      assert cart.items == []
    end
  end

  describe "add_item/2" do
    test "adds a valid product code to the cart" do
      cart = Cart.new()
      assert {:ok, updated_cart} = Cart.add_item(cart, "GR1")
      assert updated_cart.items == ["GR1"]
    end

    test "adds multiple items in order" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:ok, cart} = Cart.add_item(cart, "SR1")
      {:ok, cart} = Cart.add_item(cart, "CF1")
      assert cart.items == ["GR1", "SR1", "CF1"]
    end

    test "allows duplicate items" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:ok, cart} = Cart.add_item(cart, "GR1")
      assert cart.items == ["GR1", "GR1"]
    end

    test "returns error for unknown product code" do
      cart = Cart.new()
      assert {:error, :not_found} = Cart.add_item(cart, "UNKNOWN")
    end

    test "does not modify cart on error" do
      cart = Cart.new()
      {:ok, cart} = Cart.add_item(cart, "GR1")
      {:error, :not_found} = Cart.add_item(cart, "UNKNOWN")
      assert cart.items == ["GR1"]
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
      # 311 + 311 = 622
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
