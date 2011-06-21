module NotificationHelpers
  class AppType
    LOG = 0
    BLOCK = 1
    DELETE = 2
    QUARANTINE = 3
    UNKNOWN = 4
    
    def self.log_name(app_type)
      case app_type
      when AppType::LOG
        "LOG"
      when AppType::BLOCK
        "BLOCK"
      when AppType::DELETE
        "DELETE"
      when AppType::QUARANTINE
        "QUARANTINE"
      else
        "UNKNOWN"
      end
    end
  end
  
  def application_type(notification)
    starting_app = notification.userInfo
    app_name  = notification.userInfo["NSApplicationName"]
    pid       = notification.userInfo["NSApplicationProcessIdentifier"]
    bundleID  = notification.userInfo["NSApplicationBundleIdentifier"]
    path      = notification.userInfo["NSApplicationPath"]

    @app_config.each_value do |app|
      if app["ApplicationBundleID"] == bundleID || app["ApplicationName"] == app_name
        if app["Actions"]["Log"]
          # @logged_apps[pid] = bundleID
          return AppType::LOG
        elsif app["Actions"]["Blocked"]
          return AppType::BLOCK
        elsif app["Actions"]["Remove"]
          return AppType::DELETE
        elsif app["Actions"]["Quarantine"]
          return AppType::QUARANTINE
        end
      end
    end
    AppType::UNKNOWN  
  end

  
  def pause_app(pid)
    NSLog "Pausing Application #{pid}"
    `kill -STOP #{pid}`
  end
  
  def continue_app(pid)
    NSLog "Resuming Application #{pid}"
    `kill -CONT #{pid}`
  end
  
  def kill_app(pid)
    NSLog "Killing Application #{pid}"
    `kill -9 #{pid}`
  end
  
  def log(func, notif, app_type)
    app_name  = notif.userInfo["NSApplicationName"]
    pid       = notif.userInfo["NSApplicationProcessIdentifier"]
    bundleID  = notif.userInfo["NSApplicationBundleIdentifier"]
    path      = notif.userInfo["NSApplicationPath"]
    time = Time.now.strftime("%Y-%m-%d %T")
    log_text = "#{time}\t#{func}\t#{AppType.log_name(app_type)}\t#{app_name}\t#{pid}\t#{bundleID}\t#{path}\n"
    log_path = @prefs[:LogfileLocation].stringByStandardizingPath
    File.open(log_path, 'a') {|f| f.write(log_text) }
  end
  
  def run_alert(text, icon)
    alert = NSAlert.alloc.init
    alert.setMessageText(text)
    alert.addButtonWithTitle("OK")
    alert.setIcon(icon)
    alert.runModal
  end
  
  def get_app_icon(notif)
    if notif.userInfo["NSWorkspaceApplicationKey"].icon
      notif.userInfo["NSWorkspaceApplicationKey"].icon
    else
      app_path = notif.userInfo["NSApplicationPath"]
      icon_path = Hash.dictionaryWithContentsOfFile("#{app_path}/Contents/Info.plist")["CFBundleIconFile"] + ".icns"
      icon_path = app_path + "/Contents/Resources/" + icon_path
      NSImage.alloc.initWithContentsOfFile icon_path
    end
  end
  
  
  def localize(key, val = nil)
    NSBundle.mainBundle.localizedStringForKey(key, value:val, table:nil)
  end
end