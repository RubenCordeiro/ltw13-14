function getUrlVars() {
    var vars = {};
    window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function (m, key, value) {
        vars[key] = value;
    });
    return vars;
}

function showProductData(data) {
    $(document).attr('title', 'Show Product #' + data.ProductCode);

    $('#ProductCode').attr('value', data.ProductCode);
    $('#ProductDescription').attr('value', data.ProductDescription);
    $('#UnitPrice').attr('value', data.UnitPrice);
}

function showEditableProductData(data) {

    $('._header').text("Edit Product");

    $('input').filter(function (index) {
        return $(this).attr('id') !== 'ProductCode';
    }).removeAttr('readonly').attr('method', 'post').prop('required', true);

    $('div._header').text('Edit product');

    var submissionCallback = function (event) {
        if (event.preventDefault)
            event.preventDefault();
        else
            event.returnValue = false;

        var jsonObj = {
            ProductCode: $('#ProductCode').val(),
            ProductDescription: $("#ProductDescription").val(),
            UnitPrice: $("#UnitPrice").val()
        };

        var requestStr = JSON.stringify(jsonObj);

        $.ajax({
            url: "api/updateProduct.php",
            type: "POST",
            data: {
                product: requestStr
            },
            dataType: "JSON",
            success: function (jsonStr) {
                alert(JSON.stringify(jsonStr));
            }
        });
    };

    showProductData(data);

    $('form').attr('method', 'post').attr('action', 'api/updateProduct.php')
        .append('<input type="submit" id="submit" value="Submit">').submit(submissionCallback);

    $('#ProductDescription').focus();
}

function showBlankProductData(data) {

    $('div._product_code').remove();

    $('input').removeAttr('readonly').prop('required', true).val('');

    $('#ProductDescription').focus();

    var submissionCallback = function (event) {
        // prevent the default form behaviour
        if (event.preventDefault)
            event.preventDefault();
        else
            event.returnValue = false;

        var jsonObj = {
            ProductCode: "",
            ProductDescription: $("#ProductDescription").val(),
            UnitPrice: $("#UnitPrice").val()
        };

        var requestStr = JSON.stringify(jsonObj);

        $.ajax({
            url: "api/updateProduct.php",
            type: "POST",
            data: {
                product: requestStr
            },
            dataType: "JSON",
            success: function (jsonObj) {
                $.ajax({
                    url: "showProduct.php",
                    type: "GET",
                    data: {
                        ProductId: jsonObj
                    },
                    dataType: "text",
                    success: function (jsonObj) {
                    }
                });
            }
        });
    };

    $('form')
        .append('<input id="submit" type="submit" value="Submit">').submit(submissionCallback);

    $('div._header').text('Create new product');
}

function loadProduct() {

    var urlVars = getUrlVars();
    var action = urlVars['action'];

    if (action !== 'create')
    {
        var id = urlVars['ProductCode'];
        if (id == undefined)
            return;
    }
    $.ajax({
        url: "api/user_is_editor.php",
        success: function (is_editor) {

            is_editor = JSON.parse(is_editor);

            var onSuccess = null;
            if (is_editor)
            {
                switch(action)
                {
                    case 'edit':
                    {
                        onSuccess = showEditableProductData;
                        break;
                    }
                    case 'create':
                    {
                        onSuccess = showBlankProductData;
                        break;
                    }
                    case 'show':
                    case undefined:
                    {
                        onSuccess = showProductData;
                        break;
                    }
                }
            }
            else {
                if (action != 'show' && action !== undefined) {
                    alert('Error: permission denied');
                    window.location.replace('index.php');
                }
                else
                    onSuccess = showCustomerData;
            }
            if (onSuccess == null)
                return;

            $.getJSON("api/getProduct.php", {
                ProductCode: decodeURI(id)
            }).done(onSuccess);
        }

    });


}