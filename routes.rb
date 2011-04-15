ActionController::Routing::Routes.draw do |map|
  map.resources(:greenmine, :member => { :issue_move => :get } )
end

