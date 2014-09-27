class XcodebuildCompileCRule
  def initialize lines
    @lines = lines.clone
  end
  def metadata
    @metadata ||= @lines[0].split(/\s+/)
  end
  def source_file_full_path
    self.metadata[2]
  end
  def language
    self.metadata[5]
  end
  def arch
    self.metadata[4]
  end
  def source_file
    @source_file ||=  File.basename(self.source_file_full_path)
  end
  def to_s
    @lines.join "\n"
  end
end

class Xcodebuild
  attr_accessor :compile_rule, :rules
  def initialize data
    @rules = []
    self.parse_rules data 
  end

  def << rule
    @rules << rule
  end
  def find_rule source, arch
    @rules.detect { |rule| rule.source_file == source and rule.arch == arch }
  end
  def parse_rules data
    temp_rules = []
    lines = []
    data.split("\n").each do |line|
      if line =~ /^\w/
        lines = []
        temp_rules << lines
      end
      lines << line
    end
    temp_rules.select do |rule_lines| 
      rule_lines[0] =~ /^CompileC/
    end.each do |rule_lines|
      self << XcodebuildCompileCRule.new(rule_lines)
    end
  end


end
