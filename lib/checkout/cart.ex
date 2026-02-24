defmodule Checkout.Cart do
  @moduledoc """
  Represents a shopping cart containing a list of scanned product codes.

  The cart is a plain struct with pure functional operations — no side effects.
  Items are stored as a list of product codes in the order they were scanned.
  """

  alias Checkout.Product

  @type t :: %__MODULE__{
          items: [String.t()]
        }

  defstruct items: []

  @doc """
  Creates a new empty cart.

  ## Examples

      iex> Checkout.Cart.new()
      %Checkout.Cart{items: []}
  """
  @spec new() :: t()
  def new, do: %__MODULE__{}

  @doc """
  Adds a product code to the cart.

  Returns `{:ok, updated_cart}` if the product exists, or `{:error, :not_found}`
  if the product code is not in the catalog.

  ## Examples

      iex> cart = Checkout.Cart.new()
      iex> {:ok, cart} = Checkout.Cart.add_item(cart, "GR1")
      iex> cart.items
      ["GR1"]

      iex> cart = Checkout.Cart.new()
      iex> Checkout.Cart.add_item(cart, "UNKNOWN")
      {:error, :not_found}
  """
  @spec add_item(t(), String.t()) :: {:ok, t()} | {:error, :not_found}
  def add_item(%__MODULE__{} = cart, code) when is_binary(code) do
    case Product.fetch(code) do
      {:ok, _product} ->
        {:ok, %__MODULE__{cart | items: cart.items ++ [code]}}

      {:error, :not_found} ->
        {:error, :not_found}
    end
  end

  @doc """
  Computes the total price of all items in the cart, in cents.

  Returns `{:ok, total_cents}` where `total_cents` is a non-negative integer.

  ## Examples

      iex> cart = Checkout.Cart.new()
      iex> {:ok, cart} = Checkout.Cart.add_item(cart, "GR1")
      iex> {:ok, cart} = Checkout.Cart.add_item(cart, "SR1")
      iex> Checkout.Cart.total(cart)
      {:ok, 811}
  """
  @spec total(t()) :: {:ok, non_neg_integer()}
  def total(%__MODULE__{items: items}) do
    total_cents =
      Enum.reduce(items, 0, fn code, acc ->
        case Product.fetch(code) do
          {:ok, product} -> acc + product.price
          {:error, :not_found} -> acc
        end
      end)

    {:ok, total_cents}
  end
end
