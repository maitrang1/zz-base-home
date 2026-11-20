// ===================================================================
// Own: zzOWN.com - Own Fast. Work Faster.  | Ema: zzown.com@gmail.com
// Des: Saved page fixtures shared by parser and pipeline tests
// Flo: constants only: shop page, block pages, robots, sitemaps
// I/O: none > const strings (tests only, never shipped logic)
// ===================================================================
pub const shop = "<!DOCTYPE html><html><head><meta charset=\"utf-8\"><title>Blue Widget &ndash; Shop &amp; Co</title><style>.x{color:red}</style><script>var a = '<b>not text</b>';</script><script type=\"application/ld+json\">{\"@context\":\"https://schema.org\",\"@type\":\"Product\",\"name\":\"Blue Widget\",\"offers\":{\"@type\":\"Offer\",\"price\":\"19.90\",\"priceCurrency\":\"USD\"}}</script></head><body><h1>Blue   Widget</h1><p>A fine widget.<br>Ships &quot;fast&quot; &#38; free &#x41;.</p><!-- hidden --><ul><li>one</li><li>two</li></ul><noscript>enable js</noscript></body></html>";
pub const cfch = "<!DOCTYPE html><html><head><title>Just a moment...</title></head><body><div id=\"cf-chl-widget\">Checking your browser before accessing the site. Enable JavaScript and cookies to continue.</div></body></html>";
pub const deny = "<HTML><HEAD><TITLE>Access Denied</TITLE></HEAD><BODY><H1>Access Denied</H1>You don't have permission to access this page. Reference #18.2f3c1b02</BODY></HTML>";
pub const capt = "<html><head><title>Please verify</title></head><body><p>We detected unusual traffic from your network. Are you a robot? Solve the CAPTCHA.</p></body></html>";
pub const emty = "<html><head><title>x</title><script>1</script></head><body>   <div> </div>  </body></html>";
pub const robo = "# crawlers\nUser-agent: *\nDisallow: /private\nDisallow: /tmp/\nAllow: /private/open\nCrawl-delay: 2\n\nUser-agent: scra\nDisallow: /secret$\nAllow: /\n\nUser-agent: badbot\nDisallow: /\n\nSitemap: https://example.com/sitemap.xml\n";
pub const smap = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\"><url><loc>https://example.com/a</loc><lastmod>2026-01-02</lastmod></url><url><loc> https://example.com/b?x=1&amp;y=2 </loc></url><url><loc><![CDATA[https://example.com/c]]></loc></url></urlset>";
pub const smix = "<sitemapindex><sitemap><loc>https://example.com/s1.xml</loc></sitemap><sitemap><loc>https://example.com/s2.xml</loc></sitemap></sitemapindex>";
pub const next = "<html><body><script id=\"__NEXT_DATA__\" type=\"application/json\">{\"props\":{\"items\":[{\"id\":1},{\"id\":2}],\"total\":2}}</script></body></html>";
// =======================___THIS_IS_THE_END___=======================
// ==============___HOLD_YOUR_BREATH_AND_COUNT_TO_TEN___==============
