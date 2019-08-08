defmodule TypedStruct.Cast do
  @type params :: params_kw | params_map
  @type params_kw :: [{atom(), any()}]
  @type params_map :: %{(atom() | binary()) => any()}
  @type result :: {:ok, any()} | {:error, any()}

  defmacro __using__(_) do
    quote do
      @__typed_struct_cast_define_helpers__ true
    end
  end

  @spec cast(map() | module(), params()) :: {:ok, any()} | {:error, any()}
  def cast(module_or_struct, params) do
    __MODULE__.Plugin.cast(module_or_struct, params)
  end

  @spec cast!(map() | module(), params()) :: any()
  def cast!(module_or_struct, params) do
    case cast(module_or_struct, params) do
      {:ok, value} -> value
      {:error, err} -> raise RuntimeError, message: "failed to cast: #{err}"
    end
  end
end
