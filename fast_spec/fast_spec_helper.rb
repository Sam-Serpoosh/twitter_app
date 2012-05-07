Dir[File.expand_path(File.dirname(__FILE__) + '/../app/domain_modules/*.rb')].each { |f| require f }
