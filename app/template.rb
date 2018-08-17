copy_file "app/views/shared/_aside.html.erb"
copy_file "app/views/shared/_flash.html.erb"
copy_file "app/views/shared/_footer.html.erb"
copy_file "app/views/shared/_header.html.erb"
copy_file "app/views/shared/_nav.html.erb"
copy_file "app/views/public/home/index.html.erb"
copy_file "app/views/layouts/application.html.erb", force: true
empty_directory_with_keep_file "app/views/admin"

copy_file 'app/controllers/admin/base_controller.rb'
copy_file 'app/controllers/public/base_controller.rb'
copy_file 'app/controllers/public/home_controller.rb'

copy_file 'app/helpers/sidebar_helper.rb'

insert_into_file 'app/assets/javascripts/application.js', %Q(//= require coreui-free\n), before: %Q(//= require_tree .)

copy_file 'app/assets/stylesheets/application.scss'
remove_file 'app/assets/stylesheets/application.css'
copy_file 'app/assets/stylesheets/_custom-variables.scss'
