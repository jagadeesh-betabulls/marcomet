<style>#minderFilters { border-style: solid; border-width: 1px; text-align: left; text-decoration: none; font: 10pt "Arial Narrow", Helvetica, sans-serif;  }
#jobNumberFilter {padding: 5pt; border-bottom-style: solid; border-bottom-width: 1px; }
#otherFilters {padding: 5pt; border-bottom-style: solid; border-bottom-width: 1px; }
#sortAndGo{padding: 5pt;}
select { line-height: 14pt; font: normal 9pt Arial, Helvetica, sans-serif; }
.otherminder { font: normal 9pt Arial, Helvetica, sans-serif; background: #f6f6de; }
select.sortBy st3.
.jobNumberInput { font: normal 9pt Arial, Helvetica, sans-serif; background: #e9f3f6 }
input.submit { font-weight: bold; font: normal 9pt Arial, Helvetica, sans-serif; background: #c0cbb1; }
</style>
<script>
	function popSiteNumber(){
		var elVal=' AND 1 = 1 ';
		var EntryVal=document.forms[0].sitenumberEntry.value;
		if ( EntryVal != ''){
			elVal=" AND j.site_number = '"+EntryVal+"' ";
		}
		document.forms[0].sitenumberFilter.value=elVal;
		
	}
	function popCustomerID(){
		var elVal=' AND 1 = 1 ';
		var EntryVal=document.forms[0].customerIDentry.value;
		if ( EntryVal != ''){
			elVal=" AND j.jbuyer_contact_id = '"+EntryVal+"' ";
		}
		document.forms[0].customerIDfilter.value=elVal;
		
	}
	
</script>
<form method="post" action=""><div id=minderFilters><!-- Job Number Filter -->
<div id=jobNumberFilter>
<table cellpadding="0" border="0"><tbody><tr><td width="80%" valign="bottom"><strong>Filter Jobs By:</strong><br>Job Number (Leave blank for all):&nbsp;<input type="text" name="mndrJobNumber" size="10" value="<%=mndrJobNumber%>" class="jobNumberInput"> | <select name="linkedjobsFilter" class="jobNumberInput"><option value="">HIDE</option><option value="YES">SHOW</option></select>&nbsp;&nbsp;&nbsp;--OR--&nbsp;&nbsp;&nbsp; Subvendor Reference (Leave blank for all):&nbsp;<input type="text" name="svReference" size="15" value="<%=svReference%>" class="jobNumberInput">
&nbsp;&nbsp;&nbsp;--OR--&nbsp;&nbsp;&nbsp;Order Number(Leave blank for all) :&nbsp;<input type="text" name="orderNumber" size="12" value="<%=orderFilter%>">  <br> Linked Jobs</td></tr></tbody></table>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; --OR-- (Clear the job number,order number and SV Reference to use filters below)</div>
<div id=otherFilters>
<table cellpadding=0 border=0>

<!-- Vendor Rep Filter - modified by CSA 10/15/2014 to change from dynamic to master list-->

<tr><td align=right><span class=label>Rep:</span></td><td><%
// Check role for view all or only self.  Role = 8 means Rep Supv, show all reps
	sql = "SELECT cont.id, cr.contact_role_id, c.company_name 'companyname', cont.lastname 'lastname', cont.firstname  'firstname' FROM contacts cont, contact_roles cr, companies c WHERE cont.id = " + up.getContactId() + " AND cont.companyid = c.id AND cr.contact_id = cont.id AND cr.site_host_id = " + shs.getSiteHostId() + " AND cr.contact_role_id = 8";
Connection conn2 = DBConnect.getConnection();
Statement st3 = conn2.createStatement();
		ResultSet rs7 = st3.executeQuery(sql);
		while (rs7.next()) {
			vendorRepSupv = "1";
			}
%><select name="vendorRepFilter" class="otherminder"><%
		if (vendorRepSupv.equals("1")) {
			//if Rep Supv, view all Reps <option selected value=" AND 1 = 0 ">- select -</option>
			 if (vendorRepFilter.equals(" AND 1 = 1 ")) { 
	//if already set to All, show All selected
	%><option selected value=" AND 1 = 1 ">All</option><% } else { %><option value=" AND 1 = 1 ">All</option><% 
	}

sql = "SELECT companyid, companyname 'companyname', lastname 'lastname', contactid, firstname 'firstname', default_rep 'default_rep' FROM PL_vendorRepFilter WHERE companyid = " + up.getCompanyId() + " ORDER BY companyname, lastname, firstname";

ResultSet rs2 = st3.executeQuery(sql);
while (rs2.next()) {

  if (vendorRepFilter.equals(" AND ( j.vendor_contact_id = " + rs2.getString("contactid")+ " OR o.buyer_contact_id = " + rs2.getString("contactid")+ " ) ")) {
			//if rep already set, show that selected
			%><option selected value=" AND ( j.vendor_contact_id = <%=rs2.getString("contactid")%> OR o.buyer_contact_id = <%=rs2.getString("contactid")%> ) "><%=rs2.getString("companyname")%> - <%=rs2.getString("firstname")%> <%=rs2.getString("lastname")%> - <%=rs2.getString("contactid")%></option><% } else { %>

  <option value=" AND ( j.vendor_contact_id = <%=rs2.getString("contactid")%> OR o.buyer_contact_id = <%=rs2.getString("contactid")%> ) "><%=rs2.getString("companyname")%> - <%=rs2.getString("firstname")%> <%=rs2.getString("lastname")%> - <%=rs2.getString("contactid")%></option><% } }   

			// end else, end while
			} else { 
				//if not Rep Supv, view only unassigned default or self
				sql = "SELECT c.id , c.company_name 'companyname', cont.lastname 'lastname', cont.id 'contactid', cont.firstname 'firstname', v.default_rep 'default_rep' FROM contacts cont, vendors v, companies c WHERE (cont.id = " + up.getContactId() + " AND c.id = cont.companyid AND v.company_id = c.id) OR (c.id = " + up.getCompanyId() + " AND v.company_id = c.id AND cont.id = v.default_rep) GROUP BY cont.id ORDER BY companyname, lastname, firstname";
ResultSet rs2 = st3.executeQuery(sql);
while (rs2.next()) {

  if (vendorRepFilter.equals(" AND ( j.vendor_contact_id = " + rs2.getString("cont.id")+ " OR o.buyer_contact_id = " + rs2.getString("cont.id")+ " ) ")) { 
			//if rep already set, show that selected
			%><option selected value=" AND ( j.vendor_contact_id = <%=rs2.getString("contactid")%> OR o.buyer_contact_id = <%=rs2.getString("contactid")%> ) "><%=rs2.getString("companyname")%> - <%=rs2.getString("firstname")%> <%=rs2.getString("lastname")%> - <%=rs2.getString("contactid")%></option><% } else { %>
  <option value=" AND ( j.vendor_contact_id = <%=rs2.getString("contactid")%> OR o.buyer_contact_id = <%=rs2.getString("contactid")%> ) "><%=rs2.getString("companyname")%> - <%=rs2.getString("firstname")%> <%=rs2.getString("lastname")%> - <%=rs2.getString("contactid")%></option><% } }
			//end else - not prev set, end while loop of reps
			} 
			//end else - not Rep Supv
%></select>
<!-- End Vendor Rep Filter -->


</td></tr>


<!-- Client Filter - edited 10/15/2014 by CSA to eliminate dynamic choice, too much load on db and no longer needed -->
<tr><td align=right><span class=label>Client/Buyer:</span></td><td><select name="companyFilter" class='otherminder'><option selected value=" AND 1 = 1 ">All</option>
</select>
<!-- end Client filter -->

<!-- Customer ID Filter -->
&nbsp;&nbsp;&nbsp;&nbsp; <span class=label>Customer ID#:&nbsp;</span><input type=text name='customerIDEntry' id='customerIDEntry' class='otherminder' size=10 onChange='popCustomerID()' value="<%=customerIDEntry%>"><input type=hidden name='customerIDFilter' id='customerIDFilter' value="<%=customerIDFilter%>">
<!-- end Customer ID filter -->

<!-- Sitenumber Filter -->
&nbsp;&nbsp;&nbsp;&nbsp; <span class=label>Wyndham Site#:&nbsp;</span><input type=text name='sitenumberEntry' id='sitenumberEntry' class='otherminder' size=10 onChange='popSiteNumber()' value="<%=sitenumberEntry%>"><input type=hidden name='sitenumberFilter' id='sitenumberFilter' value="<%=sitenumberFilter%>">
<!-- end Sitenumber filter -->

</td></tr>

<!-- site host filter - changed 10/15/2014 by CSA from dynamic to master picklist -->
<tr><td align=right><span class=label>Site&nbsp;Host:</span></td><td><select name="siteHostFilter" class='otherminder'><option selected value=" AND 1 = 1 ">All</option>
<%sql = "SELECT sh_id 'id', companyname 'companyname' FROM PL_siteHostFilter WHERE user_comp_id = " + up.getCompanyId() + " ORDER BY companyname";

		ResultSet rs1 = st3.executeQuery(sql);
		while (rs1.next()) {

		 if (siteHostFilter.equals(" AND sh.id = " + rs1.getString("id")+ " ")) { %><option selected value=" AND sh.id = <%=rs1.getString("id")%> "><%=rs1.getString("companyname")%></option><%

		 } else { %><option value=" AND sh.id = <%=rs1.getString("id")%> "><%=rs1.getString("companyname")%></option><%   } } %></select>&nbsp; 
<!-- End Site host filter  -->


<!-- Vendor Filter modified by CSA 10/15/2014 to remove dynamic list and replace with master list -->
<span class=label>&nbsp;&nbsp;&nbsp;&nbsp; Vendor:&nbsp;</span><select name="vendorFilter" class='otherminder'><option selected value=" AND 1 = 1 ">All</option>
<%sql = "SELECT vendorid 'vendorid', vendorcompid 'vendorcompid', vendorcompname 'vendorcompname' FROM PL_vendorFilter WHERE user_comp_id = " + up.getCompanyId() + " ORDER BY vendorcompname";
				ResultSet rs6 = st3.executeQuery(sql);
				while (rs6.next()) {

		  if (vendorFilter.equals(" AND ( j.vendor_id = " + rs6.getString("vendorid") + " ) " ) ) { %><option selected value=" AND ( j.vendor_id = <%=rs6.getString("vendorid")%> ) "><%=rs6.getString("vendorcompname")%></option><% } else { %><option value=" AND ( j.vendor_id = <%=rs6.getString("vendorid")%> ) "><%=rs6.getString("vendorcompname")%></option><%
						 }
						}
						%></select>
<!-- End Vendor Filter -->

</td></tr>

<!-- Sub-Vendor Filter -->
<tr><td align=right><span class=label>Sub-Vendor:</span></td><td><%
//Check role for all or limited view.  If contact is proxy for vendor, then limited
sql = "SELECT cont.id,proxyvendor FROM contacts cont WHERE cont.id = " + up.getContactId() + " AND proxyvendor is not null";
ResultSet rs8 = st3.executeQuery(sql);
String proxyVendorId="";
while (rs8.next()) {
	onlySubVendor = "1";
	proxyVendorId=rs8.getString("proxyvendor");
}
%><select name="subvendorFilter" class='otherminder'><%
subvendorFilter=((request.getParameter("subvendorFilter")==null)?"":request.getParameter("subvendorFilter"));
if (!onlySubVendor.equals("1")) { 
//not a proxy for vendor, show all subvendors
%><option selected value=" 1 = 1 " >All</option><option <%=((subvendorFilter.equals(" sv.integrated_flag=0 "))?"Selected":"")%> value=" sv.integrated_flag=0 ">All Non-integrated Vendors</option><%sql = "SELECT v.id 'subvendor_id', company_name 'companyname' FROM product_price_codes ppc, vendors v, companies co WHERE ppc.dropship_vendor=v.id AND v.company_id=co.id GROUP BY v.id ORDER BY company_name";
	ResultSet rs4 = st3.executeQuery(sql);
	while (rs4.next()) {
	  if (subvendorFilter.equals(" j.dropship_vendor= " + rs4.getString("subvendor_id")+ " ")) { %><option selected value=" j.dropship_vendor= <%=rs4.getString("subvendor_id")%> "><%=rs4.getString("companyname")%></option><% } else { %><option value=" j.dropship_vendor= <%=rs4.getString("subvendor_id")%> "><%=rs4.getString("companyname")%></option><% 
		}
		//end if to select subvendor already set
	} 
	//end loop of subvendor companies
} else { 
//show only subvendor related by proxyvendor, or where other vendors are shipping from their warehouse
	sql="SELECT v.id 'subvendor_id', company_name 'companyname'  FROM vendors v, companies co WHERE v.id ='"+proxyVendorId+"' AND v.company_id = co.id union SELECT v.id 'subvendor_id', company_name 'companyname'  FROM vendors v, companies co, warehouses w,jobs j WHERE w.vendor_id='"+proxyVendorId+"' and j.jwarehouse_id=w.id and j.dropship_vendor=v.id AND v.company_id = co.id and j.status_id<>9 and if((select v1.show_other_vendor_jobs_flag from vendors v1 where id='"+proxyVendorId+"')=1,1=1,j.dropship_vendor='"+proxyVendorId+"') ORDER BY companyname";
	//sql = "SELECT distinct v.id 'subvendor_id', company_name 'companyname'  FROM vendors v, companies co WHERE v.id ='"+proxyVendorId+"' AND v.company_id = co.id union SELECT distinct  v.id 'subvendor_id', company_name 'companyname'  FROM vendors v, companies co, warehouses w,products p  left join product_price_codes pc on pc.prod_price_code=p.prod_price_code  WHERE w.vendor_id='"+proxyVendorId+"' and p.default_warehouse_id=w.id and  pc.dropship_vendor=v.id  AND v.company_id = co.id and p.status_id=2 GROUP BY subvendor_id ORDER BY companyname";


//"SELECT v.id 'subvendor_id', company_name 'companyname' FROM vendors v, companies co, contacts c WHERE c.id = " + up.getContactId() + " AND c.proxyvendor = v.id  AND v.company_id = co.id  ORDER BY company_name";

	ResultSet rs4 = st3.executeQuery(sql);
	String selStr="";
	int c=0;
	while (rs4.next()) { 
		selStr+="<option "+((subvendorFilter.equals(" j.dropship_vendor= " + rs4.getString("subvendor_id")+ " ") )?"selected":"")+" value= ' j.dropship_vendor= "+rs4.getString("subvendor_id")+" '>"+rs4.getString("companyname")+"</option>"; 
		c++;
	}//end loop of subvendor companies
	if (c>1){%><option selected value=" 1 = 1 " >All</option><%}
		%><%=selStr%><%
	
}
//end else
%></select>
<!-- End Sub-Vendor Filter -->


<!-- Warehouse Filter -->
<span class=label>&nbsp;&nbsp;&nbsp;&nbsp;Ship From:&nbsp;</span><%
//Check role for all or limited view.  If contact is proxy for vendor, then limited
sql = "SELECT cont.id FROM contacts cont WHERE cont.id = " + up.getContactId() + " AND proxyvendor is not null";
ResultSet rsWa = st3.executeQuery(sql);
while (rsWa.next()) {
	onlySubVendor = "1";
}
%><select name="warehouseFilter" class='otherminder'><%
if (!onlySubVendor.equals("1")) { 
%><option selected value=" 1 = 1 " >All</option><%
	//not a proxy for vendor, show all warehouses
	sql = "SELECT id 'warehouse_id', warehouse_name 'warehousename' FROM warehouses where wh_status=2 ORDER BY warehouse_name";
	rsWa = st3.executeQuery(sql);
	while (rsWa.next()) {
		if (warehouseFilter.equals(" j.jwarehouse_id= " + rsWa.getString("warehouse_id")+ " ")) { %><option selected value=" j.jwarehouse_id= <%=rsWa.getString("warehouse_id")%> "><%=rsWa.getString("warehousename")%></option><% } else { %><option value=" j.jwarehouse_id= <%=rsWa.getString("warehouse_id")%> "><%=rsWa.getString("warehousename")%></option><% 
		}  //end if to select warehouse already set
	}  //end loop of warehouses
} else { 
	boolean whfSel=false;
	int countWh=0;
	String wareFilter="<option value=\" (j.dropship_vendor='"+proxyVendorId+"' ";
	//show only warehouses related to the proxyvendor
	//	--Change subvendor dropdown to show subvendors for proxyvendor and any other vendors that are shipping from their company's warehouses. If more than one subvendor here default to all, otherwise default to single sv.
	//	
	//	-- Change 'rep' dropdown to default to 'all' if supervisor AND proxyvendor
	//default to proxy vendor's default_warehouse_id but show all warehouses for their products	

	sql="SELECT distinct w.id 'warehouse_id', warehouse_name 'warehousename' FROM jobs j,warehouses w, vendors v, contacts c WHERE c.id = " + up.getContactId() + " AND c.proxyvendor = v.id AND (v.company_id = w.company_id or (if(v.show_other_vendor_wh_flag=1,j.dropship_vendor=v.id and j.jwarehouse_id=w.id,v.company_id = w.company_id) ))  ORDER BY warehouse_name";
	//sql = "SELECT distinct w.id 'warehouse_id', warehouse_name 'warehousename' FROM jobs j,warehouses w, vendors v, contacts c WHERE c.id = " + up.getContactId() + " AND c.proxyvendor = v.id AND (v.company_id = w.company_id or (p.company_id=v.company_id and p.default_warehouse_id=w.id))  ORDER BY warehouse_name";
	rsWa = st3.executeQuery(sql);
	while (rsWa.next()) { %><option <%
		if (warehouseFilter.equals(" j.jwarehouse_id= "+rsWa.getString("warehouse_id")+" ")){
			%>Selected<% 
			whfSel=true;
		}
		%> value=" j.jwarehouse_id= <%=rsWa.getString("warehouse_id")%> "><%=rsWa.getString("warehousename")%></option><% 
	wareFilter+=" OR j.jwarehouse_id='"+rsWa.getString("warehouse_id")+"' ";
	countWh++;
	}
	wareFilter+=" )\" "+((whfSel)?"":" Selected ")+" >All</option>";
	//end loop of subvendor companies
	%><%=((countWh>1)?wareFilter:"")%><%
} //end else
%></select>

<!-- End Warehouse Filter -->

<!-- Job Ordered from Subvendor Filter -->
&nbsp;&nbsp;&nbsp;<span class=label>Ordered from Subvendor:</span> <select name="svAssignedFilter" class='otherminder'><option selected value=" AND 1 = 1 ">All</option><option value=" AND (subvendor_reference_data is null or subvendor_reference_data='') " <%=((session.getAttribute("svAssignedFilter")!=null && session.getAttribute("svAssignedFilter").toString().equals(" AND (subvendor_reference_data is null or subvendor_reference_data='') "))?"selected":"")%>>Unassigned</option><option value=" AND (subvendor_reference_data is not null and subvendor_reference_data<>'') " <%=((session.getAttribute("svAssignedFilter")!=null && session.getAttribute("svAssignedFilter").toString().equals(" AND (subvendor_reference_data is not null and subvendor_reference_data<>'') "))?"selected":"")%>>Assigned</option></select></td></tr>
<!-- End Job Ordered from Subvendor Filter -->


<!-- Job Type Filter -->
<tr><td align=right><span class=label>Job Type:</span></td><td><select name="jobTypeFilter" class='otherminder'><option selected value=" AND 1 = 1 ">All</option><%sql = "SELECT id 'jobtypefilterid', value 'jobtypefiltervalue' FROM lu_job_types ORDER BY value";
ResultSet rs5 = st3.executeQuery(sql);
while (rs5.next()) {
	if (jobTypeFilter.equals(" AND ( j.job_type_id = " + rs5.getString("jobtypefilterid") + " )")) { %><option selected value=" AND ( j.job_type_id = <%=rs5.getString("jobtypefilterid")%> )"><%=rs5.getString("jobtypefiltervalue")%></option><% } else { %><option value=" AND ( j.job_type_id = <%=rs5.getString("jobtypefilterid")%> )"><%=rs5.getString("jobtypefiltervalue")%></option><%
	} 
}%></select>
<!-- End Job Type Filter -->


<!-- Design Filter -->
<span class=label>&nbsp;&nbsp;&nbsp;&nbsp; Design:&nbsp;<select name="designFilter" class="otherminder"><option selected value=" AND 1 = 1 ">All</option><%sql = "SELECT id 'designid', value 'design_desc' FROM lu_build_types ORDER BY sequence";
ResultSet rsDes = st3.executeQuery(sql);
while (rsDes.next()) {
	if (designFilter.equals(" AND ( prod.build_type = '" + rsDes.getString("designid") + "' )")){ 
		%><option selected value=" AND ( prod.build_type = '<%=rsDes.getString("designid")%>' )"><%=rsDes.getString("design_desc")%></option><%
	} else { 
		%><option value=" AND ( prod.build_type = '<%=rsDes.getString("designid")%>' )"><%=rsDes.getString("design_desc")%></option><%
 	}
}%></select>
<!-- End Design Filter -->

</td></tr>


<!-- Root Product Filter -->
<tr><td align=right><span class=label>Root Prod:&nbsp;</td><td><select name="rootProdFilter" class='otherminder'><option selected value=" AND 1 = 1 ">All</option><%sql = "SELECT root_prod_code 'rootprodfilter', description 'root_desc' FROM product_roots GROUP BY root_prod_code ORDER BY root_prod_code";
ResultSet rsRP = st3.executeQuery(sql);
while (rsRP.next()) {
	if (rootProdFilter.equals(" AND ( j.root_prod_code = '" + rsRP.getString("rootprodfilter") + "' )")){ 
%><option selected value=" AND ( j.root_prod_code = '<%=rsRP.getString("rootprodfilter")%>' )"><%=rsRP.getString("rootprodfilter")%> - <%=rsRP.getString("root_desc")%></option><% } else { %><option value=" AND ( j.root_prod_code = '<%=rsRP.getString("rootprodfilter")%>' )"><%=rsRP.getString("rootprodfilter")%> - <%=rsRP.getString("root_desc")%></option><%
	}
}%></select>
<!-- End Root Product Filter -->

<!-- Backorder Status Filter -->
<span class=label>&nbsp;&nbsp;&nbsp;&nbsp; Backorder Status:&nbsp;</span><select name="boFilter" class='otherminder'><%
String[] boChoices = {" "," AND (prod.inv_on_order_amount>=prod.inventory_amount AND prod.inventory_product_flag=1) "," AND ((prod.inv_on_order_amount<prod.inventory_amount AND prod.inventory_product_flag=1) or (prod.inventory_product_flag=0)) "};
%><option <%=((boChoices[0].equals(boFilter))?"SELECTED value=\""+boChoices[0]+"\"":" value=\""+boChoices[0]+"\"")%>>All</option><option <%=((boChoices[1].equals(boFilter))?"SELECTED value=\""+boChoices[1]+"\"":" value=\""+boChoices[1]+"\"")%>>Product on Backorder</option><option <%=((boChoices[2].equals(boFilter))?"SELECTED value=\""+boChoices[2]+"\"":" value=\""+boChoices[2]+"\"")%>>Product Available for Shipping</option></select>
<!-- End Backorder Status Filter -->

</td></tr>

<!-- Job Status filter  -->
<tr><td align=right><span class=label>Job&nbsp;Status:</span></td><td>
<select name="archiveFilter" class='otherminder'><%
 		if (archiveFilter.equals(" AND ( j.status_id = 123 ) ")) { %><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) " selected >Hold For Payment</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND j.status_id != 9 ">All Uncancelled</option>
 		<%} else if (archiveFilter.equals(" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ")) { %><option selected value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) ">Hold For Payment</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND j.status_id != 9 ">All Uncancelled</option><% } else if (archiveFilter.equals(" AND (j.status_id = 16 OR j.status_id = 2) ")) { 
	%><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) ">Hold For Payment</option><option selected value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND j.status_id != 9 ">All Uncancelled</option><% } else if (archiveFilter.equals(" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ")) { 
		%><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) ">Hold For Payment</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option selected value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND j.status_id != 9 ">All Uncancelled</option><% } else if (archiveFilter.equals(" AND j.status_id = 112 ")) { %><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) ">Hold For Payment</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option selected value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND j.status_id != 9 ">All Uncancelled</option><% } else if (archiveFilter.equals(" AND j.status_id = 119 ")) { %><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) ">Hold For Payment</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option selected value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND j.status_id != 9 ">All Uncancelled</option><% } else if (archiveFilter.equals(" AND j.status_id = 120 ")) { %><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) ">Hold For Payment</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option selected value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND j.status_id != 9 ">All Uncancelled</option><% } else if (archiveFilter.equals(" AND j.status_id = 9 ")) { %><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) ">Hold For Payment</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option selected value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND j.status_id != 9 ">All Uncancelled</option><% } else if (archiveFilter.equals(" AND j.status_id = 122 ")) { %><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) ">Hold For Payment</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option selected value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND j.status_id != 9 ">All Uncancelled</option><% } else if (archiveFilter.equals(" AND j.status_id != 120 AND j.status_id != 9 ")) { %><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) ">Hold For Payment</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option> <option selected value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option value=" AND j.status_id != 9 ">All Uncancelled</option><% } else { %><option value=" AND ((j.status_id != 120 AND j.status_id != 9 AND j.status_id != 119 AND j.status_id != 122) OR (j.status_id = 119 AND (j.billable - j.billed != 0))) ">Active</option><option value=" AND ( j.status_id = 123 ) ">Hold For Payment</option><option value=" AND (j.status_id = 16 OR j.status_id = 2) ">To be Quoted/Confirmed</option><option value=" AND (j.status_id = 17 OR j.status_id = 99 OR j.status_id = 3) ">Quote/Chg to be Appvd</option><option value=" AND j.status_id = 112 ">In Progress</option><option value=" AND j.status_id = 119 ">Completed</option><option value=" AND j.status_id = 120 ">Closed</option><option value=" AND j.status_id = 9 ">Cancelled</option><option value=" AND j.status_id = 122 ">On Hold</option><option value=" AND j.status_id != 120 AND j.status_id != 9 ">Open</option><option selected value=" AND j.status_id != 9 ">All Uncancelled</option><% } %></select>
<!-- End Job Status filter  -->
		
		
<!-- File Approvals Filter -->
<span class=label>&nbsp;&nbsp;&nbsp;&nbsp; File&nbsp;Approval Status:&nbsp;</span><select name="actionFilter" class='otherminder'><%
String[] afChoices = {" AND 1=1 ","1","2","3","4","5","6"};
%><option <%=((afChoices[0].equals(actionFilter))?"SELECTED value=\""+afChoices[0]+"\"":" value=\""+afChoices[0]+"\"")%>>All</option><option <%=((afChoices[1].equals(actionFilterStr))?"SELECTED value=\""+afChoices[1]+"\"":" value=\""+afChoices[1]+"\"")%>>to Submit</option><option <%=((afChoices[2].equals(actionFilterStr))?"SELECTED value=\""+afChoices[2]+"\"":" value=\""+afChoices[2]+"\"")%>>Appvl O/S - 0</option><option <%=((afChoices[3].equals(actionFilterStr))?"SELECTED value=\""+afChoices[3]+"\"":" value=\""+afChoices[3]+"\"")%>>Appvl O/S - 3</option><option <%=((afChoices[4].equals(actionFilterStr))?"SELECTED value=\""+afChoices[4]+"\"":" value=\""+afChoices[4]+"\"")%>>Accepted</option><option <%=((afChoices[5].equals(actionFilterStr))?"SELECTED value=\""+afChoices[5]+"\"":" value=\""+afChoices[5]+"\"")%>>Ready for Final</option><option <%=((afChoices[6].equals(actionFilterStr))?"SELECTED value=\""+afChoices[6]+"\"":" value=\""+afChoices[6]+"\"")%>>Finalized</option></select>
<!-- End File Approvals Filter -->


<!-- Bill/Pmt Status Filter -->
<span class=label>&nbsp;&nbsp;&nbsp;&nbsp; Bill/Pmt&nbsp;Status:&nbsp;</span><select name="collectedFilter" class='otherminder'><%
 	if (collectedFilter.equals(" AND (j.billable - j.billed <> 0) ")) { %><option value=" AND 1 = 1 ">All</option><option selected value=" AND (j.billable - j.billed <> 0) ">Unbilled</option><option value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option><option value=" AND (j.billed - j.collected > 0) ">Balance Due</option><option value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option><option value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><% } else if (collectedFilter.equals(" AND (j.billable - j.billed <= 0 AND j.billable != 0) ")) { %><option value=" AND 1 = 1 ">All</option><option value=" AND (j.billable - j.billed <> 0) ">Unbilled</option><option selected value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option><option value=" AND (j.billed - j.collected > 0) ">Balance Due</option><option value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option><option value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><% } else if (collectedFilter.equals(" AND (j.billed - j.collected > 0) ")) { %><option value=" AND 1 = 1 ">All</option><option value=" AND (j.billable - j.billed <> 0) ">Unbilled</option><option value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option><option selected value=" AND (j.billed - j.collected > 0) ">Balance Due</option><option value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option><option value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><% } else if (collectedFilter.equals(" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ")) { %><option value=" AND 1 = 1 ">All</option><option value=" AND (j.billable - j.billed <> 0) ">Unbilled</option><option value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option><option value=" AND (j.billed - j.collected > 0) ">Balance Due</option><option selected value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option><option value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><% } else if (collectedFilter.equals(" AND (j.billable - j.collected <= 0 AND j.billable != 0) ")) { %>
  <option value=" AND 1 = 1 ">All</option><option value=" AND (j.billable - j.billed <> 0) ">Unbilled</option><option value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option><option value=" AND (j.billed - j.collected > 0) ">Balance Due</option><option value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option><option selected value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><% } else { %><option selected value=" AND 1 = 1 ">All</option><option value=" AND (j.billable - j.billed <> 0) ">Unbilled</option><option value=" AND (j.billable - j.billed <= 0 AND j.billable != 0) ">Billed in Full</option><option value=" AND (j.billed - j.collected > 0) ">Balance Due</option><option value=" AND (j.billed - j.collected <= 0 AND j.billable != 0 AND j.billed != 0) ">Paid to Date</option><option value=" AND (j.billable - j.collected <= 0 AND j.billable != 0) ">Paid in Full</option><% } %></select>
<!-- End Bill/Pmt Status Filter -->
</td></tr>
<tr><td colspan="2">

<!-- Date Range Filter -->
<table border=0>
<tr><td><span class=label>&nbsp;&nbsp;&nbsp;&nbsp; Date&nbsp;Range:&nbsp;</span><select name="dateFilterStr" class='otherminder'><%
String[] dtChoices = {" AND 1=1 "," AND (j.order_date<=dateEnd and j.order_date>=dateBegin) "," AND (j.confirmed_date<=dateEnd and j.confirmed_date>=dateBegin) "," AND (j.completed_date<=dateEnd and j.completed_date>=dateBegin) "," AND (j.post_date<=dateEnd and j.post_date>=dateBegin) "};

%><option <%=((dtChoices[0].equals(dateFilterStr))?"SELECTED value=\""+dtChoices[0]+"\"":" value=\""+dtChoices[0]+"\"")%>>All (ignore dates)</option><option <%=((dtChoices[1].equals(dateFilterStr))?"SELECTED value=\""+dtChoices[1]+"\"":" value=\""+dtChoices[1]+"\"")%>>Date Ordered</option><option <%=((dtChoices[2].equals(dateFilterStr))?"SELECTED value=\""+dtChoices[2]+"\"":" value=\""+dtChoices[2]+"\"")%>>Date Confirmed</option><option <%=((dtChoices[3].equals(dateFilterStr))?"SELECTED value=\""+dtChoices[3]+"\"":" value=\""+dtChoices[3]+"\"")%>>Date Completed</option><option <%=((dtChoices[4].equals(dateFilterStr))?"SELECTED value=\""+dtChoices[4]+"\"":" value=\""+dtChoices[4]+"\"")%>>Date Posted</option></select></td><td class="minderHeader" style="text-align:right">Date From:</td>
 	<td>&nbsp;&nbsp;<input type="hidden" name="dateFrom" id="f_datefrom_d"><span class="lineitemsselected" id="show_d"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c" style="cursor: pointer; border: 1px solid red;" title="Date selector" onmouseover="this.style.background='red';" onmouseout="this.style.background=''" />
 	
<script type="text/javascript">
 Calendar.setup({
 inputField: "f_datefrom_d", ifFormat: "%Y-%m-%d",displayArea: "show_d",daFormat: "%m-%d-%Y", button:"f_trigger_c", align: "BR", singleClick: true}); var d=new Date();
 document.forms[0].dateFrom.value=<%=((dateFrom.equals(""))?"d.getFullYear()+'-'+(d.getMonth()+1)+'-01'":"'"+dateFrom+"'")%>; 
 document.getElementById('show_d').innerHTML=<%=((dateFrom.equals(""))?"(d.getMonth()+1)+'-01-'+d.getFullYear()":"'"+dateFrom+"'")%>;
</script></td><td class="minderHeader" style="text-align:right">&nbsp;Date To:&nbsp;<u>&nbsp;</td>
<td>&nbsp;&nbsp;<input type="hidden" name="dateTo" id="f_dateto_d"><span class="lineitemsselected" id="show_d2"></span>&nbsp;<img src="/javascripts/jscalendar/img.gif" align="absmiddle" id="f_trigger_c2" style="cursor: pointer; border: 1px solid red;" title="Date selector" onmouseover="this.style.background='red';" onmouseout="this.style.background=''" />
<script type="text/javascript">
Calendar.setup({
	inputField: "f_dateto_d", ifFormat : "%Y-%m-%d", displayArea : "show_d2", daFormat : "%m-%d-%Y", button : "f_trigger_c2", align: "BR", singleClick : true });
	var d=new Date();
	document.forms[0].dateTo.value=<%=((dateTo.equals(""))?"d.getFullYear()+'-'+(d.getMonth()+1)+'-'+d.getDate()":"'"+dateTo+"'")%>; document.getElementById('show_d2').innerHTML=<%=((dateTo.equals(""))?"(d.getMonth()+1)+'-'+d.getDate()+'-'+d.getFullYear()":"'"+dateTo+"'")%>;
</script>
<!-- End Date Range Filter -->
</td></tr></table>
</td></tr>
</table>
</div>


<div id='sortAndGo'><!-- Sort Filter -->
Sort&nbsp;by:&nbsp;<select name="sortFilter" class='sortBy'><% if (sortFilter.equals(" ORDER BY o.date_created, j.project_id, j.id DESC")) { %><option selected value=" ORDER BY o.date_created, j.project_id, j.id DESC">Date Ordered</option><option value=" ORDER BY j.product_code, o.date_created, j.project_id, j.id DESC">Prod, Date Ordered</option><option value=" ORDER BY c3.company_name, o.date_created, j.project_id, j.id DESC">Client Co., Date Ordered</option><% } else if (sortFilter.equals(" ORDER BY j.product_code, o.date_created, j.project_id, j.id DESC")) { %><option value=" ORDER BY o.date_created, j.project_id, j.id DESC">Date Ordered</option><option selected value=" ORDER BY j.product_code, o.date_created, j.project_id, j.id DESC">Prod, Date Ordered</option><option value=" ORDER BY c3.company_name, o.date_created, j.project_id, j.id DESC">Client Co., Date Ordered</option><% } else { %><option value=" ORDER BY o.date_created, j.project_id, j.id DESC">Date Ordered</option><option value=" ORDER BY j.product_code, o.date_created, j.project_id, j.id DESC">Prod, Date Ordered</option><option selected value=" ORDER BY c3.company_name, o.date_created, j.project_id, j.id DESC">Client Co., Date Ordered</option><% } %></select>
<!-- END Sort Filter -->
&nbsp;&nbsp;&nbsp;<input type="submit" name="Submit" value=" APPLY FILTERS " class='submit'></div></div></form><%
conn2.close();
%>