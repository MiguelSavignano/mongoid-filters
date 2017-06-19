require 'rails_helper'
class TestModel
  include Mongoid::Document
  include Mongoid::Filters
end

describe "QueryToFilterQuery" do
  it "#run" do
    expect(QueryToFilterQuery.run(nil)).to eq({})
    expect(QueryToFilterQuery.run({ amount__gte: 100 })).to eq({ :amount.gte => 100 })
    expect(QueryToFilterQuery.run({ amount: 100, name: "" })).to eq({ amount: 100 })
    expect(QueryToFilterQuery.run({ name__regexp: "música" })).to eq({ "name" => /m(u|ú)s(i|í)c(a|á)/i })
    expect(QueryToFilterQuery.run({ "embedded.search" => "search" })).to eq({ "embedded.search" => "search" })
  end

  it "add method to_filter_query for hash" do
    expect({ amount__gte: 100 }.to_filter_query).to eq({ :amount.gte => 100 })
  end

  it "combine with criteria mongoid" do
    expect(TestModel.filter({ amount__gte: 100 })).to eq(TestModel.where({ :amount.gte => 100 }))
    expect(TestModel.where(name: /car/i).filter({ amount__gte: 100 })).to eq(TestModel.where({ name: /car/i, :amount.gte => 100 }))
    expect(TestModel.filter({ amount: 28, name: "" })).to eq(TestModel.where({ amount: 28 }))
  end
end
