defmodule Checkout.PricingRulesTest do
  use ExUnit.Case, async: true

  alias Checkout.{LineItem, PricingRule, PricingRules, Product}

  describe "new/1" do
    test "returns {:ok, struct} for an empty list" do
      assert {:ok, %PricingRules{rules: []}} = PricingRules.new([])
    end

    test "returns {:ok, struct} for a single rule" do
      rules = [{PricingRule.BuyOneGetOneFree, "GR1", []}]
      assert {:ok, %PricingRules{rules: ^rules}} = PricingRules.new(rules)
    end

    test "returns {:ok, struct} for multiple rules targeting different products" do
      rules = [
        {PricingRule.BuyOneGetOneFree, "GR1", []},
        {PricingRule.BuyOneGetOneFree, "SR1", []},
        {PricingRule.BuyOneGetOneFree, "CF1", []}
      ]

      assert {:ok, %PricingRules{rules: ^rules}} = PricingRules.new(rules)
    end

    test "returns error when two rules target the same product code" do
      rules = [
        {PricingRule.BuyOneGetOneFree, "GR1", []},
        {PricingRule.BuyOneGetOneFree, "GR1", []}
      ]

      assert {:error, {:duplicate_product_rule, "GR1"}} = PricingRules.new(rules)
    end

    test "returns error for the first duplicate found" do
      rules = [
        {PricingRule.BuyOneGetOneFree, "GR1", []},
        {PricingRule.BuyOneGetOneFree, "SR1", []},
        {PricingRule.BuyOneGetOneFree, "GR1", []},
        {PricingRule.BuyOneGetOneFree, "SR1", []}
      ]

      # GR1 is the first duplicate encountered
      assert {:error, {:duplicate_product_rule, "GR1"}} = PricingRules.new(rules)
    end

    test "returns error when all rules target the same product" do
      rules = [
        {PricingRule.BuyOneGetOneFree, "GR1", []},
        {PricingRule.BuyOneGetOneFree, "GR1", []},
        {PricingRule.BuyOneGetOneFree, "GR1", []}
      ]

      assert {:error, {:duplicate_product_rule, "GR1"}} = PricingRules.new(rules)
    end
  end

  describe "apply_to/2" do
    setup do
      product = %Product{code: "GR1", name: "Green tea", price: 311}
      line_item = %LineItem{product: product, quantity: 3}
      %{product: product, line_item: line_item}
    end

    test "uses default subtotal when no rules are present", %{line_item: line_item} do
      {:ok, rules} = PricingRules.new([])
      # 3 * 311 = 933
      assert PricingRules.apply_to(rules, line_item) == 933
    end

    test "uses default subtotal when no rule matches the product", %{line_item: line_item} do
      {:ok, rules} = PricingRules.new([{PricingRule.BuyOneGetOneFree, "SR1", []}])
      # No rule for GR1 → default: 3 * 311 = 933
      assert PricingRules.apply_to(rules, line_item) == 933
    end

    test "applies the matching rule when one exists", %{line_item: line_item} do
      {:ok, rules} = PricingRules.new([{PricingRule.BuyOneGetOneFree, "GR1", []}])
      # BOGOF: payable = 3 - div(3, 2) = 2, total = 2 * 311 = 622
      assert PricingRules.apply_to(rules, line_item) == 622
    end

    test "applies the correct rule when multiple rules exist", %{line_item: line_item} do
      {:ok, rules} =
        PricingRules.new([
          {PricingRule.BuyOneGetOneFree, "SR1", []},
          {PricingRule.BuyOneGetOneFree, "GR1", []},
          {PricingRule.BuyOneGetOneFree, "CF1", []}
        ])

      # Only GR1 rule matches → BOGOF: 622
      assert PricingRules.apply_to(rules, line_item) == 622
    end
  end

  describe "find/2" do
    test "returns the matching rule tuple" do
      rule = {PricingRule.BuyOneGetOneFree, "GR1", []}
      {:ok, pricing_rules} = PricingRules.new([rule])
      assert PricingRules.find(pricing_rules.rules, "GR1") == rule
    end

    test "returns nil when no rule matches" do
      {:ok, pricing_rules} = PricingRules.new([{PricingRule.BuyOneGetOneFree, "SR1", []}])
      assert PricingRules.find(pricing_rules.rules, "GR1") == nil
    end

    test "returns nil for an empty rules list" do
      {:ok, pricing_rules} = PricingRules.new([])
      assert PricingRules.find(pricing_rules.rules, "GR1") == nil
    end
  end
end
