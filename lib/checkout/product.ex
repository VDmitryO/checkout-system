defmodule Checkout.Product do
  @moduledoc """
  Represents a product in the catalog.

  Prices are stored as integer cents to avoid floating-point rounding errors.
  For example, £3.11 is stored as `311`.
  """

  @type t :: %__MODULE__{
          code: String.t(),
          name: String.t(),
          price: pos_integer()
        }

  defstruct [:code, :name, :price]

  @doc """
  Returns the product for the given code, or an error if not found.

  ## Examples

      iex> Checkout.Product.fetch("GR1")
      {:ok, %Checkout.Product{code: "GR1", name: "Green tea", price: 311}}

      iex> Checkout.Product.fetch("UNKNOWN")
      {:error, :not_found}
  """
  @spec fetch(String.t()) :: {:ok, t()} | {:error, :not_found}
  def fetch(code) when is_binary(code) do
    case Map.fetch(catalog(), code) do
      {:ok, product} -> {:ok, product}
      :error -> {:error, :not_found}
    end
  end

  @doc """
  Returns all products in the catalog.

  ## Examples

      iex> products = Checkout.Product.all()
      iex> length(products)
      3
  """
  @spec all() :: [t()]
  def all, do: Map.values(catalog())

  # Private catalog — defined as a function so the struct is available at call time.
  defp catalog do
    %{
      "GR1" => %__MODULE__{code: "GR1", name: "Green tea", price: 311},
      "SR1" => %__MODULE__{code: "SR1", name: "Strawberries", price: 500},
      "CF1" => %__MODULE__{code: "CF1", name: "Coffee", price: 1123}
    }
  end

end
