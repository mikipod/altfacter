require 'json'
require 'facter'
require 'pp'
# require 'random'
# Facter API - http://www.rubydoc.info/gems/facter/2.4.6/Facter
class AltFacter
  def initialize
    @altfacts = {
      'architecture' => %w(x86 x64 8086),
      'kernel' => %w(windows Darwin Linux Solaris),
      'os' => { 'name' => %w(pancakes windows amiga) }
    }

    @facts = Facter.to_hash
    @fact_keys = Facter.list
  end

  def get_main_facts
    @facts
  end

  def process_facts(facts)
    facts.each do |key, value|
      if value.is_a?(Hash)
        process_facts(value)
        # puts "Hash: #{key}"
      elsif value.is_a?(Integer)
        facts[key] = rint
      elsif value =~ /^[-+]?[0-9]*\.?[0-9]+$/
        # puts "Float: #{key}"
        facts[key] = rfloat
      elsif value =~ /^(?:(\d+)\.)?(?:(\d+)\.)?(\*|\d+)$/
        # puts "SemVer: #{key}"
        facts[key] = rsemver
      elsif value =~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
        # puts "Network: #{key}"
        facts[key] = rnetwork
      elsif value =~ /^(\d+).(\d+)/ && value =~ /MB|GB$/
        do_ram(key, value)
      elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
       facts[key] = ['true','false'].sample
      else
        # puts Other: #{key}
        distort_facts(key, value) if @altfacts[key]
      end
    end
  end

  def show_facts
    args = ARGV
    args.delete(__FILE__)
    if args.empty?
      pp @facts
    else
      args.each { |a| puts @facts[a] if a != __FILE__ }
    end
  end

  def rfloat
    f = '%.2f' % rand(4..256).round(2)
    f
  end

  def rsemver
    rint + '.' + rint + '.' + rint
  end

  def rnetwork
    roc + '.' + roc + '.' + roc + '.' + roc
  end

  def roc
    rand(1..255).to_s
  end

  def rint
    rand(1..99).to_s
  end

  def do_ram(fact, value)
    if value =~ /GB$/
      size = 'GB'
    elsif value =~ /MB$/
      size = 'MB'
    end
    tmp = value.tr(size, '').strip
    @facts[fact] = rfloat + " #{size}" if tmp =~ /^[-+]?[0-9]*\.?[0-9]+$/
    @facts[fact] = rint + " #{size}" if tmp =~ /^\d+$/
  end

  def distort_facts(key, value)
    @altfacts[key].delete(value) if @altfacts[key].include?(value)
    @facts[key] = @altfacts[key].sample
  end

  def testit(blah)
    "i'm here bro #{blah}"
  end
  # end of AltFacter class
end

# Begin script
i = AltFacter.new
facts = i.get_main_facts
i.process_facts(facts)
i.show_facts

