defmodule Zdb.TH do
  @moduledoc ~S"""
  samples from the erlcloud test suite working in elixir for reference

  """
  def keys_to_strings(list) do
    Enum.map(list,fn({k,v})-> {Atom.to_string(k),v} end)
  end
  def e_create_table do
    table_name = "Thread"
    attrDefs = [{"Subject",:s},{"LastPostDateTime",:s},{"ForumName",:s}]
    key_schema = {"ForumName","Subject"}
    units = 5
    local = {:local_secondary_indexes,[{"LastPostIndex","LastPostDateTime",:keys_only}]}
    global = {:global_secondary_indexes,
              [{"SubjectTimeIndex",
               {"Subject","LastPostDateTime"},
               :all,
               units,
               units}
              ]}
    opts = [local,global]
    config = Zdb.config
    {res,data} = :erlcloud_ddb2.create_table(table_name, attrDefs, key_schema, units,units,opts, config)
  end
  def e_put do
    table_name = "Thread"
    attributes = [LastPostedBy: "fred@example.com",
                  ForumName: "Amazon DynamoDB",
                  LastPostDateTime: "201303201023",
                  Tags: ["Update","Multiple Items","HelpMe"],
                  Subject: "How do I update multiple items?",
                  Message: "I want to update multiple items in a single API call. What's the best way to do that?"
                 ]
    attributes = Zdb.TH.keys_to_strings(attributes)
    opts = [{:expected,[{"ForumName",:null},{"Subject",:null}]}]
    config = Zdb.config
    {res,data} = :erlcloud_ddb2.put_item(table_name,attributes,opts,config)
  end
  def e_delete do
    table_name = "Thread"
    key = [
            {"ForumName",{:s,"Amazon DynamoDb"}},
            {"Subject",{:s,"How do I update multiple items?"}}
          ]
    opts = [{:return_values, :all_old},{:expected, {"Replies",:null}}]
    config = Zdb.config
    {res,data} = :erlcloud_ddb2.delete_item(table_name, key,opts,config)
  end
  def e_q do
    table_name = "Thread"
    key_conditions = [
                      {"LastPostDateTime",{{:s, "20130101"},{:s, "20130115"}},:between},
                      {"ForumName",{:s,"Amazon DynamoDB"}}
                    ]
    opts = [index_name: "LastPostIndex",
            select: :all_attributes,
            limit: 3,
            consistent_read: :true]
    config = Zdb.config
    {res,data} = :erlcloud_ddb2.q(table_name,key_conditions,opts,config)
  end
  def e_get do
    table_name = "Thread"
    key = [ForumName: "Amazon DynamoDB",
          Subject: "How do I update multiple items?"]
    key = keys_to_strings(key)
    opts = [attributes_to_get: ["LastPostDateTime","Message","Tags",],
            consistent_read: :true,
            return_consumed_capacity: :total]
    config = Zdb.config
    {res,data} = :erlcloud_ddb2.get_item(table_name, key, opts, config)
  end
  def e_update do
    table_name = "Thread"
    key = [ {"ForumName",{:s,"Amazon DynamoDB"}},
            {"Subject",{:s,"How do I update multiple items?"}}]
    updates = [{"LastPostedBy", {:s,"alice@example.com"},:put}]
    opts = [expected: {"LastPostedBy",{:s,"fred@example.com"}},
            return_values: :all_new
            ]
    config = Zdb.config
    {res,data} = :erlcloud_ddb2.update_item(table_name, key,updates,opts,config)
  end
end
