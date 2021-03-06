module ApplicationHelper

  def nav_link(text, path)
    class_name = current_page?(path) ? 'active' : ''
    content_tag(:li, :class => class_name) do
      link_to text, path
    end
  end

  # Converts given flash type to appropriate CSS class.
  # @return [String] css class
  def flash_for(name)
    case name
    when :notice then ''
    when :error then 'alert'
    when :alert then 'alert'
    when :success then 'success'
    else 'secondary'
    end
  end

  # @see http://encosia.com/3-reasons-why-you-should-let-google-host-jquery-for-you/
  # @return [Array<String>] of URLs to javascript libraries hosted on CDNs.
  def cdn_js
    %w[
      //cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min.js
      //ajax.googleapis.com/ajax/libs/angularjs/1.0.7/angular.min.js
      //cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML
      //code.highcharts.com/highcharts.js
    ]
  end

  def cdn_css
    %w[
      //netdna.bootstrapcdn.com/font-awesome/3.1.1/css/font-awesome.css
    ]
  end

end
