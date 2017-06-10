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
    rebuild_sorted_hash
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
    rebuild_sorted_hash
    if block_given?
      return @sorted_hash.each &block
    else
      return @sorted_hash.each
    end
  end

  def keys
    rebuild_sorted_hash
    return @sorted_hash.keys
  end

  def values
    rebuild_sorted_hash
    return @sorted_hash.values
  end

  # SETTER METHODS -- additional methods may need to be added!
  def []=(key, value)
    @wrapped_hash[key] = value
    sync_sorted_array_and_hash([key, value])
  end

  # NOTE: this code is not optimized for deletions/shifts (it simply resorts the underlying array)
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

  def rebuild_sorted_hash
    if @sorted_hash.nil?
      @sorted_hash = @sorted_key_value_array.to_h
    end
  end

  def sync_sorted_array_and_hash(inserted_kv_pair=nil)
    if @wrapped_hash.size == 0
      @sorted_key_value_array = Array.new
      @sorted_hash = Hash.new
    else
      if inserted_kv_pair.nil?
        @sorted_key_value_array = @wrapped_hash.sort &@sort_block
      else
        if @sort_option == :descending
          insertion_index = @sorted_key_value_array.bsearch_index{|kv_pair| inserted_kv_pair[0] >= kv_pair[0]}
        else
          insertion_index = @sorted_key_value_array.bsearch_index{|kv_pair| kv_pair[0] >= inserted_kv_pair[0]}
        end
        if insertion_index.nil?
          @sorted_key_value_array.push(inserted_kv_pair)
        else
          @sorted_key_value_array.insert(insertion_index, inserted_kv_pair)
        end
      end
      @sorted_hash = nil
    end
  end
end
