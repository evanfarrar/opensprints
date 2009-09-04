class CategoryController < Shoes::Main
  url '/categories', :list
  url '/categories/(\d+)', :show
  url '/categories/new', :new

  def list
    layout
    @center.clear do
      stack(:width => 0.5) {
        button("new category") { visit "/categories/new" }
        Category.all.each {|category|
          separator_line
          flow(:width => 1.0) {
            flow(:width => 0.6, :margin_top => 8) {
              para category.name
            }
            flow(:width => 0.1)
            flow(:width => 0.3) {
              button("delete") { category.destroy; visit '/categories' }
            }
          }
        }
      }
    end
  end

  def new
    layout
    attrs = {}
    @center.clear do
      flow {
        para "name:"
        edit_line('') do |edit|
          attrs[:name] = edit.text
        end
      }
      button "Create" do
        Category.create(attrs)
        visit '/categories'
      end
    end
  end
end
