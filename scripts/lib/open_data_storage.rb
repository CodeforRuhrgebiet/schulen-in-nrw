class OpenDataStorage
  def self.calc_coordinates(east, north)
    # puts "=> getting coordinates.. (Rechtswert:#{east}, Hochwert:#{north})"
    east = east.to_s[0...7]
    north = north.to_s[0...7]
    output = []
    p = IO.popen("python #{@@project_root}/scripts/calc_coordinates.py #{east} #{north}")
    p.each { |line| output << line.chomp }
    p.close
    {lat: output[0].to_f, long: output[1].to_f}
  end

  # Instance Methods
  def initialize
    @storage_dir = "#{@@project_root}/scripts/.opendata"
    @requirements = [
      {
        url: 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_rechtsform.xml',
        local: 'key_rechtsform.xml'
      },
      {
        url: 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_schulformschluessel.xml',
        local: 'key_schulformschluessel.xml'
      },
      {
        url: 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_traeger.xml',
        local: 'key_traeger.xml'
      },
      {
        url: 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/key_schulbetriebsschluessel.xml',
        local: 'key_schulbetriebsschluessel.xml'
      },
      {
        url: 'https://www.schulministerium.nrw.de/BiPo/OpenData/Schuldaten/schuldaten.xml',
        local: 'schuldaten.xml'
      },
      {
        url: 'http://www.fa-technik.adfc.de/code/opengeodb/PLZ.tab',
        local: 'PLZ.tab'
      }
    ]

    @rechtsformen = false
    parse_rechtsformen!

    @schulformen = false
    parse_schulformen!

    @schultraeger = false
    parse_schultraeger!

    @schulbetriebe = false
    parse_schulbetriebe!

    @computer_class_schools = false
    parse_computer_class_schools!

    # @city_postcodes = {}
    # @postcode_schools = {}
    # map_schools_to_postcodes!

    @schools = []
    set_all_schools!
  end

  def fetch_all_requirements!
    @requirements.each_with_index do |requirement, i|
      puts "Fetching #{i + 1}/#{@requirements.size}"
      url = requirement[:url]
      dest_path = [@storage_dir, requirement[:local]].join('/')
      puts "=> writing #{dest_path} ..."
      File.open(dest_path, 'wb') do |saved_file|
        open(url, 'rb') do |read_file|
          saved_file.write(read_file.read)
        end
      end
    end
  end

  def process_data!
    map_postcodes_to_city!
  end

  def read_file(name)
    File.read([@storage_dir, name].join('/'))
  end

  def rechtsform_by_key(key)
    #@rechtsformen[key]
    case key
      when '1'
        'öffentlich'
      when "2"
        'privat'
      else
        puts 'unbekannt'
    end
  end

  def schulform_by_key(key)
    @schulformen[key]
  end

  def schultraeger_by_key(key)
    @schultraeger[key]
  end

  def schulbetrieb_by_key(key)
    @schulbetriebe[key]
  end

  def computer_class_school_keys
    @computer_class_schools
  end

  def all_schools
    @schools
  end

  private

  # Setter
  def parse_rechtsformen!
    rechtsformen = {}
    raw = read_file('key_rechtsform.xml')
    doc = Nokogiri::XML(raw)
    doc.search('//Rechtsform').each do |rechtsform|
      rechtsformen["#{rechtsform.css("Schluessel").children.text}"] = rechtsform.css("Bezeichnung").children.text
    end

    @rechtsformen = rechtsformen
  end

  def parse_schulformen!
    schulformen = {}
    raw = read_file('key_schulformschluessel.xml')
    doc = Nokogiri::XML(raw)
    doc.search('//Schulform').each do |schulform|
      schulformen["#{schulform.css("Schluessel").children.text}"] = schulform.css("Bezeichnung").children.text
    end

    @schulformen = schulformen
  end

  def parse_schultraeger!
    schultraeger_list = {}
    raw = read_file('key_traeger.xml')
    doc = Nokogiri::XML(raw)
    doc.search('//Traeger').each do |schultraeger|
      schultraeger_list["#{schultraeger.css("Traegernummer").children.text}"] = schultraeger.css("Traegerbezeichnung_1").children.text
    end

    @schultraeger = schultraeger_list
  end

  def parse_schulbetriebe!
    schulbetriebe = {}
    raw = read_file('key_schulbetriebsschluessel.xml')
    doc = Nokogiri::XML(raw)
    doc.search('//Schulbetrieb').each do |schulbetrieb|
      schulbetriebe["#{schulbetrieb.css("Schluessel").children.text}"] = schulbetrieb.css("Bezeichnung").children.text
    end

    @schulbetriebe = schulbetriebe
  end

  def parse_computer_class_schools!
    computer_class_schools = {}
    raw = read_file('informatik_angebot.txt')

    @computer_class_schools = raw.split(",")
  end

  def set_all_schools!
    raw = read_file('schuldaten.xml')
    doc = Nokogiri::XML(raw)
    xml_schools = doc.search('//Schule')
    count = xml_schools.size
    xml_schools.each_with_index do |school, index|
      puts "School #{index}/#{count}"
      s = School.new(self, school)
      @schools.push(s.as_feature)
    end
  end
end
