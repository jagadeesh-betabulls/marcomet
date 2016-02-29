package com.marcomet.products;

import com.marcomet.environment.SiteHostSettings;
import com.marcomet.jdbc.DBConnect;
import com.marcomet.tools.StringTool;
import java.io.*;
import java.sql.*;
import java.util.ResourceBundle;
import java.util.logging.*;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class UpdateFeaturedProduct extends HttpServlet {

  String errorMessage;

  public void processRequest(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException, SQLException, ClassNotFoundException, Exception {

    ResourceBundle bundle = ResourceBundle.getBundle("com.marcomet.marcomet");
    String rootDir = bundle.getString("rootDir");

    Connection conn = DBConnect.getConnection();
    Statement st = conn.createStatement();
    Statement st1 = conn.createStatement();
    String query = "";
    String query1 = "";
    HttpSession session = request.getSession(false);
    StringTool str = new StringTool();

    String siteHostRoot = ((request.getParameter("siteHostRoot") == null) ? (String) session.getAttribute("siteHostRoot") : request.getParameter("siteHostRoot"));
    String siteHostId = ((SiteHostSettings) session.getAttribute("siteHostSettings")).getSiteHostId();
    String newValue = request.getParameter("newValue");
    String actionId = request.getParameter("actionId");
    String modId = session.getAttribute("contactId").toString();
    String lastSequence = request.getParameter("lastSequence");
    String newStatus = request.getParameter("newStatus");
    String isPage = request.getParameter("page");

    if (actionId.equals("1") || actionId.equals("2")) {
      query = "SELECT * FROM products WHERE id=" + newValue;
      ResultSet rsProd = st.executeQuery(query);
      if (rsProd.next()) {
        if (actionId.equals("1")) { //Add
          query1 = "INSERT INTO featured_products (product_id,sequence,sitehost_id,status_id,mod_id) VALUES (" + rsProd.getString("id") + "," + rsProd.getInt("sequence") + "," + siteHostId + "," + rsProd.getInt("status_id") + ",'" + modId + "')";
        }
        else if (actionId.equals("2")) { //Replace
          query1 = "UPDATE featured_products SET product_id=" + rsProd.getString("id") + ", last_product_id=" + request.getParameter("primaryKeyValue") + ", last_action_id=2, mod_id=" + modId + " WHERE product_id=" + request.getParameter("primaryKeyValue");
        }
        st1.executeUpdate(query1);
      }

      try {
        File imageUrl = new File(rootDir + siteHostRoot + "/fileuploads/product_images/" + str.replaceSubstring(str.replaceSubstring(rsProd.getString("small_picurl"), ".jpg", "_TH.jpg"), " ", "%20"));
        if (!imageUrl.exists()) {
          File inFile = new File(rootDir + siteHostRoot + "/fileuploads/product_images/" + rsProd.getString("small_picurl"));
          if (inFile.exists()) {
            InputStream inStream = new FileInputStream(rootDir + siteHostRoot + "/fileuploads/product_images/" + rsProd.getString("small_picurl"));
            OutputStream outStream = new FileOutputStream(rootDir + siteHostRoot + "/fileuploads/product_images/" + str.replaceSubstring(str.replaceSubstring(rsProd.getString("small_picurl"), ".jpg", "_TH.jpg"), " ", "%20"));
            byte[] b = new byte[1024];
            int len;

            while ((len = inStream.read(b)) > 0) {
              outStream.write(b, 0, len);
            }

            inStream.close();
            outStream.close();
          }
        }
      }
      catch (IOException e) {
        errorMessage = "There was an error: " + e.getMessage();
        exitWithError(request, response);
      }
    }
    else if (actionId.equals("3") || actionId.equals("4")) {
      if (actionId.equals("3")) { //Remove
        if (isPage != null) {
          query = "UPDATE featured_products SET " + request.getParameter("columnName") + "=" + newStatus + ", last_action_id=" + actionId + ", mod_id=" + modId + " WHERE page_id=" + request.getParameter("primaryKeyValue");
        }
        else {
          query = "UPDATE featured_products SET " + request.getParameter("columnName") + "=" + newStatus + ", last_action_id=" + actionId + ", mod_id=" + modId + " WHERE product_id=" + request.getParameter("primaryKeyValue");
        }
      }
      else if (actionId.equals("4")) { //Reorder
        if (isPage != null) {
          query = "UPDATE featured_products SET " + request.getParameter("columnName") + "=" + newValue + ", last_action_id=" + actionId + ", mod_id=" + modId + ", last_sequence=" + lastSequence + " WHERE page_id=" + request.getParameter("primaryKeyValue");
        }
        else {
          query = "UPDATE featured_products SET " + request.getParameter("columnName") + "=" + newValue + ", last_action_id=" + actionId + ", mod_id=" + modId + ", last_sequence=" + lastSequence + " WHERE product_id=" + request.getParameter("primaryKeyValue");
        }
      }
      st1.executeUpdate(query);
    }

    PrintWriter out = response.getWriter();
    out.write("window.location.reload();");

    st.close();
    st1.close();
    conn.close();

  }

  private void exitWithError(HttpServletRequest request, HttpServletResponse response)
      throws ServletException {

//set error attribute 
    request.setAttribute("errorMessage", errorMessage);

//goto an error page 
    RequestDispatcher rd = getServletContext().getRequestDispatcher(request.getParameter("errorPage"));
    try {
      rd.forward(request, response);
    }
    catch (IOException ioe) {
      throw new ServletException("UpdateFeaturedProduct, forward failed on an error" + ioe.getMessage());
    }
  }

  public void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException {

    try {
      processRequest(request, response);
    }
    catch (IOException ex) {
      Logger.getLogger(UpdateFeaturedProduct.class.getName()).log(Level.SEVERE, null, ex);
    }
    catch (SQLException ex) {
      Logger.getLogger(UpdateFeaturedProduct.class.getName()).log(Level.SEVERE, null, ex);
    }
    catch (Exception ex) {
      Logger.getLogger(UpdateFeaturedProduct.class.getName()).log(Level.SEVERE, null, ex);
    }
  }
} 