defmodule PlaygroundTest do
  use ExUnit.Case, async: true

  test "it works" do
    Playground.start([
      :decimal
    ])

    IO.inspect(Decimal.add(1, 2))
  end
end
