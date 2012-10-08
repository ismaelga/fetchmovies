require 'nokogiri'
require 'open-uri'


module FilmesFetch

end

require './lib/movies_io_fetch_data'
require './lib/movies_io_fetcher_top_movies'



FilmesFetch::MoviesIoFetchTopMovies.new.perform