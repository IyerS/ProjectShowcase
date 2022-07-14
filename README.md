# ProjectShowcase
Set of work to showcase skill levels


PROJECT: FuzzyFactory Ecommerce Data analysis
DATABASE: The TABLES IN USE are website_sessions, website_pageviews, products, orders, order_items, order_item_refunds

website_sessions
Columns: website_session_id, created_At, user_id, is_repeat_sessoion, utm_source, utm_campaign, utm_cntent, device_type_http_referer

website_pageviews
Columns: website_pageview_id, created_at, website_session_id, pageview_url

products
Columns: product_id, created_at, product_name

orders
Columns: order_id, created_at, website_session_id, user_id, primary_product_id, items_purchased, price_usd, cogs_usd

order_items
Columns: order_item_id, created_At, order_id, product_id, is_primary_item, price_usd, cogs_usd

order_item_refunds
Columns: order_item_refund_id, created_at, order_item_id, order_id, refund_amount_usd




  
  
  
  
  To create the table, you can execute the SQL file "create_fuzzyfactorydata"
  

