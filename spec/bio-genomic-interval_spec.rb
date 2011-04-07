require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Bio::GenomicInterval" do

  #
  # class methods
  #

  describe ".new" do
    context 'given ("chr1", 1, 234)' do
      it "is a Bio::GenomicInterval" do
        Bio::GenomicInterval.new("chr1", 1, 234).should be_a(Bio::GenomicInterval)
      end
    end

    context 'given ("chr1", -1, 234)' do
      it "raises an ArgumentError" do
        expect{Bio::GenomicInterval.new("chr1", -1, 234)}.to raise_error(ArgumentError)
      end
    end

    context 'given ("chr1", 234, 1)' do
      it "raise an ArgumentError" do
        expect{Bio::GenomicInterval.new("chr1", 234, 1)}.to raise_error(ArgumentError)
      end
    end

    context 'given no argument' do
      it "is a Bio::GenomicInterval" do
        Bio::GenomicInterval.new.should be_a(Bio::GenomicInterval)
      end
    end
  end

  describe  ".parse" do 
    context 'given "chr1:1-123"' do
      it 'represents "chr1:1-123" by the to_s method' do 
        Bio::GenomicInterval.parse("chr1:1-123").to_s.should == "chr1:1-123"
      end
    end

    context 'given "chr1:123-1"' do
      it 'represents "chr1:1-123" by the to_s method' do 
        Bio::GenomicInterval.parse("chr1:123-1").to_s.should == "chr1:1-123"
      end
    end

    context 'given "chr1:123"' do
      it 'represents "chr1:123-123" by the to_s method' do 
        Bio::GenomicInterval.parse("chr1:123").to_s.should == "chr1:123-123"
      end
    end
  end

  describe ".zero_based" do
    context 'given ("chr1", 0, 1)' do
      it 'represents "chr1:1-1" by the to_s method' do
        Bio::GenomicInterval.zero_based("chr1", 0, 1).to_s.should == "chr1:1-1"
      end 
    end
  end

  #
  # instance methods
  #
  describe '#zero_start for "chr1:1-1"' do 
    context 'when called' do
      it 'returns 0' do
        Bio::GenomicInterval.parse("chr1:1-1").zero_start.should == 0
      end
    end
  end
  
  describe '#zero_end for "chr1:1-1"' do
    context 'when called' do
      it 'returns 1' do
        Bio::GenomicInterval.parse("chr1:1-1").zero_end.should == 1
      end
    end
  end


  describe '#adjacent' do
    context 'when called first' do
      it 'returns default value' do
        default = Bio::GenomicInterval::DEFAULT_ADJACENT
        Bio::GenomicInterval.new.adjacent.should == default
      end
    end

    context 'when set by #adjacent = 10' do
      it 'returns 10' do
        obj = Bio::GenomicInterval.new
        obj.adjacent = 10
        obj.adjacent.should == 10
      end
    end
  end

  describe '#compare for "chr1:400-600"' do 
    context 'given "chrX:123-234"' do
      it 'returns :different_chr' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chrX:123-234")
        receiver.compare(subject).should == :different_chrom
      end
    end

   context 'given "chr1:123-234"' do
      it 'returns :left_off' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:123-234")
        receiver.compare(subject).should == :left_off
      end
    end

   context 'given "chr1:789-890"' do
      it 'returns :right_off' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:789-890")
        receiver.compare(subject).should == :right_off
      end
    end

    context 'given "chr1:450-550"' do
      it 'returns :contained' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:450-550")
        receiver.compare(subject).should == :contained
      end
    end

    context 'given "chr1:300-700"' do
      it 'returns :containing' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:300-700")
        receiver.compare(subject).should == :containing
      end
    end

    context 'given "chr1:300-500"' do
      it 'returns :left_overlapped' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:300-500")
        receiver.compare(subject).should == :left_overlapped
      end
    end

    context 'given "chr1:500-700"' do
      it 'returns :right_overlapped' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:500-700")
        receiver.compare(subject).should == :right_overlapped
      end
    end

    context 'given same interval' do
      it 'returns :equal' do
        receiver = subject = Bio::GenomicInterval.parse("chr1:400-600")
        receiver.compare(subject).should == :equal
      end
    end

    context 'given "chr1:300-398"' do
      it 'returns :right_adjacent' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:300-398")
        receiver.compare(subject).should == :left_adjacent
      end
    end

    context 'given "chr1:603-800"' do
      it 'returns :right_adjacent' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:603-800")
        receiver.compare(subject).should == :right_adjacent
      end
    end
  end    

  describe '#nearly_overlapped? for "chr1:400-600"' do
    context 'given "chr1:300-500"' do
      it 'returens true' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:300-500")
        receiver.nearly_overlapped?(subject).should be_true
      end
    end

    context 'given "chr1:300-390"' do
      it 'returens true' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        receiver.adjacent = 20
        subject  = Bio::GenomicInterval.parse("chr1:300-390")
        receiver.nearly_overlapped?(subject).should be_true
      end
    end
  end

  describe '#overlapped? for "chr1:400-600"' do
    context 'given "chr1:300-500"' do
      it 'returens true' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:300-500")
        receiver.overlapped?(subject).should be_true
      end
    end
    context 'given "chr1:300-370"' do
      it 'returens false' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        receiver.adjacent = 20
        subject  = Bio::GenomicInterval.parse("chr1:300-370")
        receiver.overlapped?(subject).should be_false
      end
    end
  end

  describe '#expand for "chr1:400-600"' do
    context 'given "chr1:603-800"' do
      it 'returns "chr1:400-800" by the to_s method' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chr1:603-800")
        receiver.expand(subject).to_s.should == "chr1:400-800"
      end
    end

    context 'given "chrX:603-800"' do
      it 'raises ArgumentError' do
        receiver = Bio::GenomicInterval.parse("chr1:400-600")
        subject  = Bio::GenomicInterval.parse("chrX:603-800")
        expect{receiver.expand(subject)}.to raise_error(ArgumentError)
      end
    end
  end

  describe '#size' do
    context 'when initialized by "chr1:400-410"' do
      it 'returens 11' do
        Bio::GenomicInterval.parse("chr1:400-410").size.should == 11
      end
    end
  end

  describe '#center' do
    context 'when initialized by "chr1:11-15"' do
      it 'returns "chr1:13-13" by the to_s method' do
        Bio::GenomicInterval.parse("chr1:11-15").center.to_s.should == "chr1:13-13"
      end
    end

    context 'when initialize by "chr1:10-15"' do
      it 'returns "chr1:12-12" by the to_s method' do
        Bio::GenomicInterval.parse("chr1:10-15").center.to_s.should == "chr1:12-12"
      end
    end
   end

  describe '#overlap for "chr1:400-500"' do 
    context 'given "chr1:100-200"' do
      it 'returns -199' do
        receiver = Bio::GenomicInterval.parse("chr1:400-500")
        subject  = Bio::GenomicInterval.parse("chr1:100-200")
        receiver.overlap(subject).should == -199
      end
    end

    context 'given "chr1:100-399"' do
      it 'returns 0' do
        receiver = Bio::GenomicInterval.parse("chr1:400-500")
        subject  = Bio::GenomicInterval.parse("chr1:100-399")
        receiver.overlap(subject).should == 0
      end
    end

    context 'given "chr1:100-400"' do
      it 'returns 1' do
        receiver = Bio::GenomicInterval.parse("chr1:400-500")
        subject  = Bio::GenomicInterval.parse("chr1:100-400")
        receiver.overlap(subject).should == 1
      end
    end

    context 'given "chr1:410-490"' do
      it 'returns 81' do
        receiver = Bio::GenomicInterval.parse("chr1:400-500")
        subject  = Bio::GenomicInterval.parse("chr1:410-490")
        receiver.overlap(subject).should == 81
      end
    end

    context 'given "chr1:300-600"' do
      it 'returns 101' do
        receiver = Bio::GenomicInterval.parse("chr1:400-500")
        subject  = Bio::GenomicInterval.parse("chr1:300-600")
        receiver.overlap(subject).should == 101
      end
    end

    context 'given "chr1:400-500"' do
      it 'returns 101' do
        receiver = Bio::GenomicInterval.parse("chr1:400-500")
        subject  = Bio::GenomicInterval.parse("chr1:400-500")
        receiver.overlap(subject).should == 101
      end
    end

    context 'given "chr1:450-550"' do
      it 'returns 51' do
        receiver = Bio::GenomicInterval.parse("chr1:400-500")
        subject  = Bio::GenomicInterval.parse("chr1:450-550")
        receiver.overlap(subject).should == 51
      end
    end

    context 'given "chr1:501-600"' do
      it 'returns 0' do
        receiver = Bio::GenomicInterval.parse("chr1:400-500")
        subject  = Bio::GenomicInterval.parse("chr1:501-600")
        receiver.overlap(subject).should == 0
      end
    end

    context 'given "chr1:550-600"' do
      it 'returns -49' do
        receiver = Bio::GenomicInterval.parse("chr1:400-500")
        subject  = Bio::GenomicInterval.parse("chr1:550-600")
        receiver.overlap(subject).should == -49
      end
    end

    context 'given "chrX:100-900"' do
      it 'returns 0' do
        receiver = Bio::GenomicInterval.parse("chr1:400-500")
        subject  = Bio::GenomicInterval.parse("chrX:100-900")
        receiver.overlap(subject).should == 0
      end
    end

  end

end
