# Mongoid::Filters

Help to filter with params

## Usage
### install
dowload the file lib/mongoid_filters.rb put in you initializer folder

#### include in you models 
```ruby
  class Item
    import Mongoid::Document
    import Mongoid::Filters
  end
```

```html
<div class="custom-filters">
  <input type="number" name="item[price__gte]" placeholder="price grhather than" />
  <input type="number" name="item[price__lte]" placeholder="price lower than" />
</div>
```
```ruby
# controller
@items = Item.filter(params[:item])
# or use
query = params[:item].to_filter_query
@item = Item.where(query)
```

## filter
```ruby
  Item.filter({ price__gte: "", price__lte: "100" })
```

## to_filter_query
```ruby
  { price__gte: "", price__lte: "100" }.to_filter_query
  # { :price.lte => "100" }
```

## run
```ruby
  QueryToFilterQuery.run({ price__gte: "", price__lte: "100" })
  # { :price.lte => "100" }
```
## Explain
When you filter you don't need fill all fields and the problem with this it's the form send a empty string.
you need to sanitize the params delete the empty string and change price lower than to price.lte => 100

Usando esta gema conseguirimos el el mismo resultado que si hicieramos de manera manual la combinacion de cada tipo de operador de mongo con cada campo del modelo.

Si no utilizas la gema debes hacer algo parecido a esto
Other way to do this without the gem it's something like this code 
```ruby
 params[:item]
 # { price__gte: "", price__lte: "100" }
 filter_query = {}
 filter_query[:price.lte] = params[:price__lte] if params[:price__lte].present?
 filter_query[:price.gte] = params[:price__gte] if params[:price__gte].present?
 filter_query[:price.lt] = params[:price__lt] if params[:price__lt].present?
 filter_query[:price.gt] = params[:price__gt] if params[:price__gt].present?
 filter_query[:price.gt] = params[:price__gt] if params[:price__gt].present?
 
 filter_query[:price.in] = params[:price__in] if params[:price__in].present?
 filter_query[:price.nin] = params[:price__nin] if params[:price__nin].present?
 filter_query[:price.with_size] = params[:price__with_size] if params[:price__with_size].present?
 # { :price.lte => "100" }
```
## Customize

### default mongoid operators
``` ruby
  def mongoid_filter_operators
    %W[ gt lt gte lte in with_size nin ]
  end
```

#### Add custom operator

Add a new postfix value to the custom filter operators

```ruby
  def custom_filter_operators
    %W[ regexp ]
  end
```

Override the method set_custom_filters with yours custom method, you need to return the new key and the new value in array format
``` ruby
  def set_custom_filters(key, value, operator)
    # key is setter without the operator
    if operator == "regexp" && !empty_value?(value)
      value = /#{build_regexp(value)}/i
    end
    [key, value]
  end
```

```ruby
  { name__regexp: "car" }.to_filter_query
  # { name: /car/i }
```


 




