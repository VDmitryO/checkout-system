defmodule Checkout.PricingRule.BulkPriceMultiplierTest do
  use ExUnit.Case, async: true

  alias Checkout.PricingRule.BulkPriceMultiplier
  alias Checkout.{LineItem, Product}

  @cf1 %Product{code: "CF1", name: "Coffee", price: 1123}
  @opts [min_qty: 3, multiplier: 2 / 3]

  describe "apply/2" do
    test "below threshold — full price per item (qty 1)" do
      line_item = %LineItem{product: @cf1, quantity: 1}
      assert BulkPriceMultiplier.apply(line_item, @opts) == 1123
    end

    test "still below threshold — two items at full price" do
      line_item = %LineItem{product: @cf1, quantity: 2}
      assert BulkPriceMultiplier.apply(line_item, @opts) == 2246
    end

    test "at threshold — multiplier kicks in for all items" do
      line_item = %LineItem{product: @cf1, quantity: 3}
      # round(3 * 1123 * (2/3)) = round(2246.0) = 2246
      assert BulkPriceMultiplier.apply(line_item, @opts) == 2246
    end

    test "above threshold — multiplier applies to all items" do
      line_item = %LineItem{product: @cf1, quantity: 4}
      # round(4 * 1123 * (2/3)) = round(2994.666...) = 2995
      assert BulkPriceMultiplier.apply(line_item, @opts) == 2995
    end

    test "works with a different multiplier (50% off = 0.5)" do
      line_item = %LineItem{product: @cf1, quantity: 3}
      # round(3 * 1123 * 0.5) = round(1684.5) = 1685
      assert BulkPriceMultiplier.apply(line_item, min_qty: 3, multiplier: 0.5) == 1685
    end
  end
end
