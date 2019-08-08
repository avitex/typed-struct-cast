defmodule TypedStruct.Cast.MixProject do
  use Mix.Project

  def project do
    [
      app: :typedstruct_cast,
      version: "0.1.0",
      elixir: "~> 1.8",
      deps: deps()
    ]
  end

  defp deps do
    [
      {:typed_struct, github: "ejpcmac/typed_struct", branch: "develop"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
