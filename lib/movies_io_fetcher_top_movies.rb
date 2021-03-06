module FilmesFetch
  class MoviesIoFetchTopMovies
    # include Sidekiq::Worker

    def perform
      @url = 'http://movies.io/i/top50'
      @page = Nokogiri.HTML open(@url)
      fetch_top50.each do |movie_url|
        MoviesIoFetchData.new.perform movie_url
      end
    end

  private
    def fetch_top50
      @movies_urls = @page.css('a.goodie').map { |e| "http://movies.io" + e[:href] }
    end
  end
end