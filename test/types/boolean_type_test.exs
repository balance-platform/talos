defmodule Types.BooleanTypeTest do
  use ExUnit.Case
  alias Talos.Types.BooleanType

  test "#valid? - true" do
    assert BooleanType.valid?(%BooleanType{}, true) == true
    assert BooleanType.valid?(%BooleanType{}, false) == true
    assert BooleanType.valid?(%BooleanType{allow_nil: true}, nil) == true
    assert BooleanType.valid?(%BooleanType{allow_nil: false}, nil) == false
  end

  test "#valid? - false" do
    assert BooleanType.valid?(%BooleanType{}, "Y") == false
    assert BooleanType.valid?(%BooleanType{}, "true") == false
    assert BooleanType.valid?(%BooleanType{}, "false") == false
  end
end
