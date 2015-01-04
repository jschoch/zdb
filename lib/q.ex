defmodule Zq do
  @moduledoc ~S"""
    a struct for managing the dynamodb query api

  ### Attributes
    
    :kc are key conditions per docs: `http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html#DDB-Query-request-KeyConditions`

  ### Options

    :limit the query limit

    :qf query filter `http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html#DDB-Query-request-QueryFilter`

    :esk exclusive start key `http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html#DDB-Query-request-ExclusiveStartKey`

    :rcc return consumed capacity 

    :consistent_read default :true

    :select default all_attributes `http://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_Query.html#DDB-Query-request-Select`
  
    :fe a filter expression [docs](http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Expressions.SpecifyingConditions.html)
    
    :eav expression attribute values

  """
  defstruct table: "", 
    index: "", 
    select: :all_attributes, 
    kc: [],
    qf: [], 
    fe: "",
    eav: [],
    operator: :and, 
    esk: [], 
    rcc: :none, 
    limit: 100,
    consistent_read: :true
end
