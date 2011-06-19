module GorillaHelpers
  def read_prefs(id)
    CFPreferencesAppSynchronize(id)
    pref_keys = CFPreferencesCopyKeyList(id, "kCFPreferencesAnyUser", "kCFPreferencesCurrentHost")
    ret = {}
    pref_keys.each do |key|
      ret[key.to_sym] = CFPreferencesCopyAppValue(key, id)
    end
    ret[:BUNDLE_ID] = id
    ret
  end
end