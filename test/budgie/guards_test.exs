defmodule Budgie.GuardsTest do
  use ExUnit.Case, async: true

  import Budgie.Guards

  describe "is_uuid" do
    test "True when the string is a UUID" do
      assert is_uuid("4ceabc96-e5e3-4274-9092-71b2f1a4615b")
    end

    test "False when the string is not a UUID" do
      refute is_uuid("ppp")
    end
  end
end
