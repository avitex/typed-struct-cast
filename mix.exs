defmodule TypedStruct.Cast.MixProject do
  use Mix.Project

  @description """
  Casting plugin for TypedStruct
  """

  def project do
    [
      app: :typed_struct_cast,
      version: "0.1.0",
      elixir: "~> 1.8",
      deps: deps(),
      description: @description
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:typed_struct, "~> 0.2"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
