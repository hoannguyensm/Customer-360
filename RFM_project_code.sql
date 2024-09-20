With Calculation as(
Select CustomerID,
(datediff(day, max(cast(Purchase_Date as date)), '2022-09-01')) as recency,
round(cast((count(distinct(cast(Purchase_Date as date)))) as float) / cast(datediff(year, cast(created_date as date), '2022-09-01') as float), 2) as frequency,
(sum(gmv)) / datediff(year, cast(created_date as date), '2022-09-01') as monetary,
datediff(year, cast(created_date as date), '2022-09-01') as customer_age
row_number() over (order by (datediff(day, max(cast(Purchase_Date as date)), '2022-09-01')) ) as rn_recency,
row_number() over (order by (round(cast((count(distinct(cast(Purchase_Date as date)))) as float) / cast(datediff(year, cast(created_date as date), '2022-09-01') as float), 2))) as rn_frequency,
row_number() over (order by (sum(gmv))) as rn_monetary
from Customer_Transaction T
join Customer_Registered R on T.CustomerID = R.ID
where CustomerID != 0
group by CustomerID, created_date)

select *, case 
    when recency < (select recency from Calculation where rn_recency = (select count(distinct(CustomerID))*0.25 from Calculation)) then '1'
    when recency > (select recency from Calculation where rn_recency = (select count(distinct(CustomerID))*0.25 from Calculation)) 
        and recency < (select recency from Calculation where rn_recency = (select count(distinct(CustomerID))*0.5 from Calculation)) then '2'
    when recency > (select recency from Calculation where rn_recency = (select count(distinct(CustomerID))*0.5 from Calculation)) 
        and recency < (select recency from Calculation where rn_recency = (select count(distinct(CustomerID))*0.75 from Calculation)) then '3'
    else '4' end as R,
       case
    when frequency < (select frequency from Calculation where rn_frequency = (select count(distinct(CustomerID))*0.25 from Calculation)) then '1'
    when frequency > (select frequency from Calculation where rn_frequency = (select count(distinct(CustomerID))*0.25 from Calculation)) 
        and frequency < (select frequency from Calculation where rn_frequency = (select count(distinct(CustomerID))*0.5 from Calculation)) then '2'
    when frequency > (select frequency from Calculation where rn_frequency = (select count(distinct(CustomerID))*0.5 from Calculation)) 
        and frequency < (select frequency from Calculation where rn_frequency = (select count(distinct(CustomerID))*0.75 from Calculation)) then '3'
    else '4' end as F,
    case
    when monetary < (select monetary from Calculation where rn_monetary = (select count(distinct(CustomerID))*0.25 from Calculation)) then '1'
    when monetary > (select monetary from Calculation where rn_monetary = (select count(distinct(CustomerID))*0.25 from Calculation)) 
        and monetary < (select monetary from Calculation where rn_monetary = (select count(distinct(CustomerID))*0.5 from Calculation)) then '2'
    when monetary > (select monetary from Calculation where rn_monetary = (select count(distinct(CustomerID))*0.5 from Calculation)) 
        and monetary < (select monetary from Calculation where rn_monetary = (select count(distinct(CustomerID))*0.75 from Calculation)) then '3'
    else '4' end as M,
