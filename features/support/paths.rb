module NavigationHelpers

  def path_to(page_name)
    case page_name
    when '?' then '?'
    else begin
        components = page_name.split(/\s+/)
        self.send(components.push('path').join('_').to_sym)
      rescue
        raise "No mapping found for #{page_name}. Add it manually in #{__FILE__}."
      end
    end
  end

end

World(NavigationHelpers)
