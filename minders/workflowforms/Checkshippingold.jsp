<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%@ include file="/includes/SessionChecker.jsp" %>
<jsp:useBean id="cjc" class="com.marcomet.workflow.actions.CalculateJobCosts" scope="session" />
<html><head><title>Import Shipping Records</title>
<link rel="stylesheet" href="/htdocs/commerce/styles/marcomet.css" type="text/css"></head><body><p class='Title'>Importing Shipping Records</p><%
String query = "Select t.*,j.product_id,j.quantity,if(p.root_inv_prod_id=0,p.id,p.root_inv_prod_id) root_inv,p.prod_code from tmp_shipping_data t,jobs j,products p left join shipping_data s on s.job_id=t.job_id and s.reference=t.reference where t.job_id=j.id and s.id is null and j.product_id=p.id";
int x=0;
SimpleConnection sc = new SimpleConnection();
Connection conn = sc.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(query);

while (rs.next()) {
	query = "insert into shipping_data set job_id ='"+rs.getString("t.job_id")+"',user_id ='"+rs.getString("t.user_id")+"',date ='"+rs.getString("t.date")+"',method ='"+rs.getString("t.method")+"',reference ='"+rs.getString("t.reference")+"',vendor_ship_reference ='"+rs.getString("t.vendor_ship_reference")+"',cost ='"+rs.getString("t.cost")+"',handling ='"+rs.getString("t.handling")+"',mu ='"+rs.getString("t.mu")+"',fee ='"+rs.getString("t.fee")+"',price ='"+rs.getString("t.price")+"',shipped_to ='"+rs.getString("t.shipped_to")+"',shipped_from ='"+rs.getString("t.shipped_from")+"',description ='"+rs.getString("t.description")+"',status ='"+rs.getString("t.status")+"',product_id ='"+rs.getString("j.product_id")+"',shipping_quantity ='"+rs.getString("j.quantity")+"',warehouse_id ='"+rs.getString("t.warehouse_id")+"'";

	Statement st2 = conn.createStatement();
	st2.execute(query);
	query = "insert into inventory set adjustment_notes='PLI Shipment, auto-imported for DI Keycard Holders',root_inv_prod_code='"+rs.getString("p.prod_code")+"',adjustment_type_id='1',adjustment_action='0',product_id='"+rs.getString("j.product_id") +"',root_inv_prod_id='"+rs.getString("root_inv")+"',amount=-"+rs.getString("j.quantity")+",adjustor_contact_id ='"+rs.getString("t.user_id")+"',adjustment_date ='"+rs.getString("t.date")+"',warehouse_id ='"+rs.getString("t.warehouse_id")+"'";
	st2.execute(query);
		
	query="update jobs set completed_date=Now(), last_status_id=119,status_id=120,vendor_notes='<div class=notes>Daysinn cards, shipped and closed.</div>',subvendor_reference_data="+rs.getString("t.vendor_ship_reference")+" where id="+rs.getString("t.job_id");
	st2.execute(query);
	
	cjc.calculate(rs.getString("t.job_id"));
	
	x++;
	%>Job <%=x%> Updated:<%=rs.getString("t.job_id")%><br><%
}
sc.close();
%><hr><%=x%> Shipping and inventory records created, jobs updated.</body></html>