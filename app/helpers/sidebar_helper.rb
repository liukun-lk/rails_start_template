# frozen_string_literal: true

module SidebarHelper
  def nav_items
    items = [
      { title: 'Colors', icon: :drop, path: '#' },
      { title: 'Base', icon: :puzzle, children: [
        { title: 'Breadcrumb', path: '#' },
        { title: 'Cards', path: '#' }
      ] }
    ]
    active(items)
  end

  private

  def active(items)
    items.map do |item|
      if item[:children]
        item[:path] = '#'
        item[:klass] = :open if item[:children].any? { |child| child[:klass] == :active }
      elsif item[:path].to_s == current_path
        item[:klass] = :open
      end
      item
    end
  end

  def current_path
    @current_path ||=
      begin
        url_for(params.slice(:controller).to_unsafe_h)
      rescue
        url_for(params.slice(:controller, :action).to_unsafe_h)
      end
  end
end
