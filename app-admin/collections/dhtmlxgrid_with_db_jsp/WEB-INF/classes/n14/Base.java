package n14;
import java.io.*;

import javax.servlet.http.*;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import org.apache.xerces.dom.DocumentImpl;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

public class Base {
	//connection variables
	private ResultSet rs;
	private Statement stmt;
	private Connection con;
	private String dbName,userName,userPass;
	//Variables for xml response
	private Element e,e1;
	private Node n;
	//Main variables 
	public String id;
	private String name;
	private Double price;
	private String authorId;
	private String instore;
	private Double pubDate;	
	private int aId;
	private Document xmldoc = new DocumentImpl();
	public void con(String dbName,String userName,String userPass){
		this.dbName = dbName;
		this.userName = userName;
		this.userPass = userPass;
	}
	//Connect to database (Mysql)
	private void startConnect() throws ClassNotFoundException, SQLException{
		Class.forName("org.gjt.mm.mysql.Driver");
		String url = "jdbc:mysql://localhost:3306/"+dbName;
		con = DriverManager.getConnection(url, userName, userPass);		
		con.setAutoCommit(false);
		stmt = con.createStatement();
	}
	//Close connection
	public void closeConnect() throws SQLException{
		con.close();
	}
	//Initializes variable
	public void init_(HttpServletRequest request){
		try{
		if (request.getParameter("type").intern() == "delete".intern()) return ;
		String [] values = request.getParameter("values").split("\\|");
		instore = values[0];
		name = values[1];
		authorId = values[2];
		pubDate = Double.valueOf(values[3]);
		price = Double.valueOf(values[4]);
		} catch (Exception e){
			e.printStackTrace();
		}
	}
	//Add author to database
	public void addAuthors() throws ClassNotFoundException, SQLException{
		String [] tmp = authorId.split("\\,");
		String tmp_ = "";
		try{
			if (tmp.length < 1) {
				tmp[0] = authorId;
				} else tmp_ = tmp[1];
		} catch(Exception e){
			
		}
		startConnect();
		rs = stmt.executeQuery("SELECT count(*) as qty FROM authors");
		rs.next();
		aId = rs.getInt("qty");
		stmt.executeUpdate("INSERT INTO authors (`Id`,`lastname`,`firstname`) VALUES('"+aId+"','"+tmp[0]+"','"+tmp_+"')");
		con.commit();
		closeConnect();
	}
	//Check author if author not exist add him
	public void checkAuthor() throws ClassNotFoundException, SQLException{
		String [] tmp = authorId.split("\\,");
		startConnect();
		rs = stmt.executeQuery("SELECT * FROM authors WHERE Id='"+tmp[0]+"'");

		if (rs.last() == false){
			addAuthors();
		} else {
			aId = rs.getInt("Id");
		}
		closeConnect();
	}
	//Add new book to database
	public void add() throws ClassNotFoundException, SQLException{
		checkAuthor();
		startConnect();
		stmt.executeUpdate("INSERT INTO books (`name`, `authorid`, `pubdate`, `price`, `instore`) VALUES ('"+name+"', '"+aId+"', '"+pubDate+"', '"+price+"', '"+instore+"')");
		con.commit();
		closeConnect();
	}
	//Update book
	public void update() throws ClassNotFoundException, SQLException{
		checkAuthor();
		startConnect();
		stmt.executeUpdate("UPDATE `books` SET `instore`='"+instore+"', `name`='"+name+"', `authorid`='"+aId+"', `pubdate`='"+pubDate+"', `price`='"+price+"' WHERE `Id`='"+id+"'");
		con.commit();
		closeConnect();
	}	
	//Delete record from database 
	public void delete() throws ClassNotFoundException, SQLException{
		startConnect();
		stmt.executeUpdate("DELETE FROM books WHERE Id="+id);
		con.commit();
		closeConnect();
	}
	//Get author list in XML
	public void getAuthorList(HttpServletResponse response) throws IOException, ClassNotFoundException, SQLException{
	    response.setContentType("text/xml");
	    PrintWriter out = response.getWriter();
		Element root = xmldoc.createElement("authors");
		startConnect();
		rs = stmt.executeQuery("SELECT * FROM authors ORDER BY Id");
		while (rs.next()){
			e = xmldoc.createElementNS(null,"author");
			e.setAttributeNS(null,"value",rs.getString("Id"));
			n = xmldoc.createTextNode(rs.getString("lastname")+", "+rs.getString("firstname"));
			e.appendChild(n);
			root.appendChild(e);		
		}
		closeConnect();
		xmldoc.appendChild(root);
	    OutputFormat format = new OutputFormat(xmldoc);
	    format.setIndenting(true); 
	    XMLSerializer serializer = new XMLSerializer(out,format);
        try {
			serializer.asDOMSerializer();
			serializer.serialize(xmldoc);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return;
	}
	// Get base XML for grid
	public void createXML(HttpServletResponse response) throws IOException, ClassNotFoundException, SQLException{
	    response.setContentType("text/xml");
	    PrintWriter out = response.getWriter();
		Element root = xmldoc.createElement("rows");
		startConnect();
		rs = stmt.executeQuery("SELECT * FROM books ORDER BY name");
		while (rs.next()){
			e = xmldoc.createElementNS(null,"row");
			e.setAttributeNS(null,"id",rs.getString("Id"));
			e1 = xmldoc.createElementNS(null,"cell");
			e1.appendChild(xmldoc.createTextNode(rs.getString("instore")));
			e.appendChild(e1);
			e1 = xmldoc.createElementNS(null,"cell");
			e1.appendChild(xmldoc.createTextNode(rs.getString("name")));
			e.appendChild(e1);
			e1 = xmldoc.createElementNS(null,"cell");
			e1.appendChild(xmldoc.createTextNode(rs.getString("authorid")));
			e.appendChild(e1);
			e1 = xmldoc.createElementNS(null,"cell");
			e1.appendChild(xmldoc.createTextNode(""+rs.getDouble("pubdate")));
			e.appendChild(e1);
			e1 = xmldoc.createElementNS(null,"cell");
			e1.appendChild(xmldoc.createTextNode(""+rs.getDouble("price")));
			e.appendChild(e1);				
			root.appendChild(e);				
		}
		closeConnect();
		xmldoc.appendChild(root);
	    OutputFormat format = new OutputFormat(xmldoc);
	    format.setIndenting(true); 
	    XMLSerializer serializer = new XMLSerializer(out,format);
        try {
			serializer.asDOMSerializer();
			serializer.serialize(xmldoc);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return;
	}
	
	public static void main(String args[]) {
		
	}
}
