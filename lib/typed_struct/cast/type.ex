defmodule TypedStruct.Cast.Type do
  @type t :: atom()
  @type opts :: any()

  @callback cast(any(), opts()) :: {:ok, any()} | {:error, any()}

  @builtin [:integer]

  @spec cast(t() | nil, any(), opts()) :: {:ok, any()} | {:error, any()}
  def cast(nil, value, _opts) do
    {:ok, value}
  end

  def cast(:integer, value, _opts) when is_binary(value) do
    case Integer.parse(value) do
      {value, ""} -> {:ok, value}
      _ -> {:error, "invalid integer"}
    end
  end

  def cast(:integer, value, _opts) when is_integer(value) do
    {:ok, value}
  end

  def cast(type, value, opts) do
    if is_primitive?(type) do
      {:error, "could not cast to #{type}"}
    else
      type.cast(value, opts)
    end
  end

  @spec is_primitive?(t()) :: boolean
  def is_primitive?(type) do
    type in @builtin
  end
end
