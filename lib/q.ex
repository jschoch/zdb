defmodule Zq do
  defstruct table: "", 
    index: "", 
    select: :all_attributes, 
    kc: [],
    qf: [], 
    operator: :and, 
    esk: [], 
    rcc: :none, 
    limit: 100,
    consistent_read: :true
end
