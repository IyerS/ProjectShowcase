-- ***ECOMMERCE PERFORMANCE ANALYSIS ON MAVENFUZZYFACTROY DATABASE THROUGH SQL***--
-- TABLES IN USE: website_sessions, website_pageviews, products, orders, order_items, order_item_refunds --

use mavenfuzzyfactory;




-- Gsearch monthly trend for Sessions, sales and orders
select
	yearweek(website_sessions.created_at) as month_date,
    count(website_sessions.website_session_id) as tot_session,
    sum(orders.price_usd) as tot_sales,
    sum(orders.order_id) as tot_orders
from
    website_sessions 
		left join orders
			on website_sessions.website_session_id = orders.website_session_id
where
	website_sessions.utm_source = 'gsearch'
group by
	yearweek(website_sessions.created_at);
    
    
    
    
	
-- Sessions, Orders and Conversion rate by device type for gsearch, nonbrand sessions before 2012-05-11
select
	website_sessions.device_type as device_type,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conversion_rt

from
	website_sessions
		LEFT JOIN orders
			on website_sessions.website_session_id = orders.website_session_id
where
	website_sessions.created_at < '2012-05-11'
    and website_sessions.utm_source = 'gsearch'
    and website_sessions.utm_campaign = 'nonbrand'
group by
	website_sessions.device_type;
    
    
    
    
    
-- Device type session across the weeks - time series with constraints

select
	-- week(created_at) as we,
    -- year(created_at) as yr,
	min(date(created_at)) as week_start_date,
    count(case when website_sessions.device_type = 'desktop' then website_session_id else null end) as dtop_sessions,
    count(case when website_sessions.device_type = 'mobile' then website_session_id else null end) as mob_sessions
from
	website_sessions
where
	utm_source = 'gsearch' and 
    utm_campaign = 'nonbrand' and
    created_at between '2012-04-15' and '2012-06-09'

group by
	year(created_at), 
    week(created_at);
    
    
    
    
    
-- Extracting all the landing pages and sessions count
drop table temp1; -- if any? 
create table temp1
select
	website_session_id,
    min(website_pageview_id) as first_hit_pv_id
from
	website_pageviews
group by
	website_session_id;
    
    
select
	website_pageviews.pageview_url as pagename,
    count(distinct temp1.website_session_id) as sessions
from 
	temp1 left join website_pageviews
		on temp1.first_hit_pv_id=website_pageviews.website_pageview_id
group by
	1;
    
    
    
    
    
-- Pagenames and total pageviews

select
	pageview_url,
    count(distinct website_pageview_id) as pageviews
from
	website_pageviews
where
	created_at < '2012-06-09'
group by
	pageview_url
order by
	pageviews DESC;
    
    
    
    

-- landing page bounce rate

create table temp1
select
	website_session_id,
    min(website_pageview_id) as frst_pgvw,
    count(website_pageview_id) as tot_pages_in_session
from
	website_pageviews
where
	created_at between '2012-06-19' and '2012-07-28'
group by
	website_session_id;
    
    
select
	website_pageviews.pageview_url as lp,
    count(temp1.website_session_id) as tot_sessions,
    -- temp1.tot_pages_in_session as pvs_in_session,
    count(case when tot_pages_in_session = 1 then 1 end) as bounced_sessions,
    count(case when tot_pages_in_session = 1 then 1 end)/count(temp1.website_session_id) as bounce_Rate
    
from
	temp1 left join website_pageviews
		on temp1.frst_pgvw = website_pageviews.website_pageview_id
group by
	lp;
    
    
    
    
    
-- weekly bouncerate calculations for average as well as two different landing pages  
    
create table temp1
select
	website_sessions.website_session_id as website_session_id,
    date(website_sessions.created_at) as created_date,
    min(website_pageviews.website_pageview_id) as frst_pgvw_id,
    count(website_pageviews.website_pageview_id) as pageviews
from
	website_sessions left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where
	website_sessions.created_at between '2012-06-01' and '2012-08-31'
    and website_sessions.utm_source = 'gsearch'
    and website_sessions.utm_campaign = 'nonbrand'
    -- and website_pageviews.pageview_url in ('/home','/lander-1')
group by
	website_sessions.website_session_id;
    
    
select
	concat(year(temp1.created_date),'-', week(temp1.created_date)) as yearweeks,
    min(temp1.created_date) as startofweek,
    count(temp1.website_session_id) as total_sessions,
    count(case when temp1.pageviews = 1 then 1 end) as bounced_sessions,
    count(case when temp1.pageviews = 1 then 1 end)/count(temp1.website_session_id) as agg_bounce_Rate,
	-- website_pageviews.pageview_url as lp,
    count(case when website_pageviews.pageview_url = '/home' then temp1.website_session_id end) as home_sessions,
	count(case when (website_pageviews.pageview_url = '/home' and temp1.pageviews = 1) then temp1.website_session_id end) as home_bounced_sessions,
    count(case when (website_pageviews.pageview_url = '/home' and temp1.pageviews = 1) then temp1.website_session_id end)/count(case when website_pageviews.pageview_url = '/home' then temp1.website_session_id end) as home_bounce_Rate,
    count(case when website_pageviews.pageview_url = '/lander-1' then temp1.website_session_id end) as lander_sessions,
    count(case when (website_pageviews.pageview_url = '/lander-1' and temp1.pageviews = 1) then temp1.website_session_id end) as lander_bounced_sessions,
    count(case when (website_pageviews.pageview_url = '/lander-1' and temp1.pageviews = 1) then temp1.website_session_id end)/count(case when website_pageviews.pageview_url = '/lander-1' then temp1.website_session_id end) as lander_bounce_Rate

from
	temp1 left join website_pageviews
		on temp1.frst_pgvw_id = website_pageviews.website_pageview_id
group by
	yearweeks;
    
    
    
    
    
-- WEEKLY Page click through performance and conversion funnel
    
create table session_pagedepth_info
select
	session_id as session_id,
    concat(year(created_at),'-',week(created_at)) as year_week,
    max(click_lander1) as to_lander1,
    max(click_products) as to_products,
    max(click_mrFuzzy) as to_mrFuzzy,
    max(click_shipping) as to_shipping,
    max(click_cart) as to_cart,
    max(click_billing) as to_billing,
    max(click_billing2) as to_billing2,
    max(click_thankyou) as to_end
from(
select
	distinct website_sessions.website_session_id as session_id,
    website_sessions.created_at as created_at,
    case when website_pageviews.pageview_url = '/home' then 1 else 0 end as click_home,
    case when website_pageviews.pageview_url = '/products' then 1 else 0 end as click_products,
    case when website_pageviews.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as click_mrFuzzy,
    case when website_pageviews.pageview_url = '/cart' then 1 else 0 end as click_cart,
    case when website_pageviews.pageview_url = '/shipping' then 1 else 0 end as click_shipping,
    case when website_pageviews.pageview_url = '/billing' then 1 else 0 end as click_billing,
    case when website_pageviews.pageview_url = '/billing-2' then 1 else 0 end as click_billing2,
    case when website_pageviews.pageview_url = '/lander-1' then 1 else 0 end as click_lander1,
	case when website_pageviews.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as click_thankyou
from
	website_sessions left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where
	-- website_sessions.utm_source = 'gsearch' and
    -- website_sessions.utm_campaign = 'nonbrand' and
    website_sessions.created_at > '2012-03-09' and 
    website_sessions.created_at < '2012-12-31'
order by
	website_sessions.website_session_id
    ) as page_level_hit
group by
	session_id;
select * from session_pagedepth_info;
select
	year_week as year_week,
	sum(to_lander1) as lander1_entry,
    sum(to_products) as to_Products,
    sum(to_mrFuzzy) as to_mrFuzzy,
    sum(to_cart) as to_cart,
    sum(to_shipping) as to_shipping,
    sum(to_billing) as to_billing,
	sum(case when (to_billing = 1 and to_end = 1) then 1 else 0 end) as billing1_conv,
	sum(case when (to_billing = 1 and to_end = 1) then 1 else 0 end)/sum(to_billing) as billing1_conv_rt,
    sum(to_billing2) as to_billing2,
    sum(case when (to_billing2 = 1 and to_end = 1) then 1 else 0 end) as billing2_conv,
    sum(case when (to_billing2 = 1 and to_end = 1) then 1 else 0 end)/sum(to_billing2) as billing2_conv_rt,
    sum(to_billing + to_billing2) as tot_billing,
    sum(to_end) as to_end,
    sum(to_end)/sum(to_billing + to_billing2) as CTR_ThankYou
from session_pagedepth_info
group by year_week;
