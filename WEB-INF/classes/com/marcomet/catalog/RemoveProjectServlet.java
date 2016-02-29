package com.marcomet.catalog;

/**********************************************************************
Description:	This class is used to remove projects from the shopping 
				cart.

History:
	Date		Author			Description
	----		------			-----------
	8/9/01		Thomas Dietrich	Created
	
**********************************************************************/

import com.marcomet.tools.*;

import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class RemoveProjectServlet extends HttpServlet {

	public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException {
	
		ShoppingCart cart = (ShoppingCart)request.getSession().getAttribute("shoppingCart");
		
		if(cart != null){
			Vector projects = cart.getProjects();
			for(int i = 0; i < projects.size(); i++){
				ProjectObject po = (ProjectObject)projects.elementAt(i);
				if(po.getId() == Integer.parseInt((String)request.getParameter("projectId"))){
					cart.removeProject(i);
					break;
				}	
			}
		}
		
		ReturnPageContentServlet rpcs = new ReturnPageContentServlet();
		rpcs.printNextPage(this, request, response);
	}
}
