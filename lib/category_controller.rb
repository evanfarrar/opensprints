class CategoryController < Shoes::Main
  url '/categories', :list
  url '/categories/(\d+)', :show
  url '/categories/new', :new

  def list
    @title = $i18n.setup_categories
    layout(:menu)
    @center.clear do
      stack(:width => 0.5) {
        container
        button($i18n.new_category) { visit "/categories/new" }
        Category.all.each {|category|
          flow(:width => 1.0, :margin_left => 20) {
            separator_line
          }
          flow(:width => 1.0, :margin_left => 20) {
            flow(:width => 0.6, :margin_top => 8) {
              para category.name
            }
            flow(:width => 0.1)
            flow(:width => 0.3) {
              delete_button { category.destroy; visit '/categories' }
            }
          }
        }
      }
    end
  end

  def new
    @title = $i18n.new_category
    layout(:menu)
    attrs = {}
    @center.clear do
      container
      flow {
        para $i18n.name
        edit_line('') do |edit|
          attrs[:name] = edit.text
        end
      }
      button $i18n.create do
        if attrs[:name].blank?
          alert($i18n.name_cant_be_blank)
        elsif Category.first(:name => attrs[:name])
          alert($i18n.name_is_taken)
        else
          Category.create(attrs)
          visit '/categories'
        end
      end
      button $i18n.cancel do
        visit '/categories'
      end
    end
  end
end
