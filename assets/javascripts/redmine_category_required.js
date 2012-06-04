document.observe('dom:loaded', function() {
  var cat_select = $('issue_category_id');
  if (cat_select === null){
    return
  }
  var label = cat_select.siblings()[0];
  var required = (new Element("span", {class: "required"})).update(' *');
  label.appendChild(required);
});

