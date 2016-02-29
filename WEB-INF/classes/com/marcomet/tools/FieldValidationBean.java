package com.marcomet.tools;

/***************************************************************************
Pupose: This Bean recieves field names and upon request outputs orgainzed
javascript for performing level one validations on the form.
 ***************************************************************************/
import com.marcomet.jdbc.*;
import java.util.*;
import java.sql.*;

public class FieldValidationBean{

	//***** extra code *****
	private String extraCode = "";
	
	//**** form fields *****
	private Vector reqTextFields;
	private Vector reqTextFieldsIP;
	private Vector reqCheckBoxes;
	private Vector reqCheckBoxesIP;
	private Vector reqRadioButtons;
	private Vector reqRadioButtonsIP;
	private Vector numberFields;
	private Vector numberFieldsIP;
	private Vector zipcodeFields;
	private Vector zipcodeFieldsIP;
	private Vector passwordMatches;
	private Vector passwordMatchesIP;
	private Vector thisOrThatFields;            //when atleast one field needs to be filled in out of a group
	
	
	private final String  selectValidationText =
		"SELECT value FROM form_validation_scripts WHERE lookupkey =?";

	public FieldValidationBean() throws Exception{
		
		reqTextFields = new Vector();
		reqTextFieldsIP = new Vector();
		reqCheckBoxes = new Vector();
		reqCheckBoxesIP = new Vector();
		reqRadioButtons = new Vector();
		reqRadioButtonsIP = new Vector();
		numberFields = new Vector();
		numberFieldsIP = new Vector();
		zipcodeFields = new Vector();
		zipcodeFieldsIP = new Vector();
		passwordMatches = new Vector();
		passwordMatchesIP = new Vector();
		thisOrThatFields = new Vector();
		extraCode = "";		
	}

	public void setExtraCode(String temp){
		extraCode = temp;
	}	
	
	public void addReqCheckBoxes(String temp){
		reqCheckBoxes.addElement(temp);
	}
	//**** Set Fields *******
	public void addReqTextField(String temp){
		reqTextFields.addElement(temp);	
	}
	public void addReqTextFieldIP(String temp){
		reqTextFieldsIP.addElement(temp);
	}
	public String getJavaScripts() throws SQLException{
		
		Connection conn = null;
		StringBuffer javaScripts = new StringBuffer();
		
		try {			
		
			conn = DBConnect.getConnection();
			StringTool stringTool= new StringTool();		
			ResultSet rs;
			PreparedStatement selectValidation = conn.prepareStatement(selectValidationText);
			
			javaScripts.append("<script language=\"JavaScript\">");
			javaScripts.append("function submitForm(){");
			
			
			
			if(reqTextFields.size() > 0){
				selectValidation.clearParameters();
				selectValidation.setString(1,"required_text_fields");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					for(int i = 0; i < reqTextFields.size(); i++){
						javaScripts.append(stringTool.replaceSubstring(rs.getString("value"),"FN",reqTextFields.elementAt(i).toString()));
					}
				}
			}	
			
			
			if(reqTextFieldsIP.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"required_text_fields_if_present");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					for(int i = 0; i < reqTextFieldsIP.size(); i++){
						javaScripts.append(stringTool.replaceSubstring(rs.getString("value"),"FN",reqTextFieldsIP.elementAt(i).toString()));
					}
				}		
			}	
			
			if(reqCheckBoxes.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"required_check_boxes");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					for(int i = 0; i < reqCheckBoxes.size(); i++){
						javaScripts.append(stringTool.replaceSubstring(rs.getString("value"),"FN",reqCheckBoxes.elementAt(i).toString()));
					}
				}
			}	
			
			
				if(reqCheckBoxesIP.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"required_check_boxes_if_present");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					for(int i = 0; i < reqCheckBoxesIP.size(); i++){
						javaScripts.append(stringTool.replaceSubstring(rs.getString("value"),"FN",reqCheckBoxesIP.elementAt(i).toString()));
					}
				}						
			}
			
				
			if(reqRadioButtons.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"required_radio_buttons");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					for(int i = 0; i < reqRadioButtons.size(); i++){
						javaScripts.append(stringTool.replaceSubstring(rs.getString("value"),"FN",reqRadioButtons.elementAt(i).toString()));
					}
				}
			}	
			
			
				if(reqRadioButtonsIP.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"required_radio_buttons_if_present");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					for(int i = 0; i < reqRadioButtonsIP.size(); i++){
						javaScripts.append(stringTool.replaceSubstring(rs.getString("value"),"FN",reqRadioButtonsIP.elementAt(i).toString()));
					}
				}						
			}	
				
			if(numberFields.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"number_fields");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					for(int i = 0; i < numberFields.size(); i++){
						javaScripts.append(stringTool.replaceSubstring(rs.getString("value"),"FN",numberFields.elementAt(i).toString()));
					}
				}
			}	
			
			if(numberFieldsIP.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"number_fields_if_present");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					for(int i = 0; i < numberFieldsIP.size(); i++){
						javaScripts.append(stringTool.replaceSubstring(rs.getString("value"),"FN",numberFieldsIP.elementAt(i).toString()));
					}
				}						
			}
			
			
			if(zipcodeFields.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"zipcode_fields");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					for(int i = 0; i < zipcodeFields.size(); i++){
						javaScripts.append(stringTool.replaceSubstring(rs.getString("value"),"FN",zipcodeFields.elementAt(i).toString()));
					}
				}
			}	
			
			if(zipcodeFieldsIP.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"zipcode_fields_if_present");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					for(int i = 0; i < zipcodeFieldsIP.size(); i++){
						javaScripts.append(stringTool.replaceSubstring(rs.getString("value"),"FN",zipcodeFieldsIP.elementAt(i).toString()));
					}
				}						
			}
			
			if(passwordMatches.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"password_matches");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					String tempText;               //special case, it's presumed we will only ever ask for one password at a time.
					tempText = stringTool.replaceSubstring(rs.getString("value"),"FN1",passwordMatches.elementAt(0).toString());
					tempText = stringTool.replaceSubstring(tempText,"FN2",passwordMatches.elementAt(1).toString());
					javaScripts.append(tempText);
				}
			}	
			
			if(passwordMatchesIP.size() > 0){	
				selectValidation.clearParameters();
				selectValidation.setString(1,"password_matches_if_present");
				rs = selectValidation.executeQuery();
				if(rs.next()){
					String tempText;
					tempText = stringTool.replaceSubstring(rs.getString("value"),"FN1",passwordMatchesIP.elementAt(0).toString());
					tempText = stringTool.replaceSubstring(tempText,"FN2",passwordMatchesIP.elementAt(1).toString());
					javaScripts.append(tempText);
				}						
			}
			
	//**** temp till can figure out how to put in the db and use submstitution routines.
			if(thisOrThatFields.size() > 0){
				for(int i = 0; i < thisOrThatFields.size(); i++){
					javaScripts.append("if(document.forms[0].");
					javaScripts.append(thisOrThatFields.elementAt(i).toString());
					javaScripts.append(".value == \"\"){");			
				}	
			
				javaScripts.append("alert(\"Please Fill in information\");document.forms[0].");
				javaScripts.append(thisOrThatFields.elementAt(0));
				javaScripts.append(".focus();return;");
				
				for(int i = 0; i < thisOrThatFields.size(); i++){
					javaScripts.append("}");
				
				}	
			
			}	
			
		
			//add extra code for actions before submission
			javaScripts.append(extraCode);		
			
			//present submission message if there
			javaScripts.append("if(document.all(\"formSection\") != null && document.all(\"waitSection\") != null){");		
			javaScripts.append("formTarget = document.all(\"formSection\");waitTarget = document.all(\"waitSection\");");
			javaScripts.append("formTarget.style.display = \"none\";waitTarget.style.display = \"\";}");
				
				
			javaScripts.append("document.forms[0].submit();}</script>");
			
		} catch ( Exception e ) {
			throw new SQLException(e.getMessage());
		} finally {
			try {
				conn.close();
			}catch(Exception e) {
			}finally {
				conn = null;
			}
		}
	
		return javaScripts.toString();
	}
	public void setNumberFields(String[] temps){
		for(int i = 0; i < temps.length; i++){
			numberFields.addElement(temps[i]);
		}
	}
	public void setNumberFieldsIP(String[] temps){
		for(int i = 0; i < temps.length; i++){
			numberFieldsIP.addElement(temps[i]);
		}
	}
	public void setPasswordMatches(String[] temps){
		for(int i = 0; i < temps.length; i++){
			passwordMatches.addElement(temps[i]);
		}
	}
	public void setPasswordMatchesIP(String[] temps){
		for(int i = 0; i < temps.length; i++){
			passwordMatchesIP.addElement(temps[i]);
		}
	}
	public void setReqCheckBoxes(String[] temps){
		for(int i = 0; i < temps.length; i++){
			reqCheckBoxes.addElement(temps[i]);
		}
	}
	public void setReqCheckBoxesIP(String[] temps){
		for(int i = 0; i < temps.length; i++){
			reqCheckBoxesIP.addElement(temps[i]);
		}
	}
	public void setReqTextFields(String[] temps){
		for(int i = 0; i < temps.length; i++){
			reqTextFields.addElement(temps[i]);
		}
	}
	public void setReqTextFieldsIP(String[] temps){
		for(int i = 0; i < temps.length; i++){
			reqTextFieldsIP.addElement(temps[i]);
		}	
	}
	public void setThisOrThatFields(String[] temps){
		for(int i = 0; i < temps.length; i++){
			thisOrThatFields.addElement(temps[i]);
		}
	}
	public void setZipcodeFields(String[] temps){
		for(int i = 0; i < temps.length; i++){
			zipcodeFields.addElement(temps[i]);
		}
	}
	public void setZipcodeFieldsIP(String[] temps){
		for(int i = 0; i < temps.length; i++){
			zipcodeFieldsIP.addElement(temps[i]);
		}
	}
}
