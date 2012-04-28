ActionController::Routing::Routes.draw do |map|
  map.resources(:greenmine, :member => { :issue_move => :get } )
  map.resources(:greenmine, :member => { :assign_matrix => :get } )
  map.resources(:greenmine, :member => { :set_assign_matrix => :get } )
end

