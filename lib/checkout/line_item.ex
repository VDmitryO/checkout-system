defmodule Checkout.LineItem do
  @moduledoc """
  Groups a `Checkout.Product` with the quantity scanned.

  A `LineItem` is the unit on which pricing rules operate: each rule receives
  a `LineItem` and returns the total price in cents for that line.
  """

  @type t :: %__MODULE__{
          product: Checkout.Product.t(),
          quantity: pos_integer()
        }

  defstruct [:product, :quantity]

  @doc """
  Computes the default subtotal (no pricing rule applied): `quantity * unit_price`.

  ## Examples

      iex> product = %Checkout.Product{code: "GR1", name: "Green tea", price: 311}
      iex> Checkout.LineItem.subtotal(%Checkout.LineItem{product: product, quantity: 3})
      933

  """
  @spec subtotal(t()) :: non_neg_integer()
  def subtotal(%__MODULE__{product: product, quantity: quantity}) do
    quantity * product.price
  end
end
