package com.marcomet.taglibs;

import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class PricingGridTEI extends TagExtraInfo {

	public final  VariableInfo[] getVariableInfo(TagData data) {

		VariableInfo[]  scriptVars = new VariableInfo[1];
		scriptVars[0] = new VariableInfo("gridExists", "java.lang.String", true, VariableInfo.AT_END);
		return scriptVars;

	}

}