## NOTE: This Hash wrapper efficiently returns values (via the #[] method)
##       through encapsulated use of the Array#bsearch method.
##  It is intended for situations in which efficiency of lookups is paramount,
##  but where efficiency in adding values and building the initial Hash is not
##  so important. Note that every time the content of the Hash is altered, it
##  requires the @sorted_key_value_array to be computed via Hash#sort.

class HashWithBsearch

  # INITIALIZE ACCEPTS OPTIONAL OVERRIDE COMPARATOR BLOCK
  def initialize(&block)
    result = (@wrapped_hash = Hash.new)
    @sorted_hash = Hash.new
    if block_given?
      @sort_block = proc &block
    else
      @sort_block = proc {|a,b| a<=>b}
    end
    sync_sorted_array_and_hash
    return result
  end

  def size()
    return @sorted_key_value_array.size
  end

  # GETTER METHODS
  def [](key)
    if @sorted_key_value_array.empty?
      return nil
    else
      found_kv_pair = @sorted_key_value_array.bsearch{|kv_pair| kv_pair[0] >= key}
      return (found_kv_pair == nil) ? nil : found_kv_pair[1]
    end
  end

  def each(&block)
    if block_given?
      return @sorted_hash.each &block
    else
      return @sorted_hash.each
    end
  end

  def keys
    return @sorted_hash.keys
  end

  def values
    return @sorted_hash.values
  end

  # SETTER METHODS
  def []=(key, value)
    @wrapped_hash[key] = value
    sync_sorted_array_and_hash
  end

  def shift()
    result = @wrapped_hash.shift
    sync_sorted_array_and_hash
    return result
  end

  def clear()
    result = @wrapped_hash.clear
    sync_sorted_array_and_hash
    return result
  end

  private
  def sync_sorted_array_and_hash()
    if @wrapped_hash.size == 0
      @sorted_key_value_array = Array.new
      @sorted_hash = Hash.new
    else
      @sorted_key_value_array = @wrapped_hash.sort &@sort_block
      @sorted_hash = @sorted_key_value_array.to_h
    end
  end
end
