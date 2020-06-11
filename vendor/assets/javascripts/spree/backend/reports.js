(function ($) {
  let table;
  const updateUI = function () {
    $("input.date-range").each(function () {
      const $this = $(this);
      const val = $this.val();

      $this
        .daterangepicker({
          locale: {
            format: "YYYY-MM-DD",
            cancelLabel: "Clear",
          },
        })
        .on("apply.daterangepicker", function (ev, picker) {
          table.ajax.reload();
        })
        .on("cancel.daterangepicker", function (ev, picker) {
          $(this).val("");
          table.ajax.reload();
        });
      if (val === "") {
        $this.val("");
      }
    });

    $("input#paid_only").on("click", function () {
      table.ajax.reload();
    });
    $(".value-category").on("click", function () {
      const $closestDropdown = $(this).closest(".dropdown");
      $closestDropdown.find(".value-name").html($(this).attr("value"));
      $closestDropdown.find(".value-area").attr("value", $(this).attr("value"));
      if ($closestDropdown.find(".value-area").attr("value") === "") {
        $closestDropdown.find(".value-name").html("Default");
      }
      table.ajax.reload();
    });
  };

  const loadLineItemsTable = function () {
    table = $("#line-item-report-table")
      .DataTable({
        processing: true,
        serverSide: true,
        bFilter: true,
        pagingType: "full_numbers",
        order: [[2, "desc"]],
        ajax: {
          data(d) {
            d.category = $("#category").attr("value");
            d.completed_at_range = $('input[name="completed_at_range"]').val();
            d.paid_at_range = $('input[name="paid_at_range"]').val();
            d.shipped_at_range = $('input[name="shipped_at_range"]').val();
            d.paid_only = $('input[name="paid_only"]')[0].checked;
          },
        },
        columns: [
          { data: "product_name" },
          { data: "taxon_name" },
          { data: "number" },
          { data: "completed_at" },
          { data: "payment_state", orderable: false, className: "text-center" },
          {
            data: "shipment_state",
            orderable: false,
            className: "text-center",
          },
          { data: "adjustment_total", className: "text-right" },
          { data: "pre_tax_amount", className: "text-right" },
          { data: "cost_price", className: "text-right" },
          { data: "payment_amount", orderable: false, className: "text-right" },
          { data: "profit_amount", orderable: false, className: "text-right" },
        ],
      })
      .on("xhr", function () {
        const json = table.ajax.json();
        const api = table;
        const { column_totals } = json;

        $(table.column(6).header()).html(
          `Adj. <br><b>${column_totals.adjustment_total}</b>`
        );
        $(table.column(7).header()).html(
          `Total <br><b>${column_totals.pre_tax_total}</b>`
        );
        $(table.column(8).header()).html(
          `Cost <br><b>${column_totals.cost_total}</b>`
        );
        $(table.column(9).header()).html(
          `Payment <br><b>${column_totals.payment_total}</b>`
        );
        $(table.column(10).header()).html(
          `Profit <br><b>${column_totals.profit_total}</b>`
        );
      });
    updateUI();
  };

  const loadOrdersTable = function () {
    table = $("#order-report-table")
      .DataTable({
        processing: true,
        serverSide: true,
        bFilter: true,
        pagingType: "full_numbers",
        order: [[2, "desc"]],
        ajax: {
          data(d) {
            d.category = $("#category").attr("value");
            d.completed_at_range = $('input[name="completed_at_range"]').val();
            d.paid_at_range = $('input[name="paid_at_range"]').val();
            d.shipped_at_range = $('input[name="shipped_at_range"]').val();
            d.paid_only = $('input[name="paid_only"]')[0].checked;
          },
        },
        columns: [
          { data: "product_id", orderable: false },
          { data: "number" },
          { data: "completed_at" },
          { data: "email" },
          { data: "referrer", orderable: false },
          { data: "wholesaler", orderable: false },
          { data: "total" },
          { data: "ship_total", orderable: false },
          { data: "adjustment_total" },
          { data: "promo_total" },
          { data: "additional_tax_total" },
          { data: "order_paid", orderable: false },
          { data: "paid_max", orderable: false },
          { data: "payment_total" },
          { data: "shipment_state", orderable: false },
          { data: "shipped", orderable: true },
        ],
      })
      .on("xhr", function () {
        const json = table.ajax.json();
        const api = table;
        const { column_totals } = json;

        $(table.column(6).header()).html(
          `Total <br><b>${column_totals.order_total}</b>`
        );
        $(table.column(7).header()).html(
          `&Sigma; Ship <br><b>${column_totals.shipping_total}</b>`
        );
        $(table.column(8).header()).html(
          `Adj. <br><b>${column_totals.adjustment_total}</b>`
        );
        $(table.column(9).header()).html(
          `Promo <br><b>${column_totals.promo_total}</b>`
        );
        $(table.column(10).header()).html(
          `Tax <br><b>${column_totals.additional_tax_total}</b>`
        );
        $(table.column(13).header()).html(
          `Payment Sum <br><b>${column_totals.payment_total}</b>`
        );
      });
    updateUI();
  };

  const loadMonthlyReportsTable = function () {
    table = $("#monthly-sales-report-table")
      .DataTable({
        processing: true,
        serverSide: true,
        bFilter: false,
        bPaginate: false,
        ajax: {
          data(d) {},
        },
        columns: [
          { data: "name" },
          { data: "past_30_days", orderable: false },
          { data: "month_1", orderable: false },
          { data: "month_2", orderable: false },
          { data: "month_3", orderable: false },
        ],
      })
      .on("xhr", function () {
        const json = table.ajax.json();
        const api = table;
        const { column_totals } = json;

        $(table.column(1).header()).html(
          `Past 30 days <br><b>${column_totals.past_30_days}</b>`
        );
        for (let n = 1; n <= 3; n++) {
          const monthName = $(`#th-month-${n}`).data("month-name");
          $(table.column(1 + n).header()).html(
            `${monthName}<br><b>${column_totals[`month_${n}`]}</b>`
          );
        }
      });
    updateUI();
  };

  const ready = function () {
    if ($("#order-report-table").length > 0) {
      loadOrdersTable();
    }
    if ($("#line-item-report-table").length > 0) {
      loadLineItemsTable();
    }

    $(".tr-taxon").click(function () {
      const taxonId = $(this).data("taxonId");
      console.log(`tr.taxon-${taxonId}`);

      $(`tr.taxon-${taxonId}`).toggleClass("collapse");
    });
  };

  $(document).ready(ready);
})($);
