defmodule Checkout.LineItemTest do
  use ExUnit.Case, async: true

  alias Checkout.LineItem
  alias Checkout.Product

  @green_tea %Product{code: "GR1", name: "Green tea", price: 311}
  @strawberries %Product{code: "SR1", name: "Strawberries", price: 500}
  @coffee %Product{code: "CF1", name: "Coffee", price: 1123}

  describe "subtotal/1" do
    test "returns unit price for quantity of 1" do
      line_item = %LineItem{product: @green_tea, quantity: 1}
      assert LineItem.subtotal(line_item) == 311
    end

    test "multiplies unit price by quantity" do
      line_item = %LineItem{product: @green_tea, quantity: 3}
      assert LineItem.subtotal(line_item) == 933
    end

    test "works for strawberries" do
      line_item = %LineItem{product: @strawberries, quantity: 2}
      assert LineItem.subtotal(line_item) == 1000
    end

    test "works for coffee" do
      line_item = %LineItem{product: @coffee, quantity: 3}
      assert LineItem.subtotal(line_item) == 3369
    end
  end
end
