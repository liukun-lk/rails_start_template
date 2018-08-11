copy_file 'config/initializers/masquerade.rb' if @devise
copy_file 'config/initializers/sidekiq.rb'
copy_file 'config/initializers/rucaptcha.rb'
copy_file 'config/initializers/i18n.rb'
copy_file 'config/initializers/generators.rb'

template "config/database.yml.tt", force: true

copy_file 'config/routes.rb', force: true
copy_file 'config/routes/admin.rb'
copy_file 'config/routes/public.rb'

copy_file 'config/sidekiq.yml'
copy_file 'config/webpacker.yml'

copy_file 'config/locales/activerecord.cn.yml'
copy_file 'config/locales/devise.cn.yml'
copy_file 'config/locales/responders.cn.yml'

copy_file 'config/yml/sidekiq_redis.yml'

copy_file 'config/environments/development.rb', force: true
copy_file 'config/environments/production.rb', force: true

if apply_capistrano?
  template "config/deploy.rb.tt"
  template "config/deploy/production.rb.tt"
end
