<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.text.*,java.sql.*,java.util.*,com.marcomet.environment.*,com.marcomet.jdbc.*,com.marcomet.tools.*" %>
<%@ taglib uri="/WEB-INF/tld/iterationTagLib.tld" prefix="iterate" %>
<%@ taglib uri="/WEB-INF/tld/taglib.tld" prefix="taglib" %>
<%
Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
String tempString ="";
StringTool str=new StringTool();
DecimalFormat nf = new DecimalFormat("#,###.00");
DecimalFormat decFormatter = new DecimalFormat("#,###.##");
String adNumber="";
int numLines=0;
String keyStr="";
int x=0;
String jobId=((request.getParameter("jobId")==null)?"":request.getParameter("jobId"));
String ioNumber=((request.getParameter("ioNumber")==null)?"":request.getParameter("ioNumber"));
String ioId=((request.getParameter("ioId")==null)?"":request.getParameter("ioId"));
String ioNum="";
String prodId="";
String hRow="<table id='io' class='sortable' width='100%' cellpadding=2><tr>";
String contPropSQL="Select distinct j.site_number as 'property_code',cp.title as 'title' from v_contact_properties cp left join jobs j on cp.property_code=j.site_number where property_code<>0 and j.id is not null and contact_id="+(String)session.getAttribute("contactId")+" order by property_code";
ResultSet rsContProds = st.executeQuery(contPropSQL);
int cnt=0;
String propFilter="";
String propNum="";
if (!(((com.marcomet.users.security.RoleResolver)session.getAttribute("roles")).isSiteHost())){
	while(rsContProds.next()){
		propFilter+=((cnt==0)?" AND (j.site_number='"+rsContProds.getString("property_code")+"' ":" OR j.site_number='"+rsContProds.getString("property_code")+"' ");
		cnt++;
		propNum=rsContProds.getString("title");
	}
}

propFilter+=((propFilter.equals(""))?"":") ");
String selected=((request.getParameter("selectedTab")==null)?"1":request.getParameter("selectedTab"));
String ioSQL="Select distinct j.product_id as 'H:PR:product_id', if(j.thumbnail_file<>'' and j.thumbnail_file is not null,concat('<img src=\"',j.thumbnail_file,'\" border=0>'),'') as 'L:',js.job_id 'J:Job #',jsa.value as 'K:L:Production-Ad-Number', js.value 'P:L:IO-Number',if(i.id is null,'',concat('IO_',replace(i.io_number,'-0-','-NTH-'),'.pdf')) as 'H:File',jsm.value as 'L:Media-Type',jsmv.value 'L:Media-Vehicle',Region 'L:Region',jsu.value as  'L:Unit~Size',if( DATE_FORMAT(jsid.value,'%m/%d/%Y') is null, jsid.value,DATE_FORMAT(jsid.value,'%m/%d/%Y')) 'L:Issue-Date',if(i.id is null,'N/A',i.ad_number) 'L:IO-Ad-Number' ,concat(jsjc.value,if(jsc.value is not null and jsc.value<>''  and jsjc.value is not null and jsjc.value<>''   ,'<br>',''),jsc.value) as 'L:Comments'  from jobs j left join job_specs jsa on j.id=jsa.job_id and jsa.cat_spec_id='11036' left join job_specs jsu on j.id=jsu.job_id and jsu.cat_spec_id='11037' left join job_specs jsm on j.id=jsm.job_id and jsm.cat_spec_id='11039'  left join job_specs jsmv on j.id=jsmv.job_id and jsmv.cat_spec_id='11041'   left join job_specs jsc on j.id=jsc.job_id and jsc.cat_spec_id='11040'  left join job_specs jsid on j.id=jsid.job_id and jsid.cat_spec_id='11042'  left join job_specs jsjc on j.id=jsjc.job_id and jsjc.cat_spec_id='11034' left join job_specs js on js.job_id=j.id AND js.cat_spec_id='11035' left join insertions i on js.value=i.io_number and js.id is not null and js.value<>'0' where jsa.id is not null and  jsa.value =concat(j.site_number,'_',j.id)   "+propFilter+" order by jsa.value";

%>
<html><head><title>Print Ad Jobs</title>
<link rel="stylesheet" href="<%=(String)session.getAttribute("siteHostRoot")%>/styles/vendor_styles.css" type="text/css">
<script language="JavaScript" src="/javascripts/mainlib.js"></script>
</head><body><jsp:include page="/sitehosts/marketdolce/includes/MediaTabBar.jsp" >
	<jsp:param name="selectedTab" value="<%=selected%>" />
</jsp:include>
<div class='subtitle'>Print Ads <%=((cnt==1)?"For Property: "+propNum:"")%></div>&nbsp;
<table><tr><%

ResultSet rs = st.executeQuery(ioSQL);
ResultSetMetaData rsmd = rs.getMetaData();
int numberOfColumns = rsmd.getColumnCount();
tempString = null;
Vector headers  = new Vector(15);
for (int i=1 ;i <= numberOfColumns; i++){
	tempString = new String ((String) rsmd.getColumnLabel(i));
	headers.add(tempString);
	if (tempString.indexOf("H:")==-1){
tempString=str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring( str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(str.replaceSubstring(tempString,"H:", ""),"F:", ""),"B:", ""),"K:", ""),"C:", ""),"L:", ""),"^"," <br /> "),"-", "&nbsp;"),"P:", ""),"PR:", ""),"J:", "");
		%><td  class='tableheader' ><%=tempString%></td><%
	}
}
%><td  class='tableheader' >ACTION</td>
</tr>
<%
x=0;
numLines=0;
boolean showAction=true;
while (rs.next()){
	boolean ioRow=false;
	%><tr><%
	for (int i=0;i < numberOfColumns; i++){
		String columnName = (String) headers.get(i);
		String columnValue=((columnName.indexOf("F:")>-1)?nf.format(rs.getDouble(columnName)):((rs.getString(columnName)==null)?"":rs.getString(columnName) ));
		if(columnName.indexOf("H:")>-1){
			if(columnName.indexOf("PR:")>-1){
				prodId=columnValue;
			}else{	
				keyStr=columnValue;
			}
		}else if(columnName.indexOf("K:")>-1){
			adNumber=columnValue;
			%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=((showAction)?columnValue:"<a href=\"javascript:pop('/popups/JobDetailsPage.jsp?jobId="+columnValue.substring(columnValue.indexOf("_")+1, columnValue.length())+"','700','300')\" class='minderLink'>"+columnValue+"</a>")%></td><%	
		}else if(columnName.indexOf("J:")>-1){
			%><td class='lineitems' align='center'><a href="javascript:pop('/popups/JobDetailsPage.jsp?jobId=<%=rs.getString("J:Job #")%>','700','300')" class='minderLink'><%=columnValue%></a></td><%	
		}else if(columnName.indexOf("P:")>-1){
			ioNum=columnValue;
			%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><a href='<%=(String)session.getAttribute("siteHostRoot")+"/fileuploads/product_images/"+rs.getString("H:File")%>' class='minderLink' target='_blank'><%=columnValue%></a></td><%		
		}else{
			%><td class='lineitems' align='<%=((columnName.indexOf("L:")>-1)?"left":((columnName.indexOf("C:")>-1)?"center":"right"))%>'><%=columnValue%></td><%
		}
	}
	%><td class='lineitems' align='center'>
	<%=((ioId.equals(""))?"":"<a href='/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=10015&jobTypeId=15&serviceTypeId=990700&productId="+prodId+"&ioNumber="+ioNum+"&specId1=6052&6052=REPRINT&specId=6045&6045="+adNumber+"&postProdCost=true&prePopTable=v_insertions&prePopId="+ioId+"' class='greybutton' target='_top'>PICKUP AD</a>&nbsp;&nbsp;")%><a href='/frames/InnerFrameset.jsp?contents=/servlet/com.marcomet.catalog.CatalogNavigationServlet?offeringId=1001&jobTypeId=1&serviceTypeId=0&productId=8189&1977=AD Number:<%=adNumber%>' class='greybutton' target='_top'>REPRINT AS FLYER</a>
	</td><%
	x++;
	%></tr>
	<%
} 
	%></table><%
if (x==0){
	%><div class='subtitle'>No ads have been created yet for this property.</div><%
}  
	st.close();
	conn.close();
%></body></html>