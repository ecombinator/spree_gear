(() => {
  const ready = function () {
    const $inputs = $(".adjustment-input");

    if ($inputs.length === 0) return;
    $(document).on("change", ".adjustment-input", (ev) => {
      const input = $(ev.target);
      const form = input.closest("form");
      let value = input.val();
      const min = parseInt(input.attr("min"), 0);
      if (value < min) {
        input.val(min);
        value = min;
      }
      const label = value >= 0 ? "Add Stock" : "Remove Stock";
      const button = $("input[type=submit]", form);

      button.val(label);
    });
  };

  $(document).ready(ready);
}).call(this);
