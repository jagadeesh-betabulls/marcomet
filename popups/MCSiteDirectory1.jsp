<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.sql.*" errorPage="" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Marcomet Mast Site Directory</title>
<link rel="stylesheet" href="/sitehosts/lms/styles/menu_styles.css" type="text/css">
<link rel="stylesheet" href="/sitehosts/lms/styles/vendor_styles.css" type="text/css">
<link rel="stylesheet" href="/sitehosts/lms/styles/vendor_styles2.css" type="text/css">
<style>
	ul.list {
		font-family: Arial, Helvetica, sans-serif;
		font-size: 9pt;
		color: #0b3b25;
		vertical-align: top;
		font-style: normal;
		font-weight: normal;
		font-variant: normal;
		list-style-position: inside;
		list-style-type: lower-alpha;
		list-style-image: url(/images/raquote.gif);
		line-height: 150%;
	}
A:hover {
	border-top: 1px solid #52bef1;
	border-bottom: 1px solid #52bef1;
}
</style>
</head>

<body bgcolor="#FFFFFF" text="#000000">
<p><b>MarComet Site Directory:</b></p>
<table border=1 cellpadding=5 cellspacing=0 style='border-collapse:
 collapse;table-layout:fixed'>
  <tr>
    <td class='minderheader'><b>Brand / Audience</b></td>
    <td class='minderheader'><b>Site Name</b></td>
    <td class='minderheader'><b>Site Type</b></td>
    <td class='minderheader'><b>URL</b></td>
    <td class='minderheader'><b>Subdomain</b></td>
  </tr>
  <tr>
    <td class='lineitems'>Wingate Inns</td>
    <td class='lineitems'>WinMarketing</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://www.winmarketing.us" target="_blank">www.winmarketing.us</a></td>
    <td class='lineitems'>winmarketing</td>
  </tr>
  <tr>
    <td class='lineitems'>Ramada</td>
    <td class='lineitems'>MarketRamada</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://www.marketramada.com" target="_blank">www.marketramada.com</a></td>
    <td class='lineitems'>marketramada</td>
  </tr>
  <tr>
    <td class='lineitems'>Super 8</td>
    <td class='lineitems'>marketSuper8</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://www.marketsuper8.com" target="_blank">www.marketsuper8.com</a></td>
    <td class='lineitems'>marketsuper8</td>
  </tr>
    <tr>
    <td class='lineitems'>Microtel</td>
    <td class='lineitems'>marketMicrotel</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://www.marketMicrotel.com" target="_blank">www.marketMicrotel.com</a></td>
    <td class='lineitems'>marketmicrotel</td>
  </tr>
  <tr>
    <td class='lineitems'>Howard Johnson</td>
    <td class='lineitems'>markethojo</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://www.markethojo.com" target="_blank">www.markethojo.com</a></td>
    <td class='lineitems'>markethojo</td>
  </tr>
  <tr>
    <td class='lineitems'>Travelodge</td>
    <td class='lineitems'>markettravelodge</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://www.markettravelodge.com" target="_blank">www.markettravelodge.com</a></td>
    <td class='lineitems'>markettravelodge</td>
  </tr>
  <tr>
    <td class='lineitems'>Days Inns</td>
    <td class='lineitems'>MarketDaysInn</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://www.marketdaysinn.com" target="_blank">www.marketdaysinn.com</a></td>
    <td class='lineitems'>marketdaysinn</td>
  </tr>
  <tr>
    <td class='lineitems'>Baymont Inns &amp; Suites</td>
    <td class='lineitems'>MarketBaymont</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://www.marketbaymont.com" target="_blank">www.marketbaymont.com</a></td>
    <td class='lineitems'>marketbaymont</td>
  </tr>
  <tr>
    <td class='lineitems'>Baymont Inns &amp; Suites</td>
    <td class='lineitems'>BrandBaymont</td>
    <td class='lineitems'>Brand ID</td>
    <td class='lineitems'><a href="http://www.brandbaymont.com" target="_blank">www.brandbaymont.com</a></td>
    <td class='lineitems'>brandbaymont</td>
  </tr>
  <tr>
    <td class='lineitems'>&nbsp;</td>
    <td class='lineitems'>&nbsp;</td>
    <td class='lineitems'>&nbsp;</td>
    <td class='lineitems'>&nbsp;</td>
    <td class='lineitems'>&nbsp;</td>
  </tr>
    <tr>
    <td class='lineitems'>Wyndham Franchise Sales</td>
    <td class='lineitems'>ThePowerOfConnection</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://www.thepowerofconnection.com" target="_blank">www.thepowerofconnection.com</a></td>
    <td class='lineitems'>thepowerofconnection</td>
  </tr>
  <tr>
    <td class='lineitems'>AmeriHost Inns</td>
    <td class='lineitems'>InnMarketing</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://www.innmarketing.us" target="_blank">www.innmarketing.us</a></td>
    <td class='lineitems'>innmarketing</td>
  </tr>
  <tr>
    <td class='lineitems'>Other Clients</td>
    <td class='lineitems'>MC Agency</td>
    <td class='lineitems'>Marketing Services</td>
    <td class='lineitems'><a href="http://agency.marcomet.com" target="_blank">agency.marcomet.com</a></td>
    <td class='lineitems'>agency</td>
  </tr>
  <tr>
    <td class='lineitems'>&nbsp;</td>
    <td class='lineitems'>&nbsp;</td>
    <td class='lineitems'>&nbsp;</td>
    <td class='lineitems'>&nbsp;</td>
    <td class='lineitems'>&nbsp;</td>
  </tr>
  <tr>
    <td class='lineitems'>MC - Administration</td>
    <td class='lineitems'>Admin</td>
    <td class='lineitems'>MC</td>
    <td class='lineitems'><a href="http://lms.marcomet.com/app-admin/AdminLogin.jsp" target="_blank">http://lms.marcomet.com/app-admin/AdminLogin.jsp</a></td>
    <td class='lineitems'>lms</td>
  </tr>
  <tr>
    <td class='lineitems'>MC - Vendor Access</td>
    <td class='lineitems'>Vendor</td>
    <td class='lineitems'>MC</td>
    <td class='lineitems'><a href="http://vendor.marcomet.com" target="_blank">vendor.marcomet.com</a></td>
    <td class='lineitems'>vendor</td>
  </tr>
  <tr>
    <td class='lineitems'>MC - Marketing Services</td>
    <td class='lineitems'>LMS</td>
    <td class='lineitems'>MC</td>
    <td class='lineitems'><a href="http://lms.marcomet.com" target="_blank">lms.marcomet.com</a></td>
    <td class='lineitems'>lms</td>
  </tr>
</table>
<br /><br />

<p class='subtitle'>Logins for SiteHost Role access (roles 3, 10):</p>
<table border=1 cellpadding=4 cellspacing=0 style='border-collapse:
 collapse;table-layout:fixed'>
  <col width=75 span=11>
  <tr>
    <td width=75></td>
    <td width=75></td>
    <td  width=75 class='minderheader'>WINMARKETING</td>
    <td  width=75 class='minderheader'>AMERIHOST</td>
    <td  width=75 class='minderheader'>RAMADA</td>
    <td  width=75 class='minderheader'>HOWARDJOHNSONS</td>
    <td  width=75 class='minderheader'>TRAVELODGE</td>
    <td  width=75 class='minderheader'>DAYSINN</td>
    <td  width=75 class='minderheader'>BAYMONT</td>
    <td  width=75 class='minderheader'></td>
    <td  width=75 class='minderheader'>FRANCHISE SALES</td>
 </tr>
 <tr>
    <td class=xl27></td>
    <td  class='minderheaderright'>company id: </td>
    <td class='lineitems'>1082</td>
    <td class='lineitems'>1261</td>
    <td class='lineitems'>1253</td>
    <td class='lineitems'>1376</td>
    <td class='lineitems'>1916</td>
    <td class='lineitems'>1068</td>
    <td class='lineitems'>2615</td>
    <td class='lineitems'></td>
    <td class='lineitems'>2222</td>
 </tr>
 <tr>
    <td class=xl27></td>
    <td  class='minderheaderright'>username: </td>
    <td class='lineitems'>winsite</td>
    <td class='lineitems'>amerisite</td>
    <td class='lineitems'>ramadasite</td>
    <td class='lineitems'>hjsite</td>
    <td class='lineitems'>tlsite</td>
    <td class='lineitems'>disite</td>
    <td class='lineitems'>baysite</td>
    <td class='lineitems'></td>
    <td class='lineitems'>fransales</td>
 </tr>
 <tr>
    <td class=xl27></td>
    <td  class='minderheaderright'>password: </td>
    <td class='lineitems'>password</td>
    <td class='lineitems'>password</td>
    <td class='lineitems'>password</td>
    <td class='lineitems'>password</td>
    <td class='lineitems'>password</td>
    <td class='lineitems'>password</td>
    <td class='lineitems'>password</td>
    <td class='lineitems'></td>
    <td class='lineitems'>password</td>
 </tr>
 <tr>
    <td class=xl27></td>
    <td class='lineitems'></td>
    <td class='lineitems'></td>
    <td class='lineitems'></td>
    <td class='lineitems'></td>
    <td class='lineitems'></td>
    <td class='lineitems'></td>
    <td class='lineitems'></td>
    <td class='lineitems'></td>
    <td class='lineitems'></td>
    <td class='lineitems'></td>
 </tr>
 <tr>
    <td class=xl27></td>
    <td colspan=9  class='minderheaderleft'>alt username:</td>
    <td class='lineitems'>ryukna</td>
 </tr>
</table>

<p>&nbsp;</p>
<p class='subtitle'>Miscellaneous development and utility links - see Supervisor before utilizing:</p>
<ul class='list'> 
				<li>
					<a href="http://lms.marcomet.com/app-admin/product/productlinesFilters.jsp">Product Listing with Product Lines</a>: Pulls up all product lines for a given product and optionally exports to and Excel Spreadsheet; can be filtered by Company, Brand, Release and/or Status, and shows list either by product or by product line. Includes product line bridge table entries.</b>
	</li>
					<li>
					<a href="http://lms.marcomet.com/popups/ProductInfo.jsp">Product Information</a>: Pulls up all information related to the product,  supply the Product ID or the Product Code when asked.</b>
	</li>
				</li>
				<li>
					<a href="http://lms.marcomet.com/minders/workflowforms/InventoryUpdateForm.jsp">Inventory Update Form</a>Form to enter inventory updates to perform a manual increase or decrease to inventory, and update product inventory information, all from one form. Also pulls up all information related to the product. Supply the Product ID or the Product Code when asked.</b>
	</li></ol>
				</li>
	<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp">Complete Inventory Spreadsheet</a> -- shows current listing of all products with their inventory and on-order amounts. When prompted, save as a file with a .xls extension, will save to an excel spreadsheet.
	</li>
	<ul class='list'>
		<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?asap=true">Inventoriable Products Needing Order/Reorder ASAP</a> -- shows current listing of all active inventoriable products that need action: either need to be reordered immmediately to avoid backorders, or have never been initialized with a manual inventory count.</li>
			<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?asap=true&initialized=true">Initialized Products Needing Order/Reorder ASAP</a> -- shows current listing of all inventoriable products that have been initialized previously which require immediate reordering to avoid backorders.</li>
		<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?active=true">Active Products Only</a> -- shows current listing of all active products.</li>
		<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?inventory=true">Inventoriable Products Only</a> -- shows current listing of all inventoriable products.</li>
			<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?initialized=true">Initialized Products Only</a> -- shows current listing of all inventoriable products that have been initialized with a manual inventory count.</li>
			<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?active=true&inventory=true">Active, Inventoriable Products Only</a></li>			
			<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?active=true&inventory=true&initialized=true">Active, Inventoriable, Initialized Products Only</a></li>
	</ul>
	<li>
	<a href="http://lms.marcomet.com/app-admin/UpdateAccruedAP.jsp">Update Accrued AP Fields</a> -- Update the accrued_po_bal and accrued_ship_bal fields on all jobs. Can be run with a ?jobId=xxxx suffix on the URL to only run it for a specific job.
	</li>
	<li>
	<a href="http://lms.marcomet.com/app-admin/RecalcJobs.jsp">Recalc Flagged Jobs</a> -- Run the CalculateJobCosts servlet for all jobs that have a '1' in their recalc_flag. Can be run with a ?jobId=xxxx suffix on the URL to only run it for a specific job (job doesn't need to be flagged in that case.)
	</li>
	<li>
		<a href="http://lms.marcomet.com/app-admin/ShippedNotPosted.jsp">Shipped but Not Posted Report</a> 
	</li>
	<li>
		<li>
		<a href="http://lms.marcomet.com/app-admin/payments/APReportFilters.jsp">AP Reports</a> 
	</li>
	<li>
		<a href="http://lms.marcomet.com/minders/workflowforms/Checkshipping.jsp">Shipping
  Updater</a> -- for importing Days Inn Keycard Envelope shipping data provided
  by PLI in spreadsheet form. Data must first be pasted/imported from XLS file into tmp_shipping_data
  table. 
	</li>
		<li>
			<a href="http://lms.marcomet.com/minders/workflowforms/CheckProducts.jsp">Product Inventory Info
	  Updater</a> -- for updating product inventory information. Can be used one of 3 ways:
	<ol><li>Data may first be pasted/imported from XLS file into tmp_products table, then run this to create the inventory record and update the numbers, for one product only supply the productId: <b>http://lms.marcomet.com/minders/workflowforms/CheckProducts.jsp?productId=xxxx</b></li>
	<li>If inventory records were manually updated, run this with a productId for one or without to update ALL products, e.g. <b>http://lms.marcomet.com/minders/workflowforms/CheckProducts.jsp?productId=xxxx</b></li><li>To update all product records' inventory numbers, regardless of changes to inventory table run WITHOUT the productId parameter</li></ol></li>
</ul>

</body>
</html>
