require 'nokogiri'
require 'open-uri'


class MoviesIoFetchData
  # include Sidekiq::Worker

  def perform(url)
    puts 'Doing hard work ---> ' + url
    @url = url
    @page = Nokogiri.HTML open(@url)
  end

private
  def cabecalho
  	cabecalho = @page.css('.movie_headline')
  	@titulo = cabecalho.css('.movie_title').first.content
  	@ano = cabecalho.css('.movie_year a').first.content
  	@duracao = cabecalho.css('.movie_runtime').first.content
  end

  def informacao
  	info = @page.css('.movie_info')
  	@descricao = info.css('.trailer_complement .movie_plot').first['data-full-plot']
  	@rating = info.css('.movie_rating .movie_rating_value').first.content
  end

  def downloads
  	dowloads = @page.css('.sources table')
  	@downloads = downloads.first.children.map do |downloa_line|
  		download_data = {}
  		download_data.tap do |d|
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