defmodule Checkout.PricingRule.BulkPriceMultiplier do
  @moduledoc """
  Bulk price multiplier pricing rule.

  When the quantity of a product reaches or exceeds a minimum threshold,
  the total price is multiplied by a given coefficient (a float between 0.0
  and 1.0 representing the fraction of the original price to charge).

  ## Options

  - `:min_qty`    — minimum quantity to trigger the multiplier (required)
  - `:multiplier` — price coefficient to apply when threshold is met (required);
                    e.g. `2/3` expressed as `0.6667` means "charge two thirds of
                    the original price"

  ## Formula

      effective_total = if quantity >= min_qty,
        do:   round(quantity * unit_price * multiplier),
        else: quantity * unit_price

  The `round/1` call is applied to the group total (not per-item), which
  minimises rounding drift across large quantities.

  ## Examples

  | Quantity | min_qty | unit_price | multiplier | Total |
  |----------|---------|------------|------------|-------|
  | 1        | 3       | 1123       | 0.6667     | 1123  |
  | 2        | 3       | 1123       | 0.6667     | 2246  |
  | 3        | 3       | 1123       | 0.6667     | 2246  |
  | 4        | 3       | 1123       | 0.6667     | 2995  |
  """

  @behaviour Checkout.PricingRule

  @impl true
  @doc """
  Computes the total price in cents for a bulk-price-multiplier line item.

  If the quantity meets or exceeds `:min_qty`, the total is multiplied by
  `:multiplier`; otherwise the regular product price is used.

  ## Examples

      iex> product = %Checkout.Product{code: "CF1", name: "Coffee", price: 1123}
      iex> line_item = %Checkout.LineItem{product: product, quantity: 3}
      iex> Checkout.PricingRule.BulkPriceMultiplier.apply(line_item, min_qty: 3, multiplier: 0.6667)
      2246

      iex> product = %Checkout.Product{code: "CF1", name: "Coffee", price: 1123}
      iex> line_item = %Checkout.LineItem{product: product, quantity: 2}
      iex> Checkout.PricingRule.BulkPriceMultiplier.apply(line_item, min_qty: 3, multiplier: 0.6667)
      2246

  """
  def apply(%Checkout.LineItem{product: product, quantity: quantity}, opts) do
    min_qty = Keyword.fetch!(opts, :min_qty)
    multiplier = Keyword.fetch!(opts, :multiplier)

    if quantity >= min_qty do
      round(quantity * product.price * multiplier)
    else
      quantity * product.price
    end
  end
end
