<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,com.marcomet.users.security.*,com.marcomet.tools.*,com.marcomet.environment.*,java.util.*,com.marcomet.catalog.*,com.marcomet.commonprocesses.*,com.marcomet.jdbc.*;" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<html>
  <head>
    <title>Processing Old Jobs</title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="/styles/marcomet.css" type="text/css">
    <script language="javascript" src="/javascripts/mainlib.js"></script>
    <script>
    var wait=10;
    function fillCart(urlstr,framestr) {
    	document.getElementById(framestr).src=urlstr;
    	wait=wait+120000
    }
    </script>
  </head>
  <body><iframe name="contents" id="contents" width="1" height="1" border=0></iframe>  <iframe name="results" id="results" width="100%" height="100%" border=0></iframe><script>
  <%
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
Statement st2 = conn.createStatement();
Statement st3 = conn.createStatement();
Statement st4 = conn.createStatement();
String jobId="0";
Integer timer=10;
session.setAttribute("reprintJob","true");
session.setAttribute("lastRow","0");
String orderId=((request.getParameter("orderId")==null)?"0":request.getParameter("orderId"));
String query = ((orderId.equals("0"))?"SELECT distinct o.id from orders o,projects p, jobs j WHERE recalc_flag=1 and j.shipment_id=0 AND j.project_id=p.id and p.order_id=o.id ORDER BY o.id":"SELECT distinct o.id from orders o,projects p, jobs j WHERE j.shipment_id=0 AND j.project_id=p.id and p.order_id=o.id and o.id='"+orderId+"' ORDER BY j.id");


ResultSet rs = st.executeQuery(query);
while (rs.next()) {
	query = "SELECT distinct j.id,l.state as zipToStateCode,l.zip as zipTo from orders o,projects p, jobs j left join locations l on l.contactid=j.jbuyer_contact_id WHERE recalc_flag=1 and j.shipment_id=0 AND j.project_id=p.id and p.order_id=o.id and o.id="+rs.getString("o.id");
	ResultSet rsj = st2.executeQuery(query);
	while (rsj.next()) {
		%><%
    		jobId = rsj.getString("j.id");
    		session.setAttribute("priorJobId",jobId);
			session.setAttribute("lastCol","0");
			session.setAttribute("zipTo",rsj.getString("zipTo"));
			session.setAttribute("zipToStateCode",rsj.getString("zipToStateCode"));
			query = "SELECT count(pp.id) as lastCol,p.*,os.job_type_id,os.service_type_id from products p left join offerings o on o.id=p.offering_id left join offering_sequences os on os.offering_id=o.id left join product_prices pp on pp.prod_price_code=p.prod_price_code, jobs j where pp.quantity<j.quantity and p.id=j.product_id and j.id='"+jobId+"' group by p.prod_price_code";
    		ResultSet rsp = st3.executeQuery(query);
				if(rsp.next()){
					session.setAttribute("lastCol",((rsp.getString("lastCol")==null)?"0":rsp.getString("lastCol")));%>
	setTimeout(fillCart("/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=<%=rsp.getString("offering_id")%>&jobTypeId=<%=rsp.getString("job_type_id")%>&serviceTypeId=<%=rsp.getString("service_type_id")%>&productId=<%=rsp.getString("id")%>&priorJobId=<%=jobId%>","contents"),wait);
<%
		}
		rsp.close();
    	}
    	rsj.close();
    	System.out.println("priorJobId is "+session.getAttribute("priorJobId"));
//process the cart...
%></script>
<script>
	setTimeout(fillCart("/catalog/summary/ProcessOldOrders15.jsp","results"),wait);
</script><%
    }

    rs.close();

    st.close();
    st2.close();
    st3.close();
    st4.close();
    conn.close();
  %>
  </body>
</html>
