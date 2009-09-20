class CategoryController < Shoes::Main
  url '/categories', :list
  url '/categories/(\d+)', :show
  url '/categories/new', :new

  def list
    layout(:menu)
    @center.clear do
      stack(:width => 0.5) {
        container
        button("new category") { visit "/categories/new" }
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
    layout(:menu)
    attrs = {}
    @center.clear do
      flow {
        para "name:"
        edit_line('') do |edit|
          attrs[:name] = edit.text
        end
      }
      button "Create" do
        if attrs[:name].blank?
          alert("Sorry, name can't be blank")
        else
          Category.create(attrs)
          visit '/categories'
        end
      end
    end
  end
end
