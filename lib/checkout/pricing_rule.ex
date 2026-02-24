defmodule Checkout.PricingRule do
  @moduledoc """
  Behaviour for pricing rules applied at checkout.

  A pricing rule computes the total price in cents for a `Checkout.LineItem`
  (product + quantity). Each rule module implements the `apply/2` callback.

  ## Implementing a rule

      defmodule MyRule do
        @behaviour Checkout.PricingRule

        @impl true
        def apply(%Checkout.LineItem{} = line_item, opts) do
          # compute and return total cents for this line
        end
      end

  ## Using rules

  Rules are collected and managed via `Checkout.PricingRules`, which validates
  that at most one rule targets each product code and provides the lookup and
  application logic.
  """

  @doc """
  Computes the total price in cents for the given line item.

  Receives the full `LineItem` (product + quantity) and rule-specific `opts`.
  Returns the total price in cents as a non-negative integer.
  """
  @callback apply(line_item :: Checkout.LineItem.t(), opts :: keyword()) :: non_neg_integer()
end
