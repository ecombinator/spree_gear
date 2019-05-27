$(document).ready(function(){
  if ($("#simpleList").length > 0) {
    Sortable.create(simpleList, { animation: 150,
      onEnd: function (evt) {
        var itemEl = evt.item;
        var newPositions = [];
        $('#simpleList').addClass("blur-content").children().each( function( index, element ){
          newPositions.push([index + 1, element.getAttribute("category-id")]);
        });

        var searchInput = encodeURIComponent(JSON.stringify(newPositions));
        var searchLink = "/admin/home_categories_list?new_positions=" + searchInput;

        $.ajax({
          type: "POST",
          dataType: 'script',
          url: searchLink
        });
      }
    });

    $('.delete-category').click(function() {
      $('#simpleList').addClass("blur-content");
    });
  }
});
