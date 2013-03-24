module NavigationHelpers

  def path_to(page_name)
    case page_name
    when '?' then '?'
    when /^the (.+) page$/
      components = $1.split(/\s+/)
      self.send(components.push('path').join('_').to_sym)
    end
  rescue
    raise "No mapping found for #{page_name}. Add it manually in #{__FILE__}."
  end

end

World(NavigationHelpers)
