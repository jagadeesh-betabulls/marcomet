package com.marcomet.commonprocesses;

import com.marcomet.jdbc.DBConnect;
import java.io.*;
import java.sql.*;
import java.util.logging.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class ProcessNavMenu extends HttpServlet {

  String errorMessage;

  public void editLink(HttpServletRequest request, HttpServletResponse response)
    throws ClassNotFoundException, Exception {

    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement();
    String query = "SELECT * FROM nav_menus WHERE id=" + request.getParameter("primaryKeyValue");
    ResultSet rs = st.executeQuery(query);
    HttpSession session = request.getSession(false);

    PrintWriter out = response.getWriter();

    if (rs.next()) {
      String linkType = rs.getString("link_type");
      if (linkType.equals("1")) {
        out.write("AjaxModalBox.open($('divExternalLink'), {title: 'Edit External Link', width: 600, height: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {primaryKeyValue: " + request.getParameter("primaryKeyValue") + ", linkType: " + linkType + ", lastModId: " + session.getAttribute("contactId") + "}});");
        out.write("$('ELLinkAddress').value = \"" + rs.getString("link") + "\";");
        out.write("var indexELTarget;for(i=0;i<$('ELTarget').options.length; i++){");
        out.write("if($('ELTarget').options[i].text == '" + rs.getString("target") + "'){");
        out.write("indexELTarget = i;break;}}");
        out.write("$('ELTarget').selectedIndex = indexELTarget;");
        out.write("var indexELMenuParent;for(i=0;i<$('ELMenuParent').options.length; i++){");
        out.write("if($('ELMenuParent').options[i].value == '" + rs.getString("menu_parent") + "'){");
        out.write("indexELMenuParent = i;break;}}");
        out.write("$('ELMenuParent').selectedIndex = indexELMenuParent;");
        out.write("$('ELSequence').value = '" + rs.getString("sequence") + "';");
        out.write("$('ELLinkText').value = '" + rs.getString("link_text") + "';");
        out.write("var elements = $('divExternalLink').getElementsByTagName('input'), elm;");
        out.write("for(i=0;elm=elements.item(i++);){");
        out.write("if(elm.getAttribute('type')=='button'){");
        out.write("if(elm.value=='Update'){");
        out.write("elm.onclick=function(){");
        out.write("AjaxModalBox.submit({action: 'update', link: targetLink($('ELTarget').options[$('ELTarget').selectedIndex].text, $('ELLinkAddress').value), target: (($('ELTarget').options[$('ELTarget').selectedIndex].text == 'pop(URL,height,width)') ? '' : $('ELTarget').options[$('ELTarget').selectedIndex].text), menuParent: $('ELMenuParent').options[$('ELMenuParent').selectedIndex].value, sequence: $('ELSequence').value, linkText: $('ELLinkText').value});");
        out.write("};break;}}}");
      }
      else if (linkType.equals("2")) {
        String link = rs.getString("link");
        String pageName = link.substring(link.indexOf("?pageName=") + 10, link.length());
        out.write("AjaxModalBox.open($('divHTMLPageLink'), {title: 'Edit HTML Page Link', width: 600, height: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {primaryKeyValue: " + request.getParameter("primaryKeyValue") + ", linkType: " + linkType + ", lastModId: " + session.getAttribute("contactId") + "}});");
        out.write("var indexHTMLPage;for(i=0;i<$('HTMLPage').options.length;i++){");
        out.write("if($('HTMLPage').options[i].text == '[" + pageName + "]'){");
        out.write("indexHTMLPage = i;break;}}");
        out.write("$('HTMLPage').selectedIndex = indexHTMLPage;");
        out.write("$('HTMLPageName').value = '" + pageName + "';");
        out.write("var indexHTMLTarget;for(i=0;i<$('HTMLTarget').options.length; i++){");
        out.write("if($('HTMLTarget').options[i].text == '" + rs.getString("target") + "'){");
        out.write("indexHTMLTarget = i;break;}}");
        out.write("$('HTMLTarget').selectedIndex = indexHTMLTarget;");
        out.write("var indexHTMLMenuParent;for(i=0;i<$('HTMLMenuParent').options.length; i++){");
        out.write("if($('HTMLMenuParent').options[i].value == '" + rs.getString("menu_parent") + "'){");
        out.write("indexHTMLMenuParent = i;break;}}");
        out.write("$('HTMLMenuParent').selectedIndex = indexHTMLMenuParent;");
        out.write("$('HTMLSequence').value = '" + rs.getString("sequence") + "';");
        out.write("$('HTMLLinkText').value = '" + rs.getString("link_text") + "';");
        out.write("var elements = $('divHTMLPageLink').getElementsByTagName('input'), elm;");
        out.write("for(i=0;elm=elements.item(i++);){");
        out.write("if(elm.getAttribute('type')=='button'){");
        out.write("if(elm.value=='Update'){");
        out.write("elm.onclick=function(){");
        out.write("AjaxModalBox.submit({action: 'insert', page: $('HTMLPage').options[$('HTMLPage').selectedIndex].text, link: targetLink($('HTMLTarget').options[$('HTMLTarget').selectedIndex].text, '/contents/page.jsp?pageName=' + $('HTMLPageName').value), target: (($('HTMLTarget').options[$('HTMLTarget').selectedIndex].text == 'pop(URL,height,width)') ? '' : $('HTMLTarget').options[$('HTMLTarget').selectedIndex].text), menuParent: $('HTMLMenuParent').options[$('HTMLMenuParent').selectedIndex].value, sequence: $('HTMLSequence').value, linkText: $('HTMLLinkText').value});");
        out.write("};break;}}}");
      }
      else if (linkType.equals("3")) {
        String link = rs.getString("link");
        String pageName = link.substring(link.indexOf("?pageName=") + 10, link.length());
        out.write("AjaxModalBox.open($('divBRANDIDPageLink'), {title: 'Edit BRANDID Page Link', width: 600, height: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {primaryKeyValue: " + request.getParameter("primaryKeyValue") + ", linkType: " + linkType + ", lastModId: " + session.getAttribute("contactId") + "}});");
        out.write("var indexBRANDIDPage;for(i=0;i<$('BRANDIDPage').options.length;i++){");
        out.write("if($('BRANDIDPage').options[i].text == '[" + pageName + "]'){");
        out.write("indexBRANDIDPage = i;break;}}");
        out.write("$('BRANDIDPage').selectedIndex = indexBRANDIDPage;");
        out.write("$('BRANDIDPageName').value = '" + pageName + "';");
        out.write("var indexBRANDIDTarget;for(i=0;i<$('BRANDIDTarget').options.length; i++){");
        out.write("if($('BRANDIDTarget').options[i].text == '" + rs.getString("target") + "'){");
        out.write("indexBRANDIDTarget = i;break;}}");
        out.write("$('BRANDIDTarget').selectedIndex = indexBRANDIDTarget;");
        out.write("var indexBRANDIDMenuParent;for(i=0;i<$('BRANDIDMenuParent').options.length; i++){");
        out.write("if($('BRANDIDMenuParent').options[i].value == '" + rs.getString("menu_parent") + "'){");
        out.write("indexBRANDIDMenuParent = i;break;}}");
        out.write("$('BRANDIDMenuParent').selectedIndex = indexBRANDIDMenuParent;");
        out.write("$('BRANDIDSequence').value = '" + rs.getString("sequence") + "';");
        out.write("$('BRANDIDLinkText').value = '" + rs.getString("link_text") + "';");
        out.write("var elements = $('divBRANDIDPageLink').getElementsByTagName('input'), elm;");
        out.write("for(i=0;elm=elements.item(i++);){");
        out.write("if(elm.getAttribute('type')=='button'){");
        out.write("if(elm.value=='Update'){");
        out.write("elm.onclick=function(){");
        out.write("AjaxModalBox.submit({action: 'insert', page: $('BRANDIDPage').options[$('BRANDIDPage').selectedIndex].text, link: targetLink($('BRANDIDTarget').options[$('BRANDIDTarget').selectedIndex].text, '/contents/brandSpecPage.jsp?pageName=' + $('BRANDIDPageName').value), target: (($('BRANDIDTarget').options[$('BRANDIDTarget').selectedIndex].text == 'pop(URL,height,width)') ? '' : $('BRANDIDTarget').options[$('BRANDIDTarget').selectedIndex].text), menuParent: $('BRANDIDMenuParent').options[$('BRANDIDMenuParent').selectedIndex].value, sequence: $('BRANDIDSequence').value, linkText: $('BRANDIDLinkText').value});");
        out.write("};break;}}}");
      }
      else if (linkType.equals("4")) {
        out.write("AjaxModalBox.open($('divProductLineListLink'), {title: 'Edit Product Line Listing Link', width: 600, height: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {primaryKeyValue: " + request.getParameter("primaryKeyValue") + ", linkType: " + linkType + ", lastModId: " + session.getAttribute("contactId") + "}});");
        out.write("var indexPLProductLine;for(i=0;i<$('PLProductLine').options.length;i++){");
        out.write("if($('PLProductLine').options[i].value == '" + rs.getString("prodline_id") + "'){");
        out.write("indexPLProductLine = i;break;}}");
        out.write("$('PLProductLine').selectedIndex = indexPLProductLine;");
        out.write("var indexPLRelease;for(i=0;i<$('PLRelease').options.length;i++){");
        out.write("if($('PLRelease').options[i].value == '" + rs.getString("release") + "'){");
        out.write("indexPLRelease = i;break;}}");
        out.write("$('PLRelease').selectedIndex = indexPLRelease;");
        out.write("var indexPLMenuParent;for(i=0;i<$('PLMenuParent').options.length; i++){");
        out.write("if($('PLMenuParent').options[i].value == '" + rs.getString("menu_parent") + "'){");
        out.write("indexPLMenuParent = i;break;}}");
        out.write("$('PLMenuParent').selectedIndex = indexPLMenuParent;");
        out.write("$('PLSequence').value = '" + rs.getString("sequence") + "';");
        out.write("$('PLLinkText').value = '" + rs.getString("link_text") + "';");
        out.write("var elements = $('divProductLineListLink').getElementsByTagName('input'), elm;");
        out.write("for(i=0;elm=elements.item(i++);){");
        out.write("if(elm.getAttribute('type')=='button'){");
        out.write("if(elm.value=='Update'){");
        out.write("elm.onclick=function(){");
        out.write("AjaxModalBox.submit({action: 'insert', prodLineId: $('PLProductLine').options[$('PLProductLine').selectedIndex].value, release: $('PLRelease').options[$('PLRelease').selectedIndex].value, target: $('PLTarget').value, menuParent: $('PLMenuParent').options[$('PLMenuParent').selectedIndex].value, sequence: $('PLSequence').value, linkText: $('PLLinkText').value});");
        out.write("};break;}}}");
      }
      else if (linkType.equals("5")) {
        out.write("AjaxModalBox.open($('divInternalLink'), {title: 'Edit Internal Link', width: 600, height: 300, method: 'post', servletUrl: '/servlet/com.marcomet.commonprocesses.ProcessNavMenu', params: {primaryKeyValue: " + request.getParameter("primaryKeyValue") + ", linkType: " + linkType + ", lastModId: " + session.getAttribute("contactId") + "}});");
        out.write("$('ILLinkAddress').value = \"" + rs.getString("link") + "\";");
        out.write("var indexILTarget;for(i=0;i<$('ILTarget').options.length; i++){");
        out.write("if($('ILTarget').options[i].text == '" + rs.getString("target") + "'){");
        out.write("indexILTarget = i;break;}}");
        out.write("$('ILTarget').selectedIndex = indexILTarget;");
        out.write("var indexILMenuParent;for(i=0;i<$('ILMenuParent').options.length; i++){");
        out.write("if($('ILMenuParent').options[i].value == '" + rs.getString("menu_parent") + "'){");
        out.write("indexILMenuParent = i;break;}}");
        out.write("$('ILMenuParent').selectedIndex = indexILMenuParent;");
        out.write("$('ILSequence').value = '" + rs.getString("sequence") + "';");
        out.write("$('ILLinkText').value = '" + rs.getString("link_text") + "';");
        out.write("var elements = $('divInternalLink').getElementsByTagName('input'), elm;");
        out.write("for(i=0;elm=elements.item(i++);){");
        out.write("if(elm.getAttribute(\"type\")=='button'){");
        out.write("if(elm.value=='Update'){");
        out.write("elm.onclick=function(){");
        out.write("AjaxModalBox.submit({action: 'update', link: targetLink($('ILTarget').options[$('ILTarget').selectedIndex].text, $('ILLinkAddress').value), target: (($('ILTarget').options[$('ILTarget').selectedIndex].text == 'pop(URL,height,width)') ? '' : $('ILTarget').options[$('ILTarget').selectedIndex].text), menuParent: $('ILMenuParent').options[$('ILMenuParent').selectedIndex].value, sequence: $('ILSequence').value, linkText: $('ILLinkText').value});");
        out.write("};break;}}}");
      }
    }

    rs.close();
    st.close();
    conn.close();
  }

  public void updateNavMenu(HttpServletRequest request, HttpServletResponse response)
    throws ServletException, IOException, SQLException, ClassNotFoundException, Exception {

    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement();
    String query = "";

    String MenuParentSequence = request.getParameter("MenuParentSequence");
    String page = request.getParameter("page");
    String newPageName = request.getParameter("newPageName");
    String action = request.getParameter("action");
    String primaryKeyValue = request.getParameter("primaryKeyValue");
    String menuParent = request.getParameter("menuParent");
    String sequence = request.getParameter("sequence");
    String pageName = request.getParameter("pageName");
    String link = request.getParameter("link");
    String linkText = request.getParameter("linkText");
    String linkType = request.getParameter("linkType");
    String target = request.getParameter("target");
    String siteHostId = request.getParameter("siteHostId");
    String prodLineId = request.getParameter("prodLineId");
    String linkPage = request.getParameter("linkPage");
    String statusId = request.getParameter("statusId");
    String release = request.getParameter("release");
    String lastModId = request.getParameter("lastModId");

    PrintWriter out = response.getWriter();

    if (MenuParentSequence != null && MenuParentSequence.equals("true")) {
      String value = request.getParameter("menuParent");
      int seq = 0;
      if (value.equals("")) { //NONE
        String sql = "SELECT sequence FROM nav_menus WHERE page_name='" + request.getParameter("pageName") + "' AND sitehost_id=" + Integer.parseInt(request.getParameter("siteHostId")) + " ORDER BY sequence";
        ResultSet rs = st.executeQuery(sql);
        rs.last();
        seq = rs.getInt("sequence") + 10;
      }
      else {
        int menu_parent = Integer.parseInt(request.getParameter("menuParent"));
        String sql = "SELECT sequence from nav_menus WHERE menu_parent=" + menu_parent + " ORDER BY sequence";
        ResultSet rs = st.executeQuery(sql);
        rs.last();
        if (pageName.equals("topmenu")) {
          seq = rs.getInt("sequence") + 1;
        }
        else if (pageName.equals("home")) {
          seq = rs.getInt("sequence") * 10;
        }
      }
      out.write("$('" + request.getParameter("sequence") + "').value = " + seq + ";");
    }

    if (action != null) {
      if (action.equals("insert")) {
        query = "INSERT INTO nav_menus (menu_parent, sequence, page_name, link, link_text, link_type, target, sitehost_id, prodline_id, link_page, status_id, `release`, last_mod_id) VALUES (" + menuParent + ", " + sequence + ", '" + pageName + "', '" + link + "', '" + linkText + "', " + linkType + ", '" + target + "', " + siteHostId + ", " + prodLineId + ", '" + linkPage + "', " + statusId + ", '" + release + "', " + lastModId + ")";
        st.executeUpdate(query);

        if (page != null && page.equals("New Page")) {
          if (linkType.equals("2")) {
            out.write("window.location.href = '/contents/page.jsp?pageName=" + newPageName + "';");
          }
          else if (linkType.equals("3")) {
            out.write("window.location.href = '/contents/brandSpecPage.jsp?pageName=" + newPageName + "';");
          }
        }
        else{
          out.write("window.location.reload();");
        }
      }
      else if (action.equals("update")) {
        if (linkType.equals("1") || linkType.equals("5")) {
          query = "UPDATE nav_menus SET link='" + link + "', target='" + target + "', menu_parent=" + menuParent + ", sequence=" + sequence + ", link_text='" + linkText + "', last_mod_id=" + lastModId + " WHERE id=" + primaryKeyValue;
        }
        else if (linkType.equals("2")) {
          query = "UPDATE nav_menus SET ";
        }
        else if (linkType.equals("3")) {
          query = "UPDATE nav_menus SET ";
        }
        else if (linkType.equals("4")) {
          query = "UPDATE nav_menus SET ";
        }
        st.executeUpdate(query);

        out.write("window.location.reload();");
      }
      else if (action.equals("reorder")) {
        query = "UPDATE nav_menus SET menu_parent=" + menuParent + ", sequence=" + sequence + ", last_mod_id=" + lastModId + " WHERE id=" + primaryKeyValue;
        st.executeUpdate(query);

        out.write("window.location.reload();");
      }
      else if (action.equals("enable_disable")) {
        query = "UPDATE nav_menus SET status_id=" + statusId + ", last_mod_id=" + lastModId + " WHERE id=" + primaryKeyValue;
        st.executeUpdate(query);

        out.write("window.location.reload();");
      }
    }

    st.close();
    conn.close();
  }

  public void doPost(HttpServletRequest request, HttpServletResponse response)
    throws ServletException {

    try {
      if (request.getParameter("editLink") != null && request.getParameter("editLink").equals("true")) {
        editLink(request, response);
      }
      else {
        updateNavMenu(request, response);
      }
    }
    catch (IOException ex) {
      Logger.getLogger(ProcessNavMenu.class.getName()).log(Level.SEVERE, null, ex);
    }
    catch (SQLException ex) {
      Logger.getLogger(ProcessNavMenu.class.getName()).log(Level.SEVERE, null, ex);
    }
    catch (Exception ex) {
      Logger.getLogger(ProcessNavMenu.class.getName()).log(Level.SEVERE, null, ex);
    }
  }
}
