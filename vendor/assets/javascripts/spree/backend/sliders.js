$(document).ready(function(){
  var addSlide = function() {
    return `<fieldset class="added-slide well-sm">
      <div class="form-group">
        <label for="slider_slides_attributes_${$(".added-slide").length}slider_title">Slider title</label>
        <input type="text" class="form-control"
        name="slider[slides_attributes][${$(".added-slide").length}][title]" id="slider_slides_attributes_${$(".added-slide").length}"
      </div>
      <div class="form-group">
        <label for="slider_slides_attributes_${$(".added-slide").length}_picture">Slider picture</label>
        <input type="file" name="slider[slides_attributes][${$(".added-slide").length}][picture]" class="form-control" id="slider_slides_attributes_${$(".added-slide").length}_picture"
      </div>
    </fieldset>
    <hr>`
  }

  //if in index, add a blur on delete
  if ($("#sliders-list-index").length > 0) {
    $("#sliders-list-index").on('click', '.delete-slider-link', function() {
      $("#sliders-list-index").addClass("blur-content")
    });

    $("#sliders-list-index").on('click', '.blur-slider-list', function() {
      $("#sliders-list-index").addClass("blur-content")
    });
  }
  //for appending forms
  if ($("#slider-form").length > 0) {
    $("#sliders-list-index").on('click', '.delete-slider-link', function() {
      $("#sliders-list-index").addClass("blur-content")
    });

    $(document).on("click", "#add-slide",function() {
      $("#slides-group").append(addSlide());
    });
  }
});


