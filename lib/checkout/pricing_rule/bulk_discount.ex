defmodule Checkout.PricingRule.BulkDiscount do
  @moduledoc """
  Bulk discount pricing rule.

  When the quantity of a product reaches or exceeds a minimum threshold,
  every item in the line is charged at a reduced price instead of the
  regular unit price.

  ## Options

  - `:min_qty` — minimum quantity to trigger the discount (required)
  - `:discount_price` — price per item in cents when discount applies (required)

  ## Formula

      effective_price = if quantity >= min_qty, do: discount_price, else: unit_price
      total           = quantity * effective_price

  ## Examples

  | Quantity | min_qty | unit_price | discount_price | Total |
  |----------|---------|------------|----------------|-------|
  | 1        | 3       | 500        | 450            | 500   |
  | 2        | 3       | 500        | 450            | 1000  |
  | 3        | 3       | 500        | 450            | 1350  |
  | 4        | 3       | 500        | 450            | 1800  |
  """

  @behaviour Checkout.PricingRule

  @impl true
  @doc """
  Computes the total price in cents for a bulk-discount line item.

  If the quantity meets or exceeds `:min_qty`, every item is charged at
  `:discount_price`; otherwise the regular product price is used.

  ## Examples

      iex> product = %Checkout.Product{code: "SR1", name: "Strawberries", price: 500}
      iex> line_item = %Checkout.LineItem{product: product, quantity: 3}
      iex> Checkout.PricingRule.BulkDiscount.apply(line_item, min_qty: 3, discount_price: 450)
      1350

      iex> product = %Checkout.Product{code: "SR1", name: "Strawberries", price: 500}
      iex> line_item = %Checkout.LineItem{product: product, quantity: 2}
      iex> Checkout.PricingRule.BulkDiscount.apply(line_item, min_qty: 3, discount_price: 450)
      1000

  """
  def apply(%Checkout.LineItem{product: product, quantity: quantity}, opts) do
    min_qty = Keyword.fetch!(opts, :min_qty)
    discount_price = Keyword.fetch!(opts, :discount_price)

    effective_price = if quantity >= min_qty, do: discount_price, else: product.price
    quantity * effective_price
  end
end
