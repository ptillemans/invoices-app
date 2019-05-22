
if Rails.env.melexis?
  Rails.application.config.middleware.use "CasAuthentication", "CAS Authentication"
end
