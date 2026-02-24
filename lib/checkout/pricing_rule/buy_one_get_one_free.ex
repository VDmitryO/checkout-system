defmodule Checkout.PricingRule.BuyOneGetOneFree do
  @moduledoc """
  Buy-one-get-one-free pricing rule.

  For every pair of items, the customer pays for only one.
  Odd items are charged at full price.

  ## Formula

      payable = quantity - div(quantity, 2)
      total   = payable * unit_price

  ## Examples

  | Quantity | Payable | Explanation           |
  |----------|---------|-----------------------|
  | 1        | 1       | No free item          |
  | 2        | 1       | Second one free       |
  | 3        | 2       | One pair + one extra  |
  | 4        | 2       | Two pairs             |
  | 5        | 3       | Two pairs + one extra |
  """

  @behaviour Checkout.PricingRule

  @impl true
  @doc """
  Computes the total price in cents for a BOGOF line item.

  Every second item is free. The `opts` argument is ignored — this rule
  requires no configuration.

  ## Examples

      iex> product = %Checkout.Product{code: "GR1", name: "Green tea", price: 311}
      iex> line_item = %Checkout.LineItem{product: product, quantity: 2}
      iex> Checkout.PricingRule.BuyOneGetOneFree.apply(line_item, [])
      311

      iex> product = %Checkout.Product{code: "GR1", name: "Green tea", price: 311}
      iex> line_item = %Checkout.LineItem{product: product, quantity: 3}
      iex> Checkout.PricingRule.BuyOneGetOneFree.apply(line_item, [])
      622

  """
  def apply(%Checkout.LineItem{product: product, quantity: quantity}, _opts) do
    payable = quantity - div(quantity, 2)
    payable * product.price
  end
end
