<?php
header("Content-type:application/json");

require_once 'details/user_management.php';

if (!is_logged_in())
    exit('{"error":{"code":403,"reason":"Not authenticated"}}');

require_once 'details/invoice.php';
require_once 'details/utils.php';

$error400 = '{"error":{"code":400,"reason":"Bad request"}}';

function ConvertIfNeeded($fieldInUse, $operation, $value)
{
    if ($fieldInUse == "GrossTotal")
       $value = strval($value);

    if ($operation == "contains")
        return "%" . $value . "%";

    return $value;
}

function ParseValue($fileInUse, $operation, &$value)
{
    if ($fileInUse == "InvoiceNo" && $operation != "contains")
    {
        $error = parseInvoiceNoFromString($value, $value);
        if ($error) return $error;
    }

    return 0;
}

$param_type = [
    "InvoiceNo" => PDO::PARAM_INT,
    "InvoiceDate" => PDO::PARAM_STR,
    "CompanyName" => PDO::PARAM_STR,
    "GrossTotal" => PDO::PARAM_STR
];

function GetValidParamType($fieldInUse, $operation)
{
    global $param_type;
    if ($operation == "contains" && $fieldInUse == "InvoiceNo") return PDO::PARAM_STR;
    return $param_type[$fieldInUse];
}

$queries = [
    "InvoiceNo" => [
        "range" => "SELECT id FROM invoice WHERE id BETWEEN :min AND :max",
        "equal" => "SELECT id FROM invoice WHERE id = :value",
        "contains" => "SELECT id FROM invoice WHERE 'FT SEQ/' || CAST(id AS TEXT) LIKE :value",
        "min" => "SELECT id FROM invoice WHERE id >= :value",
        "max" => "SELECT id FROM invoice WHERE id <= :value",
        "minvalue" => "SELECT MIN(id) AS id FROM invoice",
        "maxvalue" => "SELECT MAX(id) AS id FROM invoice"
    ],
    "InvoiceDate" => [
        "range" => "SELECT id FROM invoice WHERE billing_date BETWEEN :min AND :max",
        "equal" => "SELECT id FROM invoice WHERE billing_date = :value",
        "contains" => "SELECT id FROM invoice WHERE CAST(billing_date AS TEXT) LIKE :value",
        "min" => "SELECT id FROM invoice WHERE billing_date >= :value",
        "max" => "SELECT id FROM invoice WHERE billing_date <= :value",
        "minvalue" => "SELECT id FROM invoice WHERE billing_date IN (SELECT MIN(billing_date) FROM invoice)",
        "maxvalue" => "SELECT id FROM invoice WHERE billing_date IN (SELECT MAX(billing_date) FROM invoice)"
    ],
    "CompanyName" => [
        "range" => "SELECT invoice.id AS id FROM invoice JOIN customer on invoice.customer_id = customer.id WHERE customer.company_name BETWEEN :min AND :max",
        "equal" => "SELECT invoice.id AS id FROM invoice JOIN customer on invoice.customer_id = customer.id WHERE customer.company_name = :value",
        "contains" => "SELECT invoice.id AS id FROM invoice JOIN customer on invoice.customer_id = customer.id WHERE customer.company_name LIKE :value",
        "min" => "SELECT invoice.id FROM invoice WHERE billing_date >= :value",
        "max" => "SELECT invoice.id FROM invoice WHERE billing_date <= :value",
        "minvalue" => "SELECT invoice.id AS id FROM invoice JOIN customer on invoice.customer_id = customer.id WHERE customer.company_name IN (SELECT MIN(company_name) FROM customer)",
        "maxvalue" => "SELECT invoice.id AS id FROM invoice JOIN customer on invoice.customer_id = customer.id WHERE customer.company_name IN (SELECT MAX(company_name) FROM customer)"
    ],
    "GrossTotal" => [
        "range" => "SELECT invoice.id AS id
                    FROM invoice JOIN line ON invoice.id = line.invoice_id join tax ON line.tax_id = tax.id
                    GROUP BY invoice.id
                    HAVING SUM((tax.percentage / 100.0 + 1) * line.quantity * line.unit_price) BETWEEN CAST(:min AS REAL) AND CAST(:max AS REAL)",
        "equal" => "SELECT invoice.id AS id
                    FROM invoice JOIN line ON invoice.id = line.invoice_id join tax ON line.tax_id = tax.id
                    GROUP BY invoice.id
                    HAVING CAST(SUM((tax.percentage / 100.0 + 1) * line.quantity * line.unit_price) AS TEXT) = :value",
        "contains" => "SELECT invoice.id AS id
                    FROM invoice JOIN line ON invoice.id = line.invoice_id join tax ON line.tax_id = tax.id
                    GROUP BY invoice.id
                    HAVING CAST(SUM((tax.percentage / 100.0 + 1) * line.quantity * line.unit_price) AS TEXT) LIKE :value",
        "min" => "SELECT line.invoice_id AS id
                  FROM line JOIN tax ON line.tax_id = tax.id
                  GROUP BY line.invoice_id
                  HAVING SUM((tax.percentage / 100.0 + 1) * line.quantity * line.unit_price) >= CAST(:value AS REAL)",
        "max" => "SELECT line.invoice_id AS id
                  FROM line JOIN tax ON line.tax_id = tax.id
                  GROUP BY line.invoice_id
                  HAVING SUM((tax.percentage / 100.0 + 1) * line.quantity * line.unit_price) <= CAST(:value AS REAL)",
        "minvalue" => "SELECT line.invoice_id AS id
                 FROM line JOIN tax ON line.tax_id = tax.id
                 GROUP BY line.invoice_id
                 HAVING SUM((tax.percentage / 100.0 + 1) * line.quantity * line.unit_price) IN
                     (   SELECT MIN(grossTotal) FROM (SELECT SUM((tax.percentage / 100.0 + 1) * line.quantity * line.unit_price) AS grossTotal
                         FROM line JOIN tax ON line.tax_id = tax.id
                         GROUP BY line.invoice_id)
                     )",
        "maxvalue" => "SELECT line.invoice_id AS id
                    FROM line JOIN tax ON line.tax_id = tax.id
                    GROUP BY line.invoice_id
                    HAVING SUM((tax.percentage / 100.0 + 1) * line.quantity * line.unit_price) IN
                        (   SELECT MAX(grossTotal) FROM (SELECT SUM((tax.percentage / 100.0 + 1) * line.quantity * line.unit_price) AS grossTotal
                            FROM line JOIN tax ON line.tax_id = tax.id
                            GROUP BY line.invoice_id)
                        )"

    ],
];

$fieldError = getParameter("field", $field);
if ($fieldError)
{
    $error =  "error" . $fieldError;
    exit($$error);
}

$opError = getParameter("op", $op);
if ($opError)
{
    $error =  "error" . $opError;
    exit($$error);
}

$valueError = getParameter("value", $value);
if ($valueError && $op != "minvalue" && $op != "maxvalue")
{
    $error =  "error" . $valueError;
    exit($$error);
}

if (!(array_key_exists($field, $queries) && array_key_exists($op, $queries[$field])))
{
    exit($error400);
}

$query = $queries[$field][$op];

$db = new PDO('sqlite:../sql/OIS.db');

$stmt = $db->prepare($query);

if ($op == "range")
{
    if (!is_array($value) || !count($value) == 2)
        exit($error400);

    ParseValue($field, $op, $value[0]);
    ParseValue($field, $op, $value[1]);

    $minValue = ConvertIfNeeded($field, $op, $value[0]);
    $stmt->bindParam(':min', $minValue, GetValidParamType($field, $op));
    $maxValue = ConvertIfNeeded($field, $op, $value[1]);
    $stmt->bindParam(':max', $maxValue, GetValidParamType($field, $op));
}
else if ($op != "minvalue" && $op != "maxvalue")
{
    ParseValue($field, $op, $value[0]);
    $convertedValue = ConvertIfNeeded($field, $op, $value[0]);
    $stmt->bindParam(':value', $convertedValue, GetValidParamType($field, $op));
}

$stmt->execute();
$results = $stmt->fetchAll();

$toBeReturned = [];

$i = 0;
foreach ($results as $result)
{
    $invoice = new Invoice;
    $invoice->queryDbByNo($result['id']);
    $toBeReturned[$i++] = $invoice->toArray();
}

echo json_encode($toBeReturned);
