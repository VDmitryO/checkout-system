defmodule Checkout.PricingRule.BuyOneGetOneFreeTest do
  use ExUnit.Case, async: true

  alias Checkout.PricingRule.BuyOneGetOneFree
  alias Checkout.{LineItem, Product}

  @gr1 %Product{code: "GR1", name: "Green tea", price: 311}

  describe "apply/2" do
    test "single item — full price" do
      line_item = %LineItem{product: @gr1, quantity: 1}
      assert BuyOneGetOneFree.apply(line_item, []) == 311
    end

    test "two items — pay for one (BOGOF)" do
      line_item = %LineItem{product: @gr1, quantity: 2}
      assert BuyOneGetOneFree.apply(line_item, []) == 311
    end

    test "three items — pay for two" do
      line_item = %LineItem{product: @gr1, quantity: 3}
      assert BuyOneGetOneFree.apply(line_item, []) == 622
    end
  end
end
