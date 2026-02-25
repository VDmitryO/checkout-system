defmodule Checkout.PricingRule.BulkDiscountTest do
  use ExUnit.Case, async: true

  alias Checkout.PricingRule.BulkDiscount
  alias Checkout.{LineItem, Product}

  @sr1 %Product{code: "SR1", name: "Strawberries", price: 500}
  @opts [min_qty: 3, discount_price: 450]

  describe "apply/2" do
    test "below threshold — full price per item" do
      line_item = %LineItem{product: @sr1, quantity: 1}
      assert BulkDiscount.apply(line_item, @opts) == 500
    end

    test "still below threshold — two items at full price" do
      line_item = %LineItem{product: @sr1, quantity: 2}
      assert BulkDiscount.apply(line_item, @opts) == 1000
    end

    test "at threshold — discount price kicks in" do
      line_item = %LineItem{product: @sr1, quantity: 3}
      assert BulkDiscount.apply(line_item, @opts) == 1350
    end

    test "above threshold — discount price for all items" do
      line_item = %LineItem{product: @sr1, quantity: 4}
      assert BulkDiscount.apply(line_item, @opts) == 1800
    end
  end
end
