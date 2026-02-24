defmodule Checkout.Formatter do
  @moduledoc """
  Presentation helpers for monetary values.

  Prices are represented as integer cents internally.
  This module provides functions to convert them to human-readable strings.
  """

  @doc """
  Formats a price in cents to a human-readable string.

  ## Examples

      iex> Checkout.Formatter.format_price(311)
      "£3.11"

      iex> Checkout.Formatter.format_price(500)
      "£5.00"

      iex> Checkout.Formatter.format_price(0)
      "£0.00"

      iex> Checkout.Formatter.format_price(101)
      "£1.01"
  """
  @spec format_price(non_neg_integer()) :: String.t()
  def format_price(cents) when is_integer(cents) and cents >= 0 do
    pounds = div(cents, 100)
    pence = rem(cents, 100)
    "£#{pounds}.#{String.pad_leading(Integer.to_string(pence), 2, "0")}"
  end
end
