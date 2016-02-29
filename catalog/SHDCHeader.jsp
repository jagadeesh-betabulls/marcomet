<%@ page errorPage="/errors/ExceptionPage.jsp" %><%
String subTitle= ((request.getParameter("subTitle")==null)?"":"<br>"+request.getParameter("subTitle")).replace("|","?").replace("~","&");
%><div class=subtitle>New Do-It-Yourself Design Center:<%=subTitle%><hr></div>

