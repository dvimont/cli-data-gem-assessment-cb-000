class HashWithBsearch < Hash

  @sorted_key_value_array = Array.new

  def sync_sorted_key_value_array
    if self.size == 0
      @sorted_key_value_array = Array.new
    else
      @sorted_key_value_array = self.sort{|a,b| a<=>b}
    end
  end

  # OVERRIDES
  def initialize(object=nil)
    result = super
    self.sync_sorted_key_value_array
    return result
  end

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
end
