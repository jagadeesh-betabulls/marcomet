<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="cjc" class="com.marcomet.workflow.actions.InventoryUpdater" scope="session" />
<html><head><title>Update Product Inventory Changes</title>
<link rel="stylesheet" href="/htdocs/commerce/styles/marcomet.css" type="text/css"></head><body><p class='Title'>Update Accrued AP  Fields</p><table><tr><td>JOBID</td><td>ACCRUED PO BALANCE</td><td>ACCRUED SHIPPING BALANCE</td></tr><%
int x=0;
int y=0;

String productId=((request.getParameter("productId")==null || request.getParameter("productId").equals(""))?"0":request.getParameter("productId"));
String jobId=((request.getParameter("jobId")==null || request.getParameter("jobId").equals(""))?"0":request.getParameter("jobId"));

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();

//UPDATE PRIMARY TABLE WITH SUMMARY AMOUNTS 
//Cycle through all records and update the summary fields
String accruedPO="0";
String accruedShipBal="0";


String primarySQL="SELECT * from jobs WHERE PO_closed=0 "+((jobId.equals("0"))?"":" AND id="+jobId);
		 
ResultSet rsRecords=st.executeQuery(primarySQL);
while(rsRecords.next()){
		jobId=rsRecords.getString("id");
			
		//get the summary fields
		String accruedSQL="select (j.accrued_po_cost - sum(apid.ap_purchase_amount)) as accrued_po, (j.accrued_shipping - sum(apid.ap_shipping_amount)) as Accrued_Ship_Bal from  jobs j, ap_invoice_details apid	where j.id="+jobId+" AND apid.jobid = j.id group by j.id";
		ResultSet rsAccrued=st3.executeQuery(accruedSQL);
		if(rsAccrued.next()){
			accruedPO=rsAccrued.getString(1);
			accruedShipBal=rsAccrued.getString(2);
		}else{
			accruedPO="0";
			accruedShipBal="0";
		}
		y++;
		//update the primary table
		String updatePrimary="update jobs j set j.Accrued_PO_Bal = "+accruedPO+", j.Accrued_Ship_Bal = "+accruedShipBal+", j.Last_Accrual_Refresh_Date = Now() WHERE id="+jobId;	
			st3.executeQuery(updatePrimary);
			
		}
	st.close();
	st2.close();
	st3.close();
	conn.close();
%><hr><%=y%>Job records updated.</body></html>