class CategoryController < Shoes::Main
  url '/categories', :list
  url '/categories/(\d+)', :show
  url '/categories/new', :new

  def list
    layout
    @center.clear do
      para(link "new category", :click => "/categories/new")
      Category.all.each {|r|
        flow {
          para r.name
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
