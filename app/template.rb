copy_file "app/views/shared/_flash.html.erb"
copy_file "app/views/public/home/index.html.erb"
empty_directory_with_keep_file "app/views/admin"

copy_file 'app/controllers/admin/base_controller.rb'
copy_file 'app/controllers/public/base_controller.rb'
copy_file 'app/controllers/public/home_controller.rb'
