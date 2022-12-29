# APPROCHES POSSIBLES :

# 1. Scrapper les events par Venue :
#    Plus simple à gérer, avec les bars déjà existants,
#    Scrappe les évènements pour un seul bar à la fois

# 2. Scrapper tous les events d'un coup :
#    C'est le bordel, faut vérifier pour chaque event si le Venue existe,
#    Le créer si il existe pas, puis créer l'event

# ON VA FAIRE L'OPTION 1 POUR L'INSTANT HEIN

############# !!!! TODO !!!! AJOUTER DES TAGS ###################

# Ruby a besoin du nom des mois en anglais pour parser correctement les dates.
MONTHS = {
  "janvier" => "jan",
  "février" => "feb",
  "mars" => "mar",
  "avril" => "apr",
  "mai" => "may",
  "juin" => "jun",
  "juillet" => "jul",
  "août" => "aug",
  "septembre" => "sep",
  "octobre" => "oct",
  "novembre" => "nov",
  "décembre" => "dec"
}

puts "Scrapping from wik-nantes.fr ..."

# TODO: Faire une boucle avec les venues
# Parce que pour l'instant ça scrappe que les evts du café rouge
venue = Venue.find_by(name: "Le Café Rouge Mécanique")
puts "Scrapping for #{venue.name}..."


page = 0

loop do
  html = URI.open("https://www.wik-nantes.fr/domib44?page=#{page}")
  doc = Nokogiri::HTML(html)

  break puts("Scrapping done for #{venue.name} !") if doc.at('.view-empty')

  events = doc.search(".type-scene")
  events.each do |evt|
    evt_url = evt.search(".views-field a")[0]['href']
    evt_html = URI.open("https://www.wik-nantes.fr#{evt_url}")
    evt_doc = Nokogiri::HTML(evt_html)

    evt_name = evt_doc.at(".ctn-title h1").text.strip
    evt_photo_url = evt_doc.at(".ctn-img img")['src']

    evt_desc = evt_doc.search(".ctn-desc p").each do |p|
      break p.text.strip if p.text.strip.length > 10
    end

    evt_dates = evt_doc.search(".dates li").map { |date| date.text.strip.downcase }
    # Traduit les mois dans les dates avant de les parser en objet DateTime
    evt_dates.map! do |date|
      MONTHS.each { |k, v| break date.gsub!(k, v) if date.include?(k) }
      DateTime.parse(date)
    end

    evt_dates.each do |date|
      # Next si il n'y a pas déjà un evt le même jour au même endroit
      next puts("!!!!! Date conflict on #{evt_name} !!!!!") if Event.where(venue: venue, date: date).any?

      event = Event.new(
        name: evt_name,
        description: evt_desc,
        date: date,
        venue: venue
      )
      file = URI.open(evt_photo_url)
      event.photo.attach(io: file, filename: "#{date.strftime('%Y%m%d')}-#{venue.name.gsub(' ','')}.jpg", content_type: "image/jpg")
      event.confirmed = true
      event.save!
      puts "Added event: #{date.strftime('%Y-%m-%d')} - #{event.name}"
      # Ligne suivante pour vérifier que ça marche bien avec les descriptions
      # puts event.description
    end
  end
  page += 1
end
