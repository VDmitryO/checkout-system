defmodule Checkout.Cart do
  @moduledoc """
  Represents a shopping cart containing a map of `Checkout.LineItem` structs
  keyed by product code, and a `Checkout.PricingRules` collection.

  Each `LineItem` groups a product with the quantity scanned so far.
  The cart is a plain struct with pure functional operations — no side effects.
  """

  alias Checkout.{LineItem, PricingRules, Product}

  @type t :: %__MODULE__{
          items: %{String.t() => LineItem.t()},
          pricing_rules: PricingRules.t()
        }

  defstruct items: %{}, pricing_rules: %PricingRules{}

  @doc """
  Creates a new empty cart with no pricing rules.
  """
  @spec new() :: t()
  def new, do: %__MODULE__{}

  @doc """
  Creates a new empty cart with the given `PricingRules` struct.
  """
  @spec new(PricingRules.t()) :: t()
  def new(%PricingRules{} = pricing_rules), do: %__MODULE__{pricing_rules: pricing_rules}

  @doc """
  Adds a product to the cart by its code.

  If a `LineItem` for that product already exists, its quantity is incremented.
  Otherwise a new `LineItem` with `quantity: 1` is inserted.

  Returns `{:ok, updated_cart}` if the product exists, or `{:error, :not_found}`
  if the product code is not in the catalog.

  ## Examples

      iex> cart = Checkout.Cart.new()
      iex> {:ok, cart} = Checkout.Cart.add_item(cart, "GR1")
      iex> map_size(cart.items)
      1
      iex> cart.items["GR1"].quantity
      1

      iex> cart = Checkout.Cart.new()
      iex> {:ok, cart} = Checkout.Cart.add_item(cart, "GR1")
      iex> {:ok, cart} = Checkout.Cart.add_item(cart, "GR1")
      iex> cart.items["GR1"].quantity
      2

      iex> cart = Checkout.Cart.new()
      iex> Checkout.Cart.add_item(cart, "UNKNOWN")
      {:error, :not_found}
  """
  @spec add_item(t(), String.t()) :: {:ok, t()} | {:error, :not_found}
  def add_item(%__MODULE__{} = cart, code) when is_binary(code) do
    with {:ok, product} <- Product.fetch(code) do
      updated_items =
        Map.update(cart.items, code, %LineItem{product: product, quantity: 1}, fn item ->
          %LineItem{item | quantity: item.quantity + 1}
        end)

      {:ok, %__MODULE__{cart | items: updated_items}}
    end
  end

  @doc """
  Computes the total price of all items in the cart, in cents.

  For each line item, the matching pricing rule (if any) is applied via
  `Checkout.PricingRules.apply_to/2`. If no rule matches, the default subtotal
  (`quantity * unit_price`) is used.

  Returns `{:ok, total_cents}` where `total_cents` is a non-negative integer.

  ## Examples

      iex> cart = Checkout.Cart.new()
      iex> {:ok, cart} = Checkout.Cart.add_item(cart, "GR1")
      iex> {:ok, cart} = Checkout.Cart.add_item(cart, "SR1")
      iex> Checkout.Cart.total(cart)
      {:ok, 811}
  """
  @spec total(t()) :: {:ok, non_neg_integer()}
  def total(%__MODULE__{items: items, pricing_rules: pricing_rules}) do
    total_cents =
      items
      |> Map.values()
      |> Enum.sum_by(&PricingRules.apply_to(pricing_rules, &1))

    {:ok, total_cents}
  end
end
