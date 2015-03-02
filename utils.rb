def http_methods
  {
    get:'GET',
    post:'POST',
    put:'PUT',
    patch:'PATCH',
    del:'DELETE',
    options:'OPTIONS'
  }
end

def partial(path)
  Haml::Engine.new(File.read(path)).render
end
