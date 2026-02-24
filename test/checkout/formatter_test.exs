defmodule Checkout.FormatterTest do
  use ExUnit.Case, async: true
  doctest Checkout.Formatter

  alias Checkout.Formatter

  describe "format_price/1" do
    test "formats 311 as £3.11" do
      assert Formatter.format_price(311) == "£3.11"
    end

    test "formats 500 as £5.00" do
      assert Formatter.format_price(500) == "£5.00"
    end

    test "formats 1123 as £11.23" do
      assert Formatter.format_price(1123) == "£11.23"
    end

    test "formats 0 as £0.00" do
      assert Formatter.format_price(0) == "£0.00"
    end

    test "formats single-digit pence with leading zero" do
      assert Formatter.format_price(101) == "£1.01"
      assert Formatter.format_price(109) == "£1.09"
    end
  end
end
