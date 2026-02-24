defmodule Checkout do
  @moduledoc """
  A cashier service for managing a shopping cart and computing the final total.

  ## Usage

      iex> co = Checkout.new()
      iex> co = Checkout.scan(co, "GR1")
      iex> co = Checkout.scan(co, "SR1")
      iex> co = Checkout.scan(co, "GR1")
      iex> {:ok, total} = Checkout.total(co)
      iex> Checkout.format_total(total)
      "£11.22"

  ## Products

  The following products are available:

  | Code | Name         | Price  |
  |------|--------------|--------|
  | GR1  | Green tea    | £3.11  |
  | SR1  | Strawberries | £5.00  |
  | CF1  | Coffee       | £11.23 |

  ## Money representation

  All prices and totals are represented as integer cents internally.
  Use `format_total/1` to convert to a human-readable string.
  """

  alias Checkout.Cart
  alias Checkout.Formatter

  @type t :: Cart.t()

  @doc """
  Creates a new empty checkout (cart).

  ## Examples

      iex> co = Checkout.new()
      iex> co.items
      []
  """
  @spec new() :: t()
  def new, do: Cart.new()

  @doc """
  Scans a product by its code and adds it to the cart.

  Returns the updated cart on success, or raises `ArgumentError` if the
  product code is not found in the catalog.

  ## Examples

      iex> co = Checkout.new()
      iex> co = Checkout.scan(co, "GR1")
      iex> length(co.items)
      1

      iex> co = Checkout.new()
      iex> Checkout.scan(co, "UNKNOWN")
      ** (ArgumentError) unknown product code: "UNKNOWN"
  """
  @spec scan(t(), String.t()) :: t()
  def scan(%Cart{} = cart, code) when is_binary(code) do
    case Cart.add_item(cart, code) do
      {:ok, updated_cart} ->
        updated_cart

      {:error, :not_found} ->
        raise ArgumentError, "unknown product code: #{inspect(code)}"
    end
  end

  @doc """
  Computes the total price of all scanned items, in cents.

  ## Examples

      iex> co = Checkout.new()
      iex> co = Checkout.scan(co, "GR1")
      iex> co = Checkout.scan(co, "SR1")
      iex> Checkout.total(co)
      {:ok, 811}
  """
  @spec total(t()) :: {:ok, non_neg_integer()}
  def total(%Cart{} = cart), do: Cart.total(cart)

  @doc """
  Formats a total in cents to a human-readable string.

  ## Examples

      iex> Checkout.format_total(811)
      "£8.11"

      iex> Checkout.format_total(0)
      "£0.00"
  """
  @spec format_total(non_neg_integer()) :: String.t()
  def format_total(cents) when is_integer(cents) and cents >= 0 do
    Formatter.format_price(cents)
  end
end
