function load(activeSeparator) {
    $('#pageHeader').load("header.php", function () {
        $('.selected').removeClass('selected');
        $('#' + activeSeparator).addClass('selected');
    });

    $('.doc_fields').hide();
    $('#op_search_list').hide();
    $('._field_search').hide();
    $('#field1').val('');
    $('#field2').val('').prop('required', false);
    $('#between_span').hide();
    $('#search_button').hide();

    $('#document_search_select').change(function () {
        $('.doc_fields').hide();
        $('#op_search_list').hide();
        $('._field_search').hide();
        $('#between_span').hide();
        $('#search_button').hide();

        if ($(this).val() !== 'none') {
            $('#' + $(this).val()).show();
            $('#op_search_list').show();
            $('#field1_search_list').show();
            $('#search_button').show();
            onChangeFunction();
        }
    });

    var onChangeFunction = function () {
        $('#field1_search_list').show();
        $('#field1').val('').prop('required', true);
        $('#field2_search_list').hide();
        $('#field2').val('').prop('required', false);
        $('#between_span').hide();
        if ($('#op_search_select').val() === 'range') {
            $('#field2_search_list').show();
            $('#between_span').show();
            $('#field2').prop('required', true);
        } else if ($('#op_search_select').val() === 'minvalue' || $('#op_search_select').val() === 'maxvalue') {
            $('#field1_search_list').hide();
            $('#field1').prop('required', false);
        }
    };

    $('#op_search_select').change(onChangeFunction);
}

function search() {
    var op = $('#op_search_select').val();

    var field = '';
    var doc = '';
    switch ($('#document_search_select').val()) {
    case 'customer_field_search_list':
        field = $('#customer_field_search_select').val();
        doc = 'customer';
        break;
    case 'product_field_search_list':
        field = $('#product_field_search_select').val();
        doc = 'product';
        break;
    case 'invoice_field_search_list':
        field = $('#invoice_field_search_select').val();
        doc = 'invoice';
        break;
    }

    var value1 = $('#field1').val();
    var value2 = $('#field2').val();

    var getRequest = {};
    if (value2 === undefined || value2.length === 0)
        getRequest = {
            'doc': doc,
            'op': op,
            'field': field,
            'value[]': value1
        };
    else
        getRequest = {
            'doc': doc,
            'op': op,
            'field': field,
            'value[]': [value1, value2]
        };

    var arr = {
        'invoice': {
            'api': 'searchInvoicesByField.php',
            'detailsHtml': 'showInvoice.php',
            'printHtml': 'printInvoice.php',
            'tableHeader': ['Number', 'Date', 'Client Code', 'Total Amount'],
            'key': 'InvoiceNo',
            'jsonFields': ['InvoiceNo', 'InvoiceDate', 'CustomerID', {
                'DocumentTotals': 'GrossTotal'
            }],
            'fields': ['InvoiceNo', 'InvoiceDate', 'CompanyName', 'GrossTotal']
        },
        'product': {
            'api': 'searchProductsByField.php',
            'detailsHtml': 'showProduct.php',
            'hasPrint': false,
            'tableHeader': ['Product Code', 'Description'],
            'key': 'ProductCode',
            'jsonFields': ['ProductCode', 'ProductDescription'],
            'fields': ['ProductCode', 'ProductDescription']
        },
        'customer': {
            'api': 'searchCustomersByField.php',
            'detailsHtml': 'showCustomer.php',
            'hasPrint': false,
            'tableHeader': ['Customer Id', 'Company Name'],
            'key': 'CustomerID',
            'jsonFields': ['CustomerID', 'CompanyName'],
            'fields': ['CustomerID', 'CustomerTaxID', 'CompanyName']
        }
    }

    var ops = ['range', 'equal', 'contains', 'min', 'max', 'minvalue', 'maxvalue'];

    $.getJSON('api/' + arr[doc].api, getRequest)
        .done(function (data) {

            $.ajax({
                url: "api/user_is_editor.php",
                success: function (is_editor) {
                    is_editor = JSON.parse(is_editor);

                    $('.search_results').empty();
                    $('.search_results').append('<table id="search_results_table"><tr id="header"></tr></table>');

                    for (var i = 0; i < arr[doc].tableHeader.length; ++i) {
                        $('#header').append('<th>' + arr[doc].tableHeader[i] + '</th>');
                    }

                    $('#header').append('<th>Details</th>');
                    if (arr[doc].printHtml)
                        $('#header').append('<th>Print</th>');

                    for (var i = 0; i < data.length; ++i) {
                        $('#search_results_table').append('<tr>');
                        for (var j = 0; j < arr[doc].jsonFields.length; ++j) {
                            if (typeof arr[doc].jsonFields[j] === 'object') {
                                for (var key in arr[doc].jsonFields[j]) {
                                    $('#search_results_table tbody').append('<td>' + data[i][key][arr[doc].jsonFields[j][key]] + '</td>');
                                }
                            } else {
                                $('#search_results_table tbody').append('<td>' + data[i][arr[doc].jsonFields[j]] + '</td>');
                            }
                        }

                        $('#search_results_table tbody').append('<td><a target="_blank" href="' + arr[doc].detailsHtml + '?' + arr[doc].key + '=' + data[i][arr[doc].key] + '"><img src="images/glyphicons_195_circle_info.png" title="more info" width="20" height="20"></a>' +
                            (is_editor ? ' <a target="_blank" href="' + arr[doc].detailsHtml + '?' + arr[doc].key + '=' + data[i][arr[doc].key] + '&action=edit"><img src="images/glyphicons_150_edit.png" title="edit" width="20" height="20"></a>' : '') +
                            '</td>');

                        if (arr[doc].printHtml) {
                            $('#search_results_table tbody').append('<td><a target="_blank" href="' + arr[doc].printHtml + '?' + arr[doc].key + '=' + data[i][arr[doc].key] + '"><img src="images/glyphicons_015_print.png" title="print" width="20" height="20"></a></td>');
                        }

                        $('#search_results_table').append('</tr>');
                    }

                }});
        });
}

function loadSearch() {

    //update the index header with the newly selected option
    $('.selected').removeClass('selected');
    $('#separator2').addClass('selected');

    // remove contents from the document information area
    $("._info_block").empty();

    // load the about.php page
    $("._info_block").load("search.php");
    load();
}

function loadAbout() {

    //update the index header with the newly selected option
    $('.selected').removeClass('selected');
    $('#separator4').addClass('selected');

    // remove contents from the document information area
    $("._info_block").empty();

    // load the about.php page
    $("._info_block").load("about.php");
}
