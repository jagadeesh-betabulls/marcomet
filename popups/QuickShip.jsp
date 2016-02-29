<%@ page import="java.sql.*,java.util.*,java.text.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*,com.marcomet.tools.*;" %>
<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%
//SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st1 = conn.createStatement();

if (!(request.getParameter("cost").equals("")) && !(request.getParameter("cost") == null)) {
	try {
		if (conn == null) {			
			conn = DBConnect.getConnection();
		}
		String userid = (String)session.getAttribute("contactId");
		String query = "insert into shipping_data (date, method, reference, cost, mu, fee, price, job_id, user_id, shipped_to, shipped_from, description, status,shipping_quantity,product_id,warehouse_id,handling,subvendor_handling,shipping_account_vendor_id,subvendor_id,shipping_vendor_id,adjustment_flag"+((request.getParameter("job_post_date").equals("0"))?"":",accrued_date")+") values (?,?,?,?,?,?,?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?"+((request.getParameter("job_post_date").equals("0"))?"":",?")+")";
		PreparedStatement shipping = conn.prepareStatement(query);
		shipping.clearParameters();
		shipping.setString(1, request.getParameter("adjdate"));
		shipping.setString(2, request.getParameter("method"));
		shipping.setString(3, request.getParameter("reference"));
		shipping.setString(4, request.getParameter("cost"));
		shipping.setString(5, request.getParameter("mu"));
		shipping.setString(6, request.getParameter("fee"));
		shipping.setString(7, request.getParameter("price"));
		shipping.setString(8, request.getParameter("jobId"));
		shipping.setString(9, userid);
		shipping.setString(10, request.getParameter("shippedTo"));
		shipping.setString(11, request.getParameter("shippedFrom"));
		shipping.setString(12, request.getParameter("description"));
		shipping.setString(13, request.getParameter("shippingStatus"));
		shipping.setString(14, request.getParameter("quantity"));
		shipping.setString(15, request.getParameter("productId"));	
		shipping.setString(16, request.getParameter("warehouse_id"));
		shipping.setString(17, request.getParameter("handling"));
		shipping.setString(18, request.getParameter("svhandling"));
		shipping.setString(19, request.getParameter("shippingAccountVendorId"));				
		shipping.setString(20, request.getParameter("subvendorId"));
		shipping.setString(21, request.getParameter("shippingVendorId"));
		shipping.setString(22, request.getParameter("adjustment_flag"));
		if (!(request.getParameter("job_post_date").equals("0"))){
			shipping.setString(23, request.getParameter("job_post_date"));
		}
		shipping.execute();

	} finally {
		st.close();
		st1.close();
		conn.close();
	}
}
%>Shipped.