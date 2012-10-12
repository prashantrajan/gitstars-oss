class ConnectionReloader

  def self.disconnect!
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.connection.disconnect!
      Rails.logger.info('Disconnected from ActiveRecord')
    end
  end

  def self.connect!
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.establish_connection
      Rails.logger.info('Connected to ActiveRecord')
    end
  end

end
