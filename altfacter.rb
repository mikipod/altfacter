require 'json'
require 'facter'
require 'pp'
# require 'random'
# Facter API - http://www.rubydoc.info/gems/facter/2.4.6/Facter
class AltFacter
  def initialize
    @altfacts = {
      'architecture' => %w(x86 x86_64 8086),
      'kernel' => %w(windows Darwin Linux Solaris),
      'os' => {
        'name'   => %w(windows Darwin CentOS amiga c64),
        'family' => %w(windows Darwin RedHat Commodore)
      },
      'operatingsystemmajrelease' => %w(XP ME '2012 R2' 2016 7 10 6 5 2000 NT4),
      'timezone' => %w(PST CST UTC EST),
      'filesystem' => %w(xfs zfs ntfs msdos fat32),
      'virtual' => %w(physical vmware),
    }

    @facts = Facter.to_hash
    @fact_keys = Facter.list
  end

  def main_facts
    @facts
  end

  def alt_facts
    @altfacts
  end

  def process_facts(facts, altfacts)
    facts.each do |key, value|
      if value.is_a?(Hash) && altfacts[key]
        process_facts(facts[key],altfacts[key])
      elsif value.is_a?(Integer)
        facts[key] = rint
      elsif value =~ /^[-+]?[0-9]*\.?[0-9]+$/
        facts[key] = rfloat
      elsif value =~ /^(?:(\d+)\.)?(?:(\d+)\.)?(\*|\d+)$/
        facts[key] = rsemver
      elsif value =~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
        facts[key] = rnetwork
      elsif value =~ /^(\d+).(\d+)/ && value =~ /MB|GB$/
        do_ram(key, value)
      elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
        facts[key] = %w(true false).sample
      elsif altfacts[key]
        distort_facts(key, value, facts, altfacts)
      end
    end
  end

  def show_facts
    args = ARGV
    args.delete(__FILE__)
    if args.empty?
      pp @facts
      'moo'
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

  def distort_facts(key, value, facts, altfacts)
    altfacts[key].delete(value) if altfacts.include?(value)
    facts[key] = altfacts[key].sample
  end

  def do_hash(blah)
    "i'm here bro #{blah}"
  end
  # end of AltFacter class
end

# Begin script
i = AltFacter.new
facts = i.main_facts
altfacts = i.alt_facts
i.process_facts(facts, altfacts)
i.show_facts
