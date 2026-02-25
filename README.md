# Checkout

A checkout system with configurable pricing rules. Supports buy-one-get-one-free, bulk discounts, and bulk price multipliers.

## Products

| Code | Name         | Price  |
|------|--------------|--------|
| GR1  | Green tea    | £3.11  |
| SR1  | Strawberries | £5.00  |
| CF1  | Coffee       | £11.23 |

## Usage

```elixir
# Define pricing rules
{:ok, rules} =
  Checkout.PricingRules.new([
    {Checkout.PricingRule.BuyOneGetOneFree, "GR1", []},
    {Checkout.PricingRule.BulkDiscount, "SR1", [min_qty: 3, discount_price: 450]},
    {Checkout.PricingRule.BulkPriceMultiplier, "CF1", [min_qty: 3, multiplier: 2 / 3]}
  ])

# Create checkout, scan items, get total
co =
  Checkout.new(rules)
  |> Checkout.scan("GR1")
  |> Checkout.scan("SR1")
  |> Checkout.scan("GR1")
  |> Checkout.scan("GR1")
  |> Checkout.scan("CF1")

{:ok, total} = Checkout.total(co)
Checkout.format_total(total)
# => "£22.45"
```

## Running Tests

```bash
mix test
```
