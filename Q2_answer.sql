WITH MonthlyProportions AS (
    SELECT
        MONTH(PST_RETURN_PERIOD.start_date) AS MonthNumber,
        YEAR(PST_RETURN_PERIOD.start_date) AS Year,
        DATEDIFF(DAY, PST_RETURN_PERIOD.start_date, PST_RETURN_PERIOD.end_date) + 1 AS DaysInPeriod,
        SUM(DATEDIFF(DAY, PST_RETURN_PERIOD.start_date, PST_RETURN_PERIOD.end_date) + 1) OVER (PARTITION BY MONTH(PST_RETURN_PERIOD.start_date), YEAR(PST_RETURN_PERIOD.end_date)) AS TotalDaysInMonth
    FROM
        PST_RETURN_PERIOD
        INNER JOIN PST_ACCOUNT ON PST_RETURN_PERIOD.account_key = PST_ACCOUNT.account_key
    WHERE
        PST_ACCOUNT.NAICSCode LIKE '512%'
        AND YEAR(PST_RETURN_PERIOD.start_date) = 2015
)

SELECT
    month_number,
    Year,
    ROUND(SUM(tax_on_sales_reported * DaysInPeriod / TotalDaysInMonth), 2) AS ProportionTaxOnSales,
    ROUND(SUM(tax_on_purchases_reported * DaysInPeriod / TotalDaysInMonth), 2) AS ProportionTaxOnPurchases,
    ROUND(SUM(commission_reported * DaysInPeriod / TotalDaysInMonth), 2) AS ProportionCommission,
    ROUND(SUM(tax_due_reported * DaysInPeriod / TotalDaysInMonth), 2) AS ProportionTaxDue
FROM
    PST_ACCOUNT
    JOIN MonthlyProportions ON MONTH(PST_RETURN_PERIOD.start_date) = month_number AND YEAR(PST_RETURN_PERIOD.start_date) = Year
GROUP BY
    month_number,
    Year;
