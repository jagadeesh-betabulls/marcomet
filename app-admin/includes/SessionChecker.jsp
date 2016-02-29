<%
	//Check to see if the session timed out
	if (session.getAttribute("currentSession") == null) {
%>
<!-- Warn user about session being gone-->
<jsp:forward page="/contents/SessionTimedOutPage.jsp" />
<%
	}
%>