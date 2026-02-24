defmodule Checkout.PricingRules do
  @moduledoc """
  A validated collection of pricing rules for a checkout session.

  Each rule is a 3-element tuple `{module, product_code, opts}` where:
  - `module` implements the `Checkout.PricingRule` behaviour
  - `product_code` is the product code the rule applies to (e.g. `"GR1"`)
  - `opts` is a keyword list of rule-specific options

  ## Constraint: one rule per product

  At most one rule may target a given product code. `new/1` enforces this
  constraint at construction time, so a `%PricingRules{}` struct is always valid.

  ## Examples

      iex> rules = [
      ...>   {Checkout.PricingRule.BuyOneGetOneFree, "GR1", []},
      ...>   {Checkout.PricingRule.BulkDiscount, "SR1", [min_qty: 3, discount_price: 450]}
      ...> ]
      iex> {:ok, %Checkout.PricingRules{}} = Checkout.PricingRules.new(rules)
  """

  alias Checkout.LineItem

  @type rule :: {module(), String.t(), keyword()}

  @type t :: %__MODULE__{
          rules: [rule()]
        }

  defstruct rules: []

  @doc """
  Creates a new `PricingRules` struct from a list of rule tuples.

  Returns `{:ok, %PricingRules{}}` if all product codes are unique, or
  `{:error, {:duplicate_product_rule, code}}` for the first duplicate found.

  ## Examples

      iex> Checkout.PricingRules.new([])
      {:ok, %Checkout.PricingRules{rules: []}}

      iex> rules = [{Checkout.PricingRule.BuyOneGetOneFree, "GR1", []}]
      iex> {:ok, %Checkout.PricingRules{rules: ^rules}} = Checkout.PricingRules.new(rules)
      {:ok, %Checkout.PricingRules{rules: [{Checkout.PricingRule.BuyOneGetOneFree, "GR1", []}]}}
  """
  @spec new([rule()]) :: {:ok, t()} | {:error, {:duplicate_product_rule, String.t()}}
  def new(rules) when is_list(rules) do
    case validate_no_duplicates(rules) do
      :ok -> {:ok, %__MODULE__{rules: rules}}
      error -> error
    end
  end

  @doc """
  Computes the subtotal in cents for a `LineItem` by applying the matching rule.

  If a rule exists for the line item's product code, it is applied.
  Otherwise the default subtotal (`quantity * unit_price`) is used.

  ## Examples

      iex> product = %Checkout.Product{code: "GR1", name: "Green tea", price: 311}
      iex> line_item = %Checkout.LineItem{product: product, quantity: 3}
      iex> {:ok, rules} = Checkout.PricingRules.new([])
      iex> Checkout.PricingRules.apply_to(rules, line_item)
      933
  """
  @spec apply_to(t(), LineItem.t()) :: non_neg_integer()
  def apply_to(%__MODULE__{rules: rules}, %LineItem{product: product} = line_item) do
    case find(rules, product.code) do
      {module, _code, opts} -> module.apply(line_item, opts)
      nil -> LineItem.subtotal(line_item)
    end
  end

  @doc """
  Finds the rule tuple for the given product code, or returns `nil`.

  ## Examples

      iex> rules = [{Checkout.PricingRule.BuyOneGetOneFree, "GR1", []}]
      iex> {:ok, pricing_rules} = Checkout.PricingRules.new(rules)
      iex> Checkout.PricingRules.find(pricing_rules.rules, "GR1")
      {Checkout.PricingRule.BuyOneGetOneFree, "GR1", []}

      iex> {:ok, pricing_rules} = Checkout.PricingRules.new([])
      iex> Checkout.PricingRules.find(pricing_rules.rules, "GR1")
      nil
  """
  @spec find([rule()], String.t()) :: rule() | nil
  def find(rules, code) when is_list(rules) and is_binary(code) do
    Enum.find(rules, fn {_module, rule_code, _opts} -> rule_code == code end)
  end

  # Validates that no two rules target the same product code.
  # Returns :ok or {:error, {:duplicate_product_rule, code}}.
  defp validate_no_duplicates(rules) do
    rules
    |> Enum.reduce_while(MapSet.new(), fn {_module, code, _opts}, seen ->
      if MapSet.member?(seen, code) do
        {:halt, {:error, {:duplicate_product_rule, code}}}
      else
        {:cont, MapSet.put(seen, code)}
      end
    end)
    |> case do
      %MapSet{} -> :ok
      error -> error
    end
  end
end
