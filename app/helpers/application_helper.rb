module ApplicationHelper

  def title
    base_title = "Ruby on Rails Tutorial Sample App | "
    if @title.nil?
      base_title += "Default"
    else
      base_title += @title
    end
    base_title
  end


  def logo
    image_tag("logo.png", :alt => "Sample App", :class => "round")
  end

end
