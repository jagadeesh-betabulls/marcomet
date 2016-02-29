<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="javax.servlet.*,javax.servlet.http.*,java.sql.*,java.util.*,com.marcomet.users.security.*, com.marcomet.jdbc.*, com.marcomet.environment.*;" %>
<jsp:useBean id="str" class="com.marcomet.tools.StringTool" scope="session" /><%

Connection conn = DBConnect.getConnection();
Statement st = conn.createStatement();
String regionId=((request.getParameter("regionId")==null)?"":request.getParameter("regionId"));
boolean editorRole=((((RoleResolver)session.getAttribute("roles")).roleCheck("editor")) || (((RoleResolver)session.getAttribute("roles")).roleCheck("ROC_editor")) || (((RoleResolver)session.getAttribute("roles")).roleCheck("ROC1_editor")) || (((RoleResolver)session.getAttribute("roles")).roleCheck("ROC"+regionId+"_editor")));
boolean editor=((session.getAttribute("editorOff")!=null && session.getAttribute("editorOff").equals("true"))?false:editorRole);
String title="";
String menuId=((request.getParameter("menuId")==null)?"":request.getParameter("menuId"));
String pageId=((request.getParameter("pageId")==null)?"":request.getParameter("pageId"));
String pageName=((request.getParameter("pageName")==null)?"":request.getParameter("pageName"));
String regionName=((request.getParameter("regionName")==null)?"":request.getParameter("regionName"));

boolean showAll=((request.getParameter("showAll")==null)?false:true);

String pageNameStr="";
if (showAll){
	pageNameStr=((regionId.equals(""))?" page_name like '%rg-1' or ":" page_name like '%rg-"+regionId+"' or ");
}else{
	pageNameStr=((pageName.equals(""))?((regionId.equals(""))?"":" page_name='"+pageName+((regionId.equals(""))?"":"rg-"+regionId)+"' or "):" page_name='"+pageName+((regionId.equals(""))?"":"rg-"+regionId)+"' or ");
}


String baseURL=HttpUtils.getRequestURL(request).toString()+((menuId.equals(""))?"?menuId=''":"?menuId="+menuId)+((regionId.equals(""))?"":"&regionId="+regionId)+((pageId.equals(""))?"":"&pageId="+pageId)+((pageName.equals(""))?"":"&pageName="+pageName);

String showAllFilesLink=baseURL + "&showAll=true";

String newFileLink=baseURL + "&addNew=true";

boolean insertNew=((request.getParameter("addNew")==null)?false:true);

if (insertNew){
	ResultSet rsM = st.executeQuery("select (max(id)+1) id from pages");
	if (rsM.next()){
			pageId=rsM.getString(1);
	}
	st.executeUpdate("insert into pages ( id,page_name,title) values ( '"+pageId+"','"+pageName+"rg-"+regionId+"', '"+title+"')");
    %><script>document.location.replace("<%=baseURL%>&reload=true")</script><%
    return;
}

String pgSQL="select * from pages where ("+pageNameStr+" id='"+pageId+"') "+((showAll)?" and ((html is not null and html<>'') or (print_file_url is not null and print_file_url<>'') ) ":"")+" group by if(print_file_url is null or print_file_url='',id,print_file_url) order by sequence";

ResultSet rsMn = st.executeQuery("select link_text from nav_menus where id='"+menuId+"'");
if (rsMn.next()){
	title=rsMn.getString(1);
}
ResultSet rs = st.executeQuery(pgSQL);
String editBody="";

int x=0;
boolean htmlBlank=false;
while (rs.next()){
	String fileName=((rs.getString("print_file_url")==null)?"":rs.getString("print_file_url"));
	fileName=str.replaceSubstring(fileName,"SHD",(String)session.getAttribute("siteHostRoot"));
	x++;
	htmlBlank=((rs.getString("html")==null || rs.getString("html").equals(""))?true:false);
	if (editor){
		editBody=((!htmlBlank)?"<a href='javascript:pop(\"/popups/QuickChangeHTMLForm.jsp?cols=80&rows=40&question=Change%20Body&primaryKeyValue="+rs.getString("id")+"&columnName=html&tableName=pages&valueType=string\",750,750)'>&raquo;</a>&nbsp;":"<a href='javascript:pop(\"/popups/QuickChangeHTMLForm.jsp?cols=80&rows=40&question=Change%20Body&primaryKeyValue="+rs.getString("id")+"&columnName=html&tableName=pages&valueType=string\",750,750)' class='minderLink'>&raquo;[Edit Body]</a>&nbsp;");
	}
	if (!(htmlBlank) || editor || x==1){
		%><div class='<%=((x==1)?"offeringTITLE":"subtitle")%>'><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Change%20Title&primaryKeyValue=<%=rs.getString("id")%>&columnName=title&tableName=pages&valueType=string",500,150)'>&raquo;<%=((rs.getString("title")==null || rs.getString("title").equals(""))?"[Edit Title]":"")%></a>&nbsp;<%}%><%=((rs.getString("title")==null || rs.getString("title").equals(""))?"":rs.getString("title"))%></div><%=((htmlBlank)?((editor)?"<div class='"+((x==1)?"borderAboveLeftIntro":"body")+"'><span class='body'>"+editBody+"</div>":((x==1)?"<div class='borderAboveLeftIntro'><span class='body'>":"")):"<div class='"+((x==1)?"borderAboveLeftIntro":"body")+"'><span class='body'>"+editBody+rs.getString("html")+"</span></div>")%><%=((editor && htmlBlank)?"</div>":"")%><%
	}
	if(rs.getString("print_file_url")==null || rs.getString("print_file_url").equals("")){
		%><%if (editor){%><br><a href='javascript:pop("/popups/QuickChangeFileUploadForm.jsp?tableName=pages&idField=id&idFieldValue=<%=rs.getString("id")%>&fileNameField=print_file_url&fileDirectory=SHD/fileuploads/ROC&fileDirectoryStr=<%=(String)session.getAttribute("siteHostRoot")%>/fileuploads/ROC",500,200)' class=greybutton> Upload File </a>&nbsp;&nbsp;<a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Add%20File%20Or%20URL%20Link&primaryKeyValue=<%=rs.getString("id")%>&columnName=print_file_url&tableName=pages&valueType=string",500,150)' class=greybutton>[Add File or URL Link]</a>&nbsp;<%=((editor)?"<br><div align=right><a href='javascript:pop(\"/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Page%20Sequence&primaryKeyValue="+rs.getString("id")+"&columnName=sequence&tableName=pages&valueType=string\",300,100)' class=greybutton>&raquo;Change Order on Page ["+((rs.getString("sequence")==null || rs.getString("sequence").equals(""))?"0":rs.getString("sequence"))+"]</a>&nbsp;<a href='javascript:if(confirm(\"Are you sure you want to remove this section?\")){pop(\"/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Remove%20from%20Page&autosubmit=true&primaryKeyValue="+rs.getString("id")+"&columnName=page_name&tableName=pages&newValue=delete-"+pageName+"&valueType=string\",1,1)}' class=greybutton>&raquo;Remove Section from Page </a></div><hr>":"")%><hr><%}%><%
	}else{
		String iconType=rs.getString("print_file_url").substring((rs.getString("print_file_url").length()-3),rs.getString("print_file_url").length());
		String iconFile=((iconType.equals("doc"))?"icon_doc.jpg":((iconType.equals("xls"))?"icon_xls.jpg":((iconType.equals("ppt"))?"icon_ppt.jpg":((iconType.equals("pdf"))?"icon_pdf.jpg":"icon_zzz.jpg"))));
		String icon="/images/"+iconFile;
		%><div class=subtitle><a href='<%=fileName%>' class=minderLink <%=((rs.getString("print_file_url").indexOf("http")>-1)?"target='_blank'":"")%>><u><img src='<%=icon%>' border=0>&nbsp;<%=rs.getString("print_file_url")%></u></a><%if (editor){%>&nbsp;<a href='javascript:pop("/popups/QuickChangeFileUploadForm.jsp?tableName=pages&idField=id&idFieldValue=<%=rs.getString("id")%>&fileNameField=print_file_url&fileDirectory=SHD/fileuploads/ROC&fileDirectoryStr=<%=(String)session.getAttribute("siteHostRoot")%>/fileuploads/ROC",500,200)' class=greybutton> Upload &amp; Replace File </a>&nbsp;<a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20File%20Or%20URL%20Link&primaryKeyValue=<%=rs.getString("id")%>&columnName=print_file_url&tableName=pages&valueType=string",500,150)' class=greybutton>Change Link</a>&nbsp;<%}%></div><%=((editor)?"<br><div align=right><a href='javascript:pop(\"/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Change%20Page%20Sequence&primaryKeyValue="+rs.getString("id")+"&columnName=sequence&tableName=pages&valueType=string\",300,100)' class=greybutton>&raquo;Change Order on Page ["+((rs.getString("sequence")==null || rs.getString("sequence").equals(""))?"0":rs.getString("sequence"))+"]</a>&nbsp;<a href='javascript:if(confirm(\"Are you sure you want to remove this section?\")){pop(\"/popups/QuickChangeForm.jsp?cols=10&rows=1&question=Remove%20from%20Page&autosubmit=true&primaryKeyValue="+rs.getString("id")+"&columnName=page_name&tableName=pages&newValue=delete-"+pageName+"&valueType=string\",1,1)}' class=greybutton>&raquo;Remove Section from Page </a></div><hr>":"")%><%
	}
}
if(x==0){
	ResultSet rsMx = st.executeQuery("select (max(id)+1) id from pages");
	if (rsMx.next()){
			pageId=rsMx.getString(1);
	}
	st.executeUpdate("insert into pages ( id,page_name,title) values ( '"+pageId+"','"+pageName+"rg-"+regionId+"', '"+title+"')");
	if (rsMx  != null)
		rsMx.close();
	rs = st.executeQuery("select * from pages where "+pageNameStr+" id='"+pageId+"'");
	if (rs.next()){
			%><br><br><div class=subtitle><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Change%20Title&primaryKeyValue=<%=pageId%>&columnName=title&tableName=pages&valueType=string",500,150)'>&raquo;<%=((rs.getString("title")==null || rs.getString("title").equals(""))?"[Edit Title]":"")%></a>&nbsp;<%}%><%=((rs.getString("title")==null || rs.getString("title").equals(""))?"":rs.getString("title"))%></div><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=20&question=Change%20Body&primaryKeyValue=<%=pageId%>&columnName=html&tableName=pages&valueType=string",600,600)'>&raquo;<%=((rs.getString("html")==null || rs.getString("html").equals(""))?"[Edit Body]":"")%></a>&nbsp;<%}%><%=((rs.getString("html")==null || rs.getString("html").equals(""))?"":rs.getString("html"))%><%
		if(rs.getString("print_file_url")==null || rs.getString("print_file_url").equals("")){
		%><%if (editor){%><br><br><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=1&question=Add%20Linked%20File%20Reference&primaryKeyValue=<%=rs.getString("id")%>&columnName=print_file_url&tableName=pages&valueType=string",500,150)' class=menuLINK>&raquo;[Add Linked File Reference]</a>&nbsp;<%}%><%
		}else{
		%><div class=lineitems><%if (editor){%><a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20Linked%20File%20Reference&primaryKeyValue=<%=rs.getString("id")%>&columnName=print_file_url&tableName=pages&valueType=string",500,150)'>&raquo;</a>&nbsp;<%}%><a href='<%=(String)session.getAttribute("siteHostRoot")%>/fileuploads/<%=rs.getString("print_file_url")%>' class=minderLink>&raquo;&nbsp;Click to Download...</a></div><%
		}

	}else{
	%><p>This is an invalid page reference, or this page has expired. Please click here to continue to the marketing home page: <a href="/" class='menuLINK'>HOME</a></p><%
	}
}
		if (editor){
			%><div align=right><a href="<%=newFileLink%>" class='menuLINK'>+ Add Paragraph / File</a></div><%
		}
if (rs  != null)
	rs.close();
	st.close();
	if(showAll){
	%><br><div align=right><a href="<%=baseURL%>" class='menuLINK'> Show Only Files For <%=title + ((pageName.equals(""))?" General":"")%> </a></div><%
	}else{%><br><div align=right><a href="<%=showAllFilesLink%>" class='menuLINK'> Show All Files For <%=regionName%> </a></div><%}%>