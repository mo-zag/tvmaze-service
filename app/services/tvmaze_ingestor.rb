class TvmazeIngestor
  API_URL = ENV.fetch('TVMAZE_API_URL', 'https://api.tvmaze.com/schedule/web').freeze
  
    def self.run(date: Date.today)
      new(date).ingest
    end
  
    def initialize(date)
      @date = date
      @episodes_data = fetch_schedule
    end
  
    def ingest
      @episodes_data.each do |episode_data|
        show_data = episode_data.dig('_embedded', 'show')
        next unless show_data
  
        show = find_or_create_show(show_data)
        next unless show
  
        create_or_update_episode(episode_data, show)
      end
    end
  
    private
  
    def fetch_schedule
      response = Net::HTTP.get_response(URI("#{API_URL}?date=#{@date}"))
      raise "TVmaze API error: #{response.code}" unless response.is_a?(Net::HTTPSuccess)
  
      JSON.parse(response.body)
    end
  
    def find_or_create_country(country_data)
      return unless country_data
  
      Country.find_or_create_by!(code: country_data['code']) do |country|
        country.name = country_data['name']
        country.timezone = country_data['timezone']
      end
    end
  
    def find_or_create_network(network_data)
        return nil unless network_data
      
        country_data = network_data['country']
        country = find_or_create_country(country_data) if country_data
      
        Network.find_or_create_by!(tvmaze_id: network_data['id']) do |network|
          network.name = network_data['name']
          network.official_site = network_data['officialSite']
          network.timezone = network_data.dig('country', 'timezone') || network_data['timezone']
          network.country = country
        end
      end
  
    def find_or_create_show(show_data)
      network_data = show_data['network'] || show_data['webChannel']
      network = find_or_create_network(network_data)
  
      show = Show.find_or_initialize_by(tvmaze_id: show_data['id'])
      show.assign_attributes(
        name: show_data['name'],
        show_type: show_data['type'],
        language: show_data['language'],
        status: show_data['status'],
        runtime: show_data['runtime'],
        premiered: show_data['premiered'],
        ended: show_data['ended'],
        official_site: show_data['officialSite'],
        summary: show_data['summary'],
        image_url: show_data.dig('image', 'original'),
        weight: show_data['weight'],
        rating: show_data.dig('rating', 'average'),
        network: network,
        tvmaze_updated_at: show_data['updated']
      )
      show.save!
  
      find_or_create_genres(show, show_data['genres'])
  
      show
    end
  
    def find_or_create_genres(show, genre_names)
      genre_names.each do |name|
        genre = Genre.find_or_create_by!(name: name)
        ShowGenre.find_or_create_by!(show: show, genre: genre)
      end
    end
  
    def create_or_update_episode(episode_data, show)
      episode = Episode.find_or_initialize_by(tvmaze_id: episode_data['id'])
  
      episode.assign_attributes(
        show: show,
        name: episode_data['name'],
        season: episode_data['season'],
        number: episode_data['number'],
        episode_type: episode_data['type'],
        airdate: episode_data['airdate'],
        airtime: episode_data['airtime'],
        airstamp: episode_data['airstamp'],
        runtime: episode_data['runtime'],
        summary: episode_data['summary'],
        image_url: episode_data.dig('image', 'original'),
        rating: episode_data.dig('rating', 'average')
      )
  
      episode.save!
    end
  end
  