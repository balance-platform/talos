defmodule Talos.Types.NumberType do
  defstruct [:gteq, :lteq, :gt, :lt, :type]
  @behaviour Talos.Types

  def valid?(%__MODULE__{gteq: gteq, lteq: lteq, gt: gt, lt: lt, type: type}, value)
      when type in [nil, :float, :integer] do
    with true <- check_type(type, value),
         true <- is_nil(lt) || value < lt,
         true <- is_nil(gt) || value > gt,
         true <- is_nil(gteq) || value >= gteq,
         true <- is_nil(lteq) || value <= lteq do
      true
    else
      false -> false
    end
  end

  defp check_type(nil, value) do
    is_float(value) || is_integer(value)
  end

  defp check_type(:integer, value) do
    is_integer(value)
  end

  defp check_type(:float, value) do
    is_float(value)
  end
end
