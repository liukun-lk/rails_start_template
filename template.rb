RAILS_REQUIREMENT = '~> 5.2.0'.freeze

require 'fileutils'
require 'shellwords'

def apply_template!
  assert_minimum_rails_version
  add_template_repository_to_source_path

  template 'Gemfile.tt', force: true

  apply 'app/template.rb'
  apply 'config/template.rb'

  copy_file 'Procfile'
  copy_file 'Capfile' if apply_capistrano?

  install_optional_gems

  after_bundle do
    run 'rails dev:cache'
    run 'rails g rspec:install'
    setup_simple_form

    setup_npm_packages if apply_komponent?
    setup_gems

    run 'bundle binstubs bundler --force'

    run 'rails db:create db:migrate'

    run_rubocop_autocorrections
  end
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    source_paths.unshift(tempdir = Dir.mktmpdir('rails-template-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/liukun-lk/rails_start_template',
      tempdir
    ].map(&:shellescape).join(' ')
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def gemfile_requirement(name)
  @original_gemfile ||= IO.read('Gemfile')
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(,[><~= \t\d\.\w'"]*)?.*$/, 1]
  req && req.tr("'", %(")).strip.sub(/^,\s*"/, ', "')
end

def ask_with_default(question, color, default)
  return default unless $stdin.tty?
  question = (question.split('?') << " [#{default}]?").join
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

def apply_capistrano?
  return @apply_capistrano if defined?(@apply_capistrano)
  @apply_capistrano = \
    ask_with_default('Use Capistrano for deployment?', :yellow, 'no') \
    =~ /^y(es)?/i
end

def apply_devise?
  return @devise if defined?(@devise)
  @devise = \
    ask_with_default('Do you want to implement authentication in your app with the Devise gem?', :yellow, 'no') \
    =~ /^y(es)?/i
end

def apply_pundit?
  return @pundit if defined?(@pundit)
  @pundit = \
    ask_with_default('Do you want to manage authorizations with Pundit?', :yellow, 'no') \
    =~ /^y(es)?/i
end

def apply_komponent?
  return @komponent if defined?(@komponent)
  @komponent = \
    ask_with_default('Do you want to adopt a component based design for your front-end?', :yellow, 'no') \
    =~ /^y(es)?/i
end

def production_hostname
  @production_hostname ||=
    ask_with_default('Production hostname?', :yellow, 'example.com')
end

def install_optional_gems
  add_devise if apply_devise?
  add_pundit if apply_pundit?
  add_komponent if apply_komponent?
end

def add_devise
  insert_into_file 'Gemfile', "gem 'devise'\n", after: /'rucaptcha'\n/
  insert_into_file 'Gemfile', "gem 'devise_masquerade'\n", after: /'rucaptcha'\n/
end

def add_pundit
  insert_into_file 'Gemfile', "gem 'pundit'\n", after: /'rucaptcha'\n/
end

def add_komponent
  insert_into_file 'Gemfile', "gem 'komponent'\n", after: /'rucaptcha'\n/
end

def setup_npm_packages
  add_linters
end

def add_linters
  run 'yarn add eslint babel-eslint eslint-config-airbnb-base eslint-config-prettier eslint-import-resolver-webpack eslint-plugin-import eslint-plugin-prettier lint-staged prettier stylelint stylelint-config-standard --dev'
  copy_file '.eslintrc'
  copy_file '.stylelintrc'
  run 'yarn add normalize.css'
end

def setup_gems
  setup_annotate
  setup_bullet
  setup_rubocop
  setup_komponent if apply_komponent?
  setup_devise if apply_devise?
  setup_pundit if apply_pundit?
  setup_responder
end

def setup_annotate
  run 'rails g annotate:install'
  run 'bundle binstubs annotate'
end

def setup_bullet
  insert_into_file 'config/environments/development.rb', before: /^end/ do
    <<-RUBY
  Bullet.enable = true
  Bullet.alert = true
    RUBY
  end
end

def run_with_clean_bundler_env(cmd)
  success = if defined?(Bundler)
              Bundler.with_clean_env { run(cmd) }
            else
              run(cmd)
            end
  unless success
    puts "Command failed, exiting: #{cmd}"
    exit(1)
  end
end

def run_rubocop_autocorrections
  run_with_clean_bundler_env 'bin/rubocop -a --fail-level A > /dev/null || true'
end

def setup_rubocop
  run 'bundle binstubs rubocop'
  copy_file '.rubocop'
  copy_file '.rubocop.yml'
end

def setup_komponent
  install_komponent
  add_basic_components
end

def install_komponent
  copy_file 'frontend/components/index.js'
  copy_file 'frontend/packs/application.js'
  run 'rails g komponent:install'
  FileUtils.rm_rf 'app/javascript'
  insert_into_file 'config/application.rb', "    config.autoload_paths << config.root.join('frontend/components')", after: /'class Application < Rails::Application'\n/
end

def add_basic_components
  run 'rails g component flash'
  insert_into_file 'app/views/layouts/application.html.erb', "    <%= component 'flash' %>\n", after: /<body>\n/
end

def setup_devise
  run 'rails generate devise:install'
  insert_into_file 'config/initializers/devise.rb', "  config.secret_key = Rails.application.credentials.secret_key_base\n", before: /^end/
  run 'rails g devise User'
  insert_into_file 'app/controllers/application_controller.rb', "  before_action :authenticate_user!\n", after: /exception\n/
end

def setup_pundit
  insert_into_file 'app/controllers/application_controller.rb', before: /^end/ do
    <<-RUBY
    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(root_path)
    end

    private

    def skip_pundit?
      devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
    end
    RUBY
  end
  insert_into_file 'app/controllers/application_controller.rb', after: /exception\n/ do
    <<-RUBY
    include Pundit

    after_action :verify_authorized, except: :index, unless: :skip_pundit?
    after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    RUBY
  end
  run 'spring stop'
  run 'rails g pundit:install'
end

def setup_responder
  run 'rails g responders:install'
  insert_into_file 'config/application.rb', after: /'class Application < Rails::Application'\n/ do
    <<-RUBY
      config.app_generators.scaffold_controller :responders_controller
      config.responders.flash_keys = %i[success warning]
    RUBY
  end
end

def setup_simple_form
  run 'rails generate simple_form:install --bootstrap'
end

run 'pgrep spring | xargs kill -9'

# launch the main template creation method
apply_template!
