<%@ page import="java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*;import java.text.*;" %><%@ include file="/includes/SessionChecker.jsp" %>
<%boolean editor= (((RoleResolver)session.getAttribute("roles")).roleCheck("editor"));%><html>
<head>
<title>Vendor Reports Menu</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
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
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
</head>
<body bgcolor="#FFFFFF" text="#000000">
<table>
	<tr>
		<td class="minderheadercenter">Reports and Data Entry</td>
	</tr>
	<tr>
		<td class="subtitle">Add/Edit data forms:</td>
	</tr>
	<tr>
		<td>
			<ul class='list'>
				<li><a href="/popups/QuickShipForm.jsp"  class='subtitle1' >Enter shipment</a></li>
				<li><a href="/popups/QuickBillForm.jsp"  class='subtitle1' >Bill Job</a></li>
				<li><a href="/admin/collections/EntryFormFromQuick.jsp"  class='subtitle1' >Enter collection</a></li>
				<li><a href="/app-admin/payments/APAddEntryFromQuick.jsp"  class='subtitle1' >Manage Accruals</a></li>
				<li><a href="/popups/ProductInfo.jsp"  class='subtitle1' target='_blank'>View/Edit Product Information</a></li>
				<li><a href="/minders/workflowforms/InventoryUpdateForm.jsp"  class='subtitle1' target='_blank'>View/Adjust Product Inventory</a></li>
				<li><a href="/admin_cm/index.jsp"  class='subtitle1' target='_blank'>MS Access Replacement Functions, incl. Prop Master List Mgmt</a></li>
			</ul>
		</td>
	</tr>
	<tr>
		<td class="subtitle">Reports:</td>
	</tr>
	<tr>
		<td>
			<ul class='list'>
				<li><a href="/reports/vendors/SalesReportFilters.jsp" class='subtitle1'>Sales: Invoice History Report</a></li>
				<li><a href="/reports/vendors/orderHistoryFilters.jsp"  class='subtitle1'>Sales: Order History Report</a></li>
				<li><a href="/reports/vendors/invoiceHistoryForCompanyFilters.jsp"  class='subtitle1'>Purchases: Invoice History Report</a></li>
				<li><a href="/reports/vendors/AgedARRptFilters.jsp"  class='subtitle1'>Accounts Receivable Open Invoices with Aging</a></li>
<li><a href="/popups/MCSiteDirectory.jsp" class='subtitle1'>Website Directory</a></li>
<%if(editor){%><li><a href="/app-admin/payments//APReportFilters.jsp"  class='subtitle1'>AP Accrual Reports</a></li>
					<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp" class='subtitle1'>Complete Inventory Spreadsheet</a> -- shows current listing of all products with their inventory and on-order amounts. When prompted, save as a file with a .xls extension, will save to an excel spreadsheet.
	</li>
	<ul class='list'>
		<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?asap=true" class='subtitle1'>Inventoriable Products Needing Order/Reorder ASAP</a> -- shows current listing of all active inventoriable products that need action: either need to be reordered immmediately to avoid backorders, or have never been initialized with a manual inventory count.</li>
			<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?asap=true&initialized=true" class='subtitle1'>Initialized Products Needing Order/Reorder ASAP</a> -- shows current listing of all inventoriable products that have been initialized previously which require immediate reordering to avoid backorders.</li>
		<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?active=true" class='subtitle1'>Active Products Only</a> -- shows current listing of all active products.</li>
		<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?inventory=true" class='subtitle1'>Inventoriable Products Only</a> -- shows current listing of all inventoriable products.</li>
			<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?initialized=true" class='subtitle1'>Initialized Products Only</a> -- shows current listing of all inventoriable products that have been initialized with a manual inventory count.</li>
			<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?active=true&inventory=true" class='subtitle1'>Active, Inventoriable Products Only</a></li>			
			<li><a href="http://lms.marcomet.com/app-admin/product/Inventory.jsp?active=true&inventory=true&initialized=true" class='subtitle1'>Active, Inventoriable, Initialized Products Only</a></li>
	</ul>
				<%}%>
			</ul>
		</td>
	</tr>


	<tr>
		<td class="subtitle">Utilities:</td>
	</tr>
	<tr>
		<td>
			<ul class='list'>
				<li><a href="/app-admin/RecalcJobs.jsp" class='subtitle1'>Recalc Flagged Jobs</a></li>
			</ul>
		</td>
	</tr>

	<tr>
		<td class="subtitle">Other:</td>
	</tr>
	<tr>
		<td>
			<ul class='list'>
				<li><a href="/app-admin/index.jsp"  class='subtitle1' target='_blank'>Marcomet Application Administration</a></li>
				<li><a href="/contents/page.jsp?pageName=site_directory"  class='subtitle1' target='_blank'>Marcomet Site Directory</a></li>
			</ul>
		</td>
	</tr>

</table>

<p>&nbsp;</p>
<p class='subtitle'>Miscellaneous development and utility links - see Supervisor before utilizing:</p>
<ul class='list'> 
				<li>
					<a href="http://lms.marcomet.com/app-admin/product/productlinesFilters.jsp">Product Listing with Product Lines</a>: Pulls up all product lines for a given product and optionally exports to and Excel Spreadsheet; can be filtered by Company, Brand, Release and/or Status, and shows list either by product or by product line. Includes product line bridge table entries.</b>
	</li>
<!--					<li>
					<a href="http://lms.marcomet.com/popups/ProductInfo.jsp">Product Information</a>: Pulls up all information related to the product,  supply the Product ID or the Product Code when asked.</b>
	</li> -->
				</li>
<!--				<li>
					<a href="http://lms.marcomet.com/minders/workflowforms/InventoryUpdateForm.jsp">Inventory Update Form</a>Form to enter inventory updates to perform a manual increase or decrease to inventory, and update product inventory information, all from one form. Also pulls up all information related to the product. Supply the Product ID or the Product Code when asked.</b>
	</li> --> </ol>
<!--				</li>
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
	</ul> -->
	<li>
	<a href="http://lms.marcomet.com/app-admin/UpdateAccruedAP.jsp">Update Accrued AP Fields</a> -- Update the accrued_po_bal and accrued_ship_bal fields on all jobs. Can be run with a ?jobId=xxxx suffix on the URL to only run it for a specific job.
	</li>
<!--	<li>
	<a href="http://lms.marcomet.com/app-admin/RecalcJobs.jsp">Recalc Flagged Jobs</a> -- Run the CalculateJobCosts servlet for all jobs that have a '1' in their recalc_flag. Can be run with a ?jobId=xxxx suffix on the URL to only run it for a specific job (job doesn't need to be flagged in that case.)
	</li> -->
	<li>
		<a href="http://lms.marcomet.com/app-admin/ShippedNotPosted.jsp">Shipped but Not Posted Report</a> 
	</li>
	<li>
<!--		<li>
		<a href="http://lms.marcomet.com/app-admin/payments/APReportFilters.jsp">AP Reports</a> 
	</li> -->
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
