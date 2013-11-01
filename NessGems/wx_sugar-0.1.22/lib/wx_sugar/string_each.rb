class String
  def each
    self.split("\n").each do |line|
      yield line
    end
  end
end
