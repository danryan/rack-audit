module Rack
  class Audit
    
    
    AUDIT_LOG = Rails.root.join('log', 'audit.log')
    FileUtils.touch(AUDIT_LOG) unless File.exist?(AUDIT_LOG)
    
    def initialize(app, options = {})
      @app     = app
      @options = options
    end
    

    def call(env)
      status, headers, response = @app.call(env)
      return [status, headers, response] unless env['rack.audit']
      
      remote_ip = env['action_dispatch.remote_ip']
      controller = env['action_dispatch.request.path_parameters'][:controller]
      action = env['action_dispatch.request.path_parameters'][:action]
      timestamp = Time.now.strftime('%Y%m%d%H%M%S')
      
      ::File.open(AUDIT_LOG, 'ab') do |file|
        file.puts("#{timestamp} - #{remote_ip} accessed #{controller}##{action}")
      end      
      response = @app.call(env)
    end
  end
end

