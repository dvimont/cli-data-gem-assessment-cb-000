## NOTE: This Hash wrapper efficiently finds and returns values
##  (via the #[] method) through encapsulated use of the Array#bsearch method.
##
##  It is intended for situations in which efficiency of lookups is paramount,
##  but where efficiency in adding values and building the initial Hash is not
##  so important. Note that every time the content of the Hash is altered, it
##  requires the @sorted_key_value_array to be recomputed via Hash#sort.

class HashWithBsearch

  def initialize(sort_option=:ascending)
    result = (@wrapped_hash = Hash.new)
    @sort_option = sort_option
    @sorted_hash = Hash.new
    if @sort_option == :descending
      @sort_block = proc {|a,b| b<=>a}
    else
      @sort_block = proc {|a,b| a<=>b}
    end
    sync_sorted_array_and_hash   # utilizes @sort_block
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
      if @sort_option == :descending
        found_kv_pair = @sorted_key_value_array.bsearch{|kv_pair| kv_pair[0] <=> key}
      else
        found_kv_pair = @sorted_key_value_array.bsearch{|kv_pair| key <=> kv_pair[0]}
      end
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

  # SETTER METHODS -- additional methods may need to be added!
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
