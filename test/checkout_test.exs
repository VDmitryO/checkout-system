defmodule CheckoutTest do
  use ExUnit.Case, async: true

  doctest Checkout

  alias Checkout.PricingRules

  describe "new/0" do
    test "creates a new empty checkout" do
      co = Checkout.new()
      assert co.items == []
      assert co.pricing_rules == %PricingRules{rules: []}
    end
  end

  describe "new/1" do
    test "creates a checkout with the given pricing rules" do
      rule_tuples = [{PricingRule.BuyOneGetOneFree, "GR1", []}]
      {:ok, rules} = PricingRules.new(rule_tuples)
      co = Checkout.new(rules)
      assert co.items == []
      assert co.pricing_rules == %PricingRules{rules: rule_tuples}
    end

    test "creates a checkout with an empty pricing rules struct" do
      {:ok, rules} = PricingRules.new([])
      co = Checkout.new(rules)
      assert co.items == []
      assert co.pricing_rules == %PricingRules{rules: []}
    end
  end

  describe "scan/2" do
    test "scans a valid product and returns updated cart" do
      co = Checkout.new()
      co = Checkout.scan(co, "GR1")
      assert length(co.items) == 1
      assert hd(co.items).product.code == "GR1"
      assert hd(co.items).quantity == 1
    end

    test "scans multiple products in order" do
      co =
        Checkout.new()
        |> Checkout.scan("GR1")
        |> Checkout.scan("SR1")
        |> Checkout.scan("CF1")

      assert length(co.items) == 3
      assert Enum.map(co.items, & &1.product.code) == ["GR1", "SR1", "CF1"]
    end

    test "allows scanning the same product multiple times" do
      co =
        Checkout.new()
        |> Checkout.scan("GR1")
        |> Checkout.scan("GR1")

      assert length(co.items) == 1
      assert hd(co.items).quantity == 2
    end

    test "raises ArgumentError for unknown product code" do
      co = Checkout.new()

      assert_raise ArgumentError, ~r/unknown product code/, fn ->
        Checkout.scan(co, "UNKNOWN")
      end
    end
  end

  describe "total/1" do
    test "returns 0 for an empty cart" do
      co = Checkout.new()
      assert {:ok, 0} = Checkout.total(co)
    end

    test "returns correct total for a single item" do
      co = Checkout.new() |> Checkout.scan("GR1")
      assert {:ok, 311} = Checkout.total(co)
    end

    test "returns correct total for multiple items" do
      co =
        Checkout.new()
        |> Checkout.scan("GR1")
        |> Checkout.scan("SR1")

      # 311 + 500 = 811
      assert {:ok, 811} = Checkout.total(co)
    end

    test "returns correct total for all three products" do
      co =
        Checkout.new()
        |> Checkout.scan("GR1")
        |> Checkout.scan("SR1")
        |> Checkout.scan("CF1")

      # 311 + 500 + 1123 = 1934
      assert {:ok, 1934} = Checkout.total(co)
    end

    test "returns correct total for duplicate items" do
      co =
        Checkout.new()
        |> Checkout.scan("GR1")
        |> Checkout.scan("GR1")
        |> Checkout.scan("GR1")

      # 311 * 3 = 933
      assert {:ok, 933} = Checkout.total(co)
    end
  end

  describe "format_total/1" do
    test "formats 0 as £0.00" do
      assert Checkout.format_total(0) == "£0.00"
    end

    test "formats 811 as £8.11" do
      assert Checkout.format_total(811) == "£8.11"
    end

    test "formats 1934 as £19.34" do
      assert Checkout.format_total(1934) == "£19.34"
    end
  end

  describe "end-to-end scenarios" do
    test "basket: GR1, SR1, GR1, GR1, CF1" do
      co =
        Checkout.new()
        |> Checkout.scan("GR1")
        |> Checkout.scan("SR1")
        |> Checkout.scan("GR1")
        |> Checkout.scan("GR1")
        |> Checkout.scan("CF1")

      # 311 + 500 + 311 + 311 + 1123 = 2556
      assert {:ok, 2556} = Checkout.total(co)
      assert Checkout.format_total(2556) == "£25.56"
    end

    test "basket: GR1, GR1" do
      co =
        Checkout.new()
        |> Checkout.scan("GR1")
        |> Checkout.scan("GR1")

      # 311 + 311 = 622
      assert {:ok, 622} = Checkout.total(co)
      assert Checkout.format_total(622) == "£6.22"
    end

    test "basket: SR1, SR1, GR1, SR1" do
      co =
        Checkout.new()
        |> Checkout.scan("SR1")
        |> Checkout.scan("SR1")
        |> Checkout.scan("GR1")
        |> Checkout.scan("SR1")

      # 500 + 500 + 311 + 500 = 1811
      assert {:ok, 1811} = Checkout.total(co)
      assert Checkout.format_total(1811) == "£18.11"
    end

    test "basket: GR1, CF1, SR1, CF1, CF1" do
      co =
        Checkout.new()
        |> Checkout.scan("GR1")
        |> Checkout.scan("CF1")
        |> Checkout.scan("SR1")
        |> Checkout.scan("CF1")
        |> Checkout.scan("CF1")

      # 311 + 1123 + 500 + 1123 + 1123 = 4180
      assert {:ok, 4180} = Checkout.total(co)
      assert Checkout.format_total(4180) == "£41.80"
    end
  end
end
