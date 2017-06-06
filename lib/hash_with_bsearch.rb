## NOTE: This subclass of Hash efficiently returns values (via the #[] method)
##       through encapsulated use of the Array#bsearch method.
##  It is intended for situations in which efficiency of lookups is paramount,
##  but where efficiency in adding values and building the initial Hash is not
##  so important. Note that every time the content of the Hash is altered, it
##  requires the @sorted_key_value_array to be computed via hash#sort.

class HashWithBsearch

  @sorted_key_value_array = Array.new

  def sorted_hash
    return @sorted_key_value_array.to_h
  end

  def sync_sorted_key_value_array()
    if self.size == 0
      @sorted_key_value_array = Array.new
    else
      @sorted_key_value_array = self.sort &@sort_block
    end
  end

  # OVERRIDES OF ADD and GET ("[bracket]") methods
  def []=(key, value)
    result = super
    self.sync_sorted_key_value_array
    return result
  end

  def [](key)
    if @sorted_key_value_array.empty?
      return nil
    else
      found_kv_pair = @sorted_key_value_array.bsearch{|kv_pair| kv_pair[0] >= key}
      return (found_kv_pair == nil) ? nil : found_kv_pair[1]
    end
  end

  # INITIALIZE ACCEPTS OPTIONAL OVERRIDE COMPARATOR BLOCK
  def initialize(&block)
    result = super
    if block_given?
      @sort_block = proc &block
    else
      @sort_block = proc {|a,b| a<=>b}
    end
    self.sync_sorted_key_value_array
    return result
  end

  # OVERRIDES OF METHODS WHICH RESULT IN ALTERATION OF HASH CONTENT
  def shift()
    result = super
    self.sync_sorted_key_value_array
    return result
  end

  def clear()
    result = super
    self.sync_sorted_key_value_array
    return result
  end
end
