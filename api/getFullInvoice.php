<?php
header("Content-type:application/json");

require_once 'details/user_management.php';
require_once 'details/user.php';

if (!is_logged_in())
    exit('{"error":{"code":403,"reason":"Not authenticated"}}');

require_once 'details/invoice.php';
require_once 'details/product.php';
require_once 'details/customer.php';

$db = new PDO('sqlite:../sql/OIS.db');

$field = 'InvoiceNo';
$error400 = '{"error":{"code":400,"reason":"Bad request"}}';
$error404 = '{"error":{"code":404,"reason":"Invoice not found"}}';

if (!array_key_exists($field, $_GET))
{
    exit($error400);
}

$invoiceNoStr = htmlspecialchars($_GET[$field]);

$invoice = new Invoice;
$error = $invoice->queryDbByNo($invoiceNoStr);
if ($error)
{
    $error = "error" . $error;
    exit($$error);
}

$invoiceArray = $invoice->toArray();

$userId = $invoiceArray['SourceID'];

$user = new User;
$error = $user->queryDbById($userId);
if ($error)
{
    $error = "error" . $error;
    exit($$error);
}

$invoiceArray['Source'] = $user->toArray();
unset($invoiceArray['SourceID']);

$customerId = $invoiceArray['CustomerID'];

$customer = new Customer;
$error = $customer->queryDbById($customerId);
if ($error)
{
    $error = "error" . $error;
    exit($$error);
}

$invoiceArray['Customer'] = $customer->toArray();
unset($invoiceArray['CustomerID']);

foreach ($invoiceArray['Line'] as &$line)
{
    $productId = $line['ProductCode'];
    $product = new Product;
    $error = $product->queryDbById($productId);
    if ($error)
    {
        $error = "error" . $error;
        exit($$error);
    }

    $line['Product'] = $product->toArray();
    unset($line['ProductCode']);
}

echo json_encode($invoiceArray);
