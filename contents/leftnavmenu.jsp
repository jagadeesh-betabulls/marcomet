<%@ page errorPage="/errors/ExceptionPage.jsp" %>
<%@ page import="java.sql.*,com.marcomet.tools.*,com.marcomet.environment.*,com.marcomet.users.security.*;" %>
<jsp:useBean id="connection" class="com.marcomet.jdbc.ConnectionBean" scope="session" />
<jsp:useBean id="sl" class="com.marcomet.tools.SimpleLookups" scope="page" />
<%
	SiteHostSettings shs = (SiteHostSettings)session.getAttribute("siteHostSettings"); 
    boolean editor = (((RoleResolver) session.getAttribute("roles")).roleCheck("editor"));
    String ShowRelease = ((request.getParameter("ShowRelease") == null || request.getParameter("ShowRelease").equals("")) ? "" : " AND nav_menus.release='" + request.getParameter("ShowRelease") + "' ");
	String brandCodeStr="";
	String tmpShId=((request.getParameter("shId")==null)?((session.getAttribute("tmpSHId")!=null && !session.getAttribute("tmpSHId").toString().equals(""))?session.getAttribute("tmpSHId").toString():""):request.getParameter("shId"));
    String ShowInactive = ((request.getParameter("ShowInactive") == null || request.getParameter("ShowInactive").equals("")) ? " AND status_id=2 " : "");
	String prodStatus=" p.status_id='2' ";
    String pageName = ((request.getParameter("pageName") == null || request.getParameter("pageName").equals("")) ? " AND page_name='home' " : " AND pagename= '" + request.getParameter("pageName") + "' ");
    String sitehostId = shs.getSiteHostId();
    String siteHostIdFilter=((!tmpShId.equals(""))?" (sitehost_id='"+sitehostId+"' or sitehost_id='"+tmpShId+"')" :" sitehost_id='"+sitehostId+"' ");
	boolean notAggregator=((shs.getSiteType()!=null && shs.getSiteType().equals("aggregator"))?false:true);
	String brandCode = ((notAggregator || session.getAttribute("brandCode") == null || session.getAttribute("brandCode").toString().equals("")) ? "" : " AND brand_code = '" + session.getAttribute("brandCode").toString() + "' ");
    if (editor) {
    	prodStatus=" (p.status_id='2' or p.status_id='9') ";
%>
<div>
 <a href="/contents/SiteMap.jsp?pageName=home&edit=true" class="graybutton">&nbsp;EDIT&nbsp;</a>
</div>
<%}
%>
<table border=0 cellpadding=0 cellspacing=0 width="232">
  <tr>
    <td valign="top">
      <table align="top" cellpadding=0 cellspacing=0 width=100%>
        <tr>
          <td width=100% class="leftNavBarHeader">Marketing&nbsp;Supplies&nbsp;&amp;&nbsp;Services
          </td>
        </tr><%if(request.getParameter("ShowBrandChooser")!=null){%>
        <tr>
          <td width=100%>
          <jsp:include page="/includes/brandChosen.jsp" flush="true" ></jsp:include>
          </td>
        </tr>
        <%
            brandCode = ((notAggregator || session.getAttribute("brandCode") == null || session.getAttribute("brandCode").toString().equals("")) ? "" : " AND brand_code = '" + session.getAttribute("brandCode").toString() + "' ");
            brandCodeStr = ((notAggregator || session.getAttribute("brandCode") == null || session.getAttribute("brandCode").toString().equals("")) ? "" : session.getAttribute("brandCode").toString());
        }%><tr>
          <td>
            <table id="subMenu0" width=100% cellspacing=0 cellpadding=0>
              <%
    Connection conn = com.marcomet.jdbc.DBConnect.getConnection();
    Statement st = conn.createStatement();
    
    String nmSQL="";
    if(notAggregator){
        nmSQL="SELECT  *,'' as 'noProds' FROM nav_menus where sitehost_id=" + sitehostId + brandCode+pageName + ShowInactive + ShowRelease + " ORDER BY sequence";
    }else{
    	nmSQL="SELECT distinct if(nm.prodline_id is not null and nm.prodline_id<>'0' and p.id is null and pb.id is null,'true','') as 'noProds',nm.* FROM nav_menus nm left join nav_menu_brand_bridge nb on nb.nav_menu_id=nm.id and (nb.brand_code='"+brandCodeStr+"') and nb.status_code='2' left join products p on if(nb.exclude_flag is null, (p.brand_code='"+brandCodeStr+"' or p.brand_code='x') and p.status_id='2' ,'') and ( left(p.prod_line_id,6)=nm.prodline_id or  left(p.prod_line_id,7)=nm.prodline_id or p.prod_line_id=nm.prodline_id) left join product_line_bridge pb on pb.prod_id=p.id and (pb.prod_line_id=nm.prodline_id or pb.prod_line_id=left(nm.prodline_id,6) or pb.prod_line_id=left(nm.prodline_id,7)) where nm.status_id=2 and "+siteHostIdFilter+" and (nm.brand_code='' or nm.brand_code='"+brandCodeStr+"' or nb.brand_code='"+brandCodeStr+"' or nm.brand_code='x') and (nb.exclude_flag is null or nb.exclude_flag=0)  and page_name='home' order by nm.sequence";
    }
  %><!-- <%=nmSQL%>  --><%
    ResultSet rs = st.executeQuery(nmSQL);
    int x = 1;
    int y = 1;
    while (rs.next()) {
      String target = ((rs.getString("target").equals("")) ? "main" : rs.getString("target"));
      if (rs.getString("link_page").equals("logos.jsp") ) {
      		String linkStr="<a href='/contents/logos.jsp?title="+rs.getString("link_text")+((request.getParameter("ShowRelease") == null || request.getParameter("ShowRelease").equals("")) ? "" : "&ShowRelease=" + request.getParameter("ShowRelease"))+((request.getParameter("ShowInactive") == null || request.getParameter("ShowInactive").equals("")) ? "" : "&ShowInactive=" + request.getParameter("ShowInactive"))+((rs.getString("prodline_id").equals("")) ? "" : "&prodLineId=" + rs.getString("prodline_id"))+"' class='leftNavBarItem2' id='cmslnk"+y+"' target='"+target+"'>";
              %>
              <tr>
                <td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cmslnk<%=y%>.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cmslnk<%=y%>.className='leftNavBarItem2'" height="30">
                  <%--<%if (editor) {
                  %>
                  <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20Navigation%20Menu%20Text&primaryKeyValue=<%=rs.getString("id")%>&columnName=link_text&tableName=nav_menus&valueType=string",500,100)'>&raquo;</a>&nbsp;
                  <%}
                  %>--%>
<%				if(rs.getString("noProds").equals("true")){
                  	linkStr=((editor)?linkStr:"<a href='javascript:alert(\"We are working hard to have "+rs.getString("link_text")+" products available shortly.\");' class='leftNavBarItem2' id='cmslnk"+y+"' >");
                  
                  %><%=linkStr%><%=rs.getString("link_text")%><font color=red>  Coming Soon...</font></a><%
				}else{
				  %><%=linkStr%><%=rs.getString("link_text")%></a><%
				}%>                  
                </td>
              </tr>
              <%} else {
              %>
              <tr>
                <td class="leftNavBarItem2" onMouseOver="this.className='leftNavBarItemOver2';cmslnk<%=y%>.className='leftNavBarItemHover2'" onMouseOut="this.className='leftNavBarItem2';cmslnk<%=y%>.className='leftNavBarItem2'" height="30">
                  <%--<%if (editor) {
                  %>
                  <a href='javascript:pop("/popups/QuickChangeForm.jsp?cols=60&rows=2&question=Change%20Navigation%20Menu%20Text&primaryKeyValue=<%=rs.getString("id")%>&columnName=link_text&tableName=nav_menus&valueType=string",500,100)'>&raquo;</a>&nbsp;
                  <%}
                  %>--%>
                  <a href="<%=rs.getString("link")%>" class='leftNavBarItem2' id='cmslnk<%=y%>' target='<%=target%>'><%=rs.getString("link_text")%></a>
                </td>
              </tr>
              <%
      }
      y++;
      x++;
    }
              %>
              <tr>
                <td class="leftNavBarBottom" onMouseOver="this.className='leftNavBarBottomOver';cmslnk<%=y%>.className='leftNavBarBottomTextOver'" onMouseOut="this.className='leftNavBarBottom';cmslnk<%=y%>.className='leftNavBarBottomText'" height="30">
                  <a href="javascript:pop('/popups/help.jsp','650','550')" id='cmslnk<%=y%>' class='leftNavBarBottomText'>Need Help? Click here...  </a>
                </td>
              </tr>
            </table>
            <%
    if (session.getAttribute("contactId") != null) {
            %>
            <table width="100%" cellspacing="0" cellpadding="0" height="200">
              <tr>
                <td valign="top" height="22">
                  <br>
                  <jsp:include page="/includes/ClientARSummary.jsp" />
                </td>
              </tr>
              <tr>
                <td valign="top">
                  <jsp:include page="/includes/ClientAppvlSummary.jsp"/>
                </td>
              </tr>
            </table>
            <%    }
            %>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
<%
    conn.close();
%>
