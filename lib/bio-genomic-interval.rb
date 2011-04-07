module Bio

  class GenomicInterval
    DEFAULT_ADJACENT = 20
    
    def initialize(chrom = "", chr_start = 1, chr_end = 1)
      raise ArgumentError unless chr_start >= 1
      raise ArgumentError unless chr_end >= 1
      raise ArgumentError unless chr_start <= chr_end
      @chrom = chrom
      @chr_start = chr_start
      @chr_end = chr_end
      @adjacent = DEFAULT_ADJACENT
    end

    attr_accessor :chrom, :chr_start, :chr_end, :adjacent

    def self.parse(interval)
      chrom, start_end = interval.split(":")
      str_start, str_end = start_end.split("-")[0..1]
      str_end = str_start if str_end.nil?
      chr_start = Integer(str_start)
      chr_end   = Integer(str_end)
      if chr_start > chr_end
        chr_end, chr_start = chr_start, chr_end
      end
      self.new(chrom, chr_start, chr_end)
  end
    
    def self.zero_based(chrom = "", z_start = 0, z_end = 1)
      z_start += 1
      self.new(chrom, z_start, z_end)
    end

    def to_s
      "#{@chrom}:#{@chr_start}-#{@chr_end}"
    end

    def zero_start
      @chr_start - 1
    end

    def zero_end
      @chr_end
    end

    def compare(other)
      case
      when self.chrom != other.chrom
        :different_chrom
      when other.chr_end.between?(self.chr_start - @adjacent, self.chr_start - 1)
        :left_adjacent
      when other.chr_start.between?(self.chr_end + 1, self.chr_end + @adjacent)
        :right_adjacent
      when other.chr_end < self.chr_start
        :left_off
      when self.chr_end < other.chr_start
        :right_off
      when (self.chr_start == other.chr_start) &&
          (self.chr_end == other.chr_end)
        :equal
      when (other.chr_start.between?(self.chr_start, self.chr_end)) &&
          (other.chr_end.between?(self.chr_start, self.chr_end))
        :contained
      when (self.chr_start.between?(other.chr_start, other.chr_end)) &&
          (self.chr_end.between?(other.chr_start, other.chr_end))
        :containing
      when (other.chr_start < self.chr_start) &&
          (other.chr_end.between?(self.chr_start, self.chr_end))
        :left_overlapped
      when (other.chr_start.between?(self.chr_start, self.chr_end)) &&
          (self.chr_end < other.chr_end)
        :right_overlapped
      else
        raise Exception, "must not happen"
      end
    end

    def nearly_overlapped?(other)
      result = compare(other)
      [ :left_adjacent, :right_adjacent,
        :equal, :contained, :containing,
        :left_overlapped, :right_overlapped].any?{|x| x == result} 
    end

    def overlapped?(other)
      result = compare(other)
      [ :equal, :contained, :containing,
        :left_overlapped, :right_overlapped].any?{|x| x == result} 
    end

    def expand(other)
      raise ArgumentError unless self.chrom == other.chrom
      new_start = [self.chr_start, other.chr_start].min
      new_end = [self.chr_end, other.chr_end].max
      Bio::GenomicInterval.new(@chrom, new_start, new_end)
    end

    def size
      chr_end - chr_start + 1
    end

    alias :length :size

    def center
      center = (chr_start + chr_end) / 2
      Bio::GenomicInterval.new(self.chrom, center, center)
    end

    # when a overlap exist, return a positive integers (>1) for the overlap length
    # when a overlap does not exist,
    #   return a zero or a negative (<= 0) for the space size between the intervals
    def overlap(other)
      case self.compare(other)
      when :different_chrom
        0
      when :left_off, :left_adjacent, :left_overlapped
        other.chr_end - self.chr_start + 1
      when :contained, :equal
        other.size
      when :containing
        self.size
      when :right_off, :right_adjacent, :right_overlapped
        self.chr_end - other.chr_start + 1
      else
        raise Exception, "must not happen"
      end
    end
  end
end
