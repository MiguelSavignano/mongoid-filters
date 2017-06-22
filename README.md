# Moingoid::Filters

Help to filter with params


## Usage
#### install
dowload the file lib/mongoid_filters.rb put in you initializer folder

### include in you models 
class Item
  import Mongoid::Document
  import Mongoid::Filters
end

```html
<div class="custom-filters">
  <input type="number" name="item[price__gte]" placeholder="price grhather than"/>
  <input type="number" name="item[price__lte]" placeholder="price lower than"/>
</div>
```
```ruby
# controller
@items = Item.filter(params[:item])
or use
filters = QueryToFilterQuery.run(params[:item])
@item = Item.where(filters)
```

## filter
```ruby
  Item.filter({ price__gte: "", price__lte: "100" })
```
## to_filter_query
```ruby
  { price__gte: "", price__lte: "100" }.to_filter_query
  # { :price.in: "100" }
```

## run
```ruby
  QueryToFilterQuery.run({ price__gte: "", price__lte: "100" })
  # { :price.in: "100" }
```
## Explain
When you filter you don't need fill all fields and the problem with this it's the form send a empty string
```ruby
 params[:item]
 # {price__gte: "", price__lte: "100"}
```
you need to sanitize the params delete the empty string and change price lower than to price.lte => 100

## Custumize

#### seed the example of regexp

Add you new postfix value to the custom filter operators

```ruby
  def custom_filter_operators
    %W[ regexp ]
  end
```

Override the method set_custom_filters with yours custom method, you need to return the new key and the new value in array format
``` ruby
  def set_custom_filters(key, value, operator)
    if operator == "regexp" && !empty_value?(value)
      value = /#{build_regexp(value)}/i
    end
    [key, value]
  end
```

and use then

```ruby
  { name__regexp: "car" }.to_filter_query
  # { name__regexp: /car/i }
```

seed 


 




