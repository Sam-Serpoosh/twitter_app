module PagesHelper

  def title
    base_title = "Ruby on Rails Tutorial Sample App | "
    if @title.nil?
      base_title += "Default"
    else
      base_title += @title
    end
    base_title
  end

end
