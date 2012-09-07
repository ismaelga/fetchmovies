require 'nokogiri'
require 'open-uri'

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









# ------------------------------------------------------------------------
# ------------------------------------------------------------------------


class MoviesIoFetchData
  # include Sidekiq::Worker

  def perform(url)
    puts 'Doing hard work ---> ' + url
    @url = url
    @page = Nokogiri.HTML open(@url)

    scrab_cebecalho
    scrab_informacao
    scrab_downloads
    save_to_db
  end

private
  def scrab_cebecalho
  	cabecalho = @page.css('.movie_headline')
  	@titulo = cabecalho.css('.movie_title').first.content
  	@ano = cabecalho.css('.movie_year a').first.content
  	@duracao = cabecalho.css('.movie_runtime').first.content
  end

  def scrab_informacao
  	info = @page.css('.movie_info')
  	@descricao = info.css('.trailer_complement .movie_plot').first['data-full-plot']
  	@rating = info.css('.movie_rating .movie_rating_value').first.content
  end

  def scrab_downloads
  	downloads = @page.css('.sources table')
  	@downloads = downloads.first.children.map do |download_line|
  		download_data = {}
  		download_data.tap do |d|
        dl = download_line.css('.download-link-container a')
        if dl.any?
  			   d[:torrent_link] = download_line.css('.download-link-container a').first[:href]
  			   d[:file_quality] = download_line.css('.qu span').first.content
  			   d[:file_size] = download_line.css('.si').first.content
  			   d[:seeders] = download_line.css('.se').first.content
  			   d[:seeders] = download_line.css('.le').first.content
  			   d[:legendas] = download_line.css('.sub a').first[:href]
         end
  		end
  	end
  end

  def save_to_db
    # TODO
    imprime
  end

  def imprime
    puts '------------------------------------------------------------'
    puts @titulo
    puts @ano
    puts @duracao
    puts ''
    puts @rating

    puts '______________________'
    @downloads.each {|d| puts "#{d[:file_quality]} - #{d[:file_size]}"}
    puts '______________________'

    puts '------------------------------------------------------------'
  end
end



MoviesIoFetchTopMovies.new.perform