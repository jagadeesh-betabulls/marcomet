<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.util.*,java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.users.security.*,java.io.*;" %>
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%
SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 
boolean useSavedBrand=((sl.getValue("site_hosts","id",shs.getSiteHostId(),"keep_last_brand_choice").equals("1"))?true:false);
String shId=((request.getParameter("shId")==null)?"":request.getParameter("shId"));
String brandCode=((session.getAttribute("brandCode")==null || session.getAttribute("brandCode").toString().equals(""))?"":(String)session.getAttribute("brandCode"));
brandCode=((request.getParameter("bc")==null)?brandCode:request.getParameter("bc"));
String shQuery = "";
boolean setParams=((request.getParameter("setParams")==null)?false:true);
boolean showBrandDropdown=((request.getParameter("showBC")==null)?false:true);
String lastBrandCode=((useSavedBrand)?sl.getValue("contacts","id",(String)session.getAttribute("contactId"),"last_brand_chosen"):"");

if(lastBrandCode!=null && !lastBrandCode.equals("")){
	session.setAttribute("brandCode",lastBrandCode);
}
ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
String homeDir = bundle.getString("transfersPrefix")+"html/";



Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
Statement st = conn.createStatement();

if((session.getAttribute("brandCode")==null || !session.getAttribute("brandCode").toString().equals(brandCode)) && !brandCode.equals("")){
	//RECORD THE LAST BRAND CHOSEN
	if(!shId.equals("")){
		if(useSavedBrand){
			st.execute("update contacts set last_sitehost_id='"+shId+"',last_brand_chosen='"+brandCode+"' where id="+(String)session.getAttribute("contactId"));
		}
		shQuery = "SELECT sh.*,sh1.site_type as siteType from site_hosts sh,site_hosts sh1 where sh1.id="+shs.getSiteHostId()+" and sh.id="+shId;
		ResultSet shRS = st.executeQuery(shQuery); 
		
		if (shRS.next()) { 
			session.setAttribute("tmpSHRoot","/sitehosts/"+shRS.getString("site_host_name"));
			session.setAttribute("tmpSHCompanyId",shRS.getString("company_id"));
			session.setAttribute("tmpSHId",shId);
			session.setAttribute("isAggregator",((shRS.getString("siteType")!= null && shRS.getString("siteType").equals("aggregator"))?"true":"false"));
		}
		shRS.close();
	}
	if(!brandCode.equals("")){
		shQuery = "SELECT * from brands where brand_code='"+brandCode+"'";
		ResultSet shRS = st.executeQuery(shQuery); 
		
		if (shRS.next()) { 
			session.setAttribute("tmpPLSegment",shRS.getString("prod_line_segment"));
			session.setAttribute("brandCode",brandCode);
		}
		shRS.close();
	}
}

int numLogos=1;

shQuery="Select distinct sh.id,sh.domain_name,b.brand_code,b.brand_name as 'brandName',concat('/images/brand_logos/',l.logo_image) as logo from brands b left join site_hosts sh on sh.company_id=b.company_id left join logos l on l.brand_code=b.brand_code where l.active=1 and b.brand_code='"+brandCode+"' and b.active=1 order by b.brand_name";

ResultSet shRS = st.executeQuery(shQuery); 
int x=0;
int y=1;
if(session.getAttribute("brandCode")!=null){
	%>
	<div align="center" class="subtitle" style="padding-bottom:12px;padding-top:4px;">
	<%
	String logoFile="";
	boolean logoFileMissing=false;
	if (shRS.next()) {
		if (shRS.getString("logo")!=null && !shRS.getString("logo").equals("")){
			File source = new File(homeDir+shRS.getString("logo"));
			if(source.exists()){
				%>Currently Selected:<br><img src='<%=shRS.getString("logo")%>' border=0 ><%
			}else{
				logoFileMissing=true;
			}
		}else{
			logoFileMissing=true;
		}
	}
	%><%=((logoFileMissing)?"Currently Selected:<br><div style='font-size:12pt;'>"+shRS.getString("brandName")+"</div><br>":"")%></div><%
	shRS.close();
}else{
%><table width="80%" border="0" cellpadding="10"><tr>
<%
int logoCount=0;
while (shRS.next()) { 
	logoCount=logoCount+1;
	if(x > 4 ){
		x=0;
		%>
		</tr>
		<tr><%
	}
	x++;
	%>
	<td width="25%" valign="middle" style="text-align:left;border:<%=((session.getAttribute("brandCode")==null || !session.getAttribute("brandCode").toString().equals(shRS.getString("b.brand_code")))?"0":"3px solid #9a9a9a")%>;"><a href="<%=(String)session.getAttribute("siteHostRoot")%>/contents/Home.jsp?bc=<%=shRS.getString("b.brand_code")%>&shId=<%=shRS.getString("sh.id")%>"><img src='<%=shRS.getString("logo")%>' border=0 ></a> </td><%
	y++;
}
shRS.close();
while(x<4){
	%>
	<td>&nbsp;</td><%
	x++;
}%>
</tr></table><%
}
st.close();
conn.close();
%>
