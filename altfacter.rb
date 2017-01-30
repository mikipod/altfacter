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
        'family' => %w(windows Darwin RedHat Commodore Debian)
      },
      'operatingsystemmajrelease' => %w(XP ME '2012 R2' 2016 7 10 6 5 2000 NT4),
      'timezone' => %w(PST CST UTC EST),
      'filesystem' => %w(xfs zfs ntfs msdos fat32),
      'virtual' => %w(physical vmware),
      'operatingsystem' => %w(windows Darwin CentOS Ubuntu)
    }

    @facts = Facter.to_hash
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
        process_facts(facts[key], altfacts[key])
      elsif value.is_a?(Hash) && !(altfacts[key])
        process_facts(facts[key], @altfacts)
      elsif altfacts[key]
        distort_facts(key, value, facts, altfacts)
      elsif value =~ /^(\d+).(\d+)/ && value =~ /MB|GB$/
        do_ram(key, value, facts)
      elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
        facts[key] = %w(true false).sample
      elsif value =~ /^\d+\.\d\d$/
        facts[key] = rfloat
      elsif value =~ /^\d+\.\d+\.\d+$/
        facts[key] = rsemver
      elsif value =~ /^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$/
        facts[key] = rnetwork
      elsif value =~ /^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/
        do_mac(key, value, facts)
      elsif value.is_a?(Integer) || value.is_a?(String) && inty(value).nonzero?
        facts[key] = rint
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
    '%.2f' % rand(4..256).round(2)
  end

  def rsemver
    rint(10) + '.' + rint(10) + '.' + rint(100)
  end

  def rnetwork
    rint(254) + '.' + rint(254) + '.' + rint(254) + '.' + rint(254)
  end

  def rint(x=99)
    rand(1..x).to_s
  end

  def do_ram(key, value, facts)
    if value =~ /GB$/
      size = 'GB'
    elsif value =~ /MB$/
      size = 'MB'
    end
    tmp = value.tr(size, '').strip
    facts[key] = rfloat + " #{size}" if tmp =~ /^[-+]?[0-9]*\.?[0-9]+$/
    facts[key] = rint + " #{size}" if tmp =~ /^\d+$/
  end

  def distort_facts(key, value, facts, altfacts)
    altfacts[key].delete(value) if altfacts[key].include?(value)
    facts[key] = altfacts[key].sample
  end

  def do_mac(key, value, facts)
    # Gleefully borrowed from https://gist.github.com/jiggneshhgohel/d4d5996207dcf81bef8e
    mac = Array.new(12) { num = (0..15).to_a.sample; num.to_s(16) }.each_slice(2).to_a.map { |arr| arr.join('') }.join(':')
    facts[key] = mac
  end

  def inty(x)
    x.to_i
  rescue
    return 0
  end
  # end of AltFacter class
end

# Begin script
i = AltFacter.new
facts = i.main_facts
altfacts = i.alt_facts
i.process_facts(facts, altfacts)
i.show_facts
