$(document).ready(() => {
  if ($("#category-products").length > 0) {
    let timeout;
    const $keywords = $("#keywords");
    const lookAndSearch = () => {
      const searchInput = $.trim($keywords.val());
      const searchLink = "/admin/home_categories_search";
      if ($keywords.val() === "") return;
      if (searchInput) {
        $.ajax({
          type: "GET",
          dataType: "script",
          url: searchLink,
          data: {
            keywords: searchInput,
            specific_name: $("#specific_name").is(":checked"),
          },
        });
        $("#search-content").addClass("blur-content");
      }
    };

    $keywords.keyup(() => {
      clearTimeout(timeout);
      timeout = setTimeout(() => {
        lookAndSearch();
      }, 2000);
    });

    $keywords.on("keydown", (event) => {
      const x = event.which;
      if (x === 13) {
        event.preventDefault();
        clearTimeout(timeout);
        lookAndSearch();
      }
    });

    // move products on click
    $("#category-area").on("click", ".product-select", () => {
      const productId = $(this).attr("product-id");
      if ($(this).parent().attr("id") === "search-content") {
        $("#no-products").remove();
        const elem = $(this).detach();
        $("#category-products").append(elem);
        $("#category-form").append(
          `<input type="hidden" name="category_product[]" value="${productId}">`
        );
      } else {
        $(this).hide(500, () => {
          const categoryProdId = $(this).attr("home-category-id");
          if (categoryProdId) {
            $.ajax({
              type: "DELETE",
              dataType: "script",
              url: `/admin/category_product?home_category_id=${categoryProdId}&product_id=${$(
                this
              ).attr("product-id")}`,
            });
          }

          $("#category-form").find(`[value=${productId}]`).remove();
          $(this).remove();
        });
      }
    });
  }
});
