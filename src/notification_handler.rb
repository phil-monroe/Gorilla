require 'notification_helpers'

class NotificationHandler
  include NotificationHelpers
  # Initializations
  def initialize(prefs)
    @prefs = prefs
    config_file_path = prefs[:ApplicationManifestLocation].stringByStandardizingPath
    NSLog "Application Config Path: #{config_file_path}"
    @app_config = Hash.dictionaryWithContentsOfFile(config_file_path)
    if @app_config == nil
      exit
    end
  end
  
  
  
  
  def will_launch_application(notification)
    app_name  = notification.userInfo["NSApplicationName"]
    bundle_id = notification.userInfo["NSApplicationBundleIdentifier"]
    pid       = notification.userInfo["NSApplicationProcessIdentifier"]
    if app_name == "Gorilla" && bundle_id == "com.primates.gorilla"
      return
    end
    pause_app(pid)
    app_type = application_type(notification)
    
    case app_type
    when AppType::LOG
      continue_app(pid)
      
    when AppType::BLOCK
      kill_app(pid)
      run_alert("#{app_name} is a blocked application.", get_app_icon(notification))
      
    when AppType::DELETE
      kill_app(pid)
      `rm -rf #{notification.userInfo["NSApplicationPath"].stringByStandardizingPath}`
      run_alert("#{app_name} is a blocked application and will be uninstalled.", get_app_icon(notification))
      
      # Localization apps      
    when AppType::QUARANTINE
      kill_app(pid)      
    else
      continue_app(pid)
    end
    
    if app_type != AppType::UNKNOWN or @prefs[:LoggingLevel] == 1
      log("will_launch_app", notification, app_type)
    end
  end
  
  
  
  def did_launch_application(notification)
    app_type = application_type(notification)
    if app_type == AppType::LOG 
      log("did_launch_app", notification, app_type)
    end
  end
  
  
  
  
  def did_terminate_application(notification)
    app_type = application_type(notification)
    if app_type == AppType::LOG 
      log("terminated_app", notification, app_type)
    end
  end
  
  
  
  def will_analalyze_stats(notification)
    
    
  end

end