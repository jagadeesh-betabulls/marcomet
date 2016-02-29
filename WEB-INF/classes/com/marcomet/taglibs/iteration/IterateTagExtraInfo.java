package com.marcomet.taglibs.iteration;
 
import java.util.Hashtable;
import javax.servlet.jsp.tagext.*;
 
public class IterateTagExtraInfo extends TagExtraInfo {
 
        static Hashtable types = new Hashtable();
        static {
                types.put("enum", "java.util.Enumeration");
                types.put("string", "java.lang.String");
                types.put("int", "java.lang.Integer");
                types.put("float", "java.lang.Float");
                types.put("double", "java.lang.Double");
                types.put("iterator", "java.util.Iterator");
        }
 
        public VariableInfo[] getVariableInfo(TagData data) {
 
                VariableInfo[] rc = new VariableInfo[1];
                rc[0] =  new VariableInfo(data.getId(), this.guessVariableType(data), true, VariableInfo.NESTED);
                return rc;
 
        }
 
        protected String guessVariableType(TagData data) {
 
                String type = (String)data.getAttribute("type");
                if (type != null) {
 
                        type = type.trim();
                        String rc = (String)types.get(type);
 
                        if (rc != null) {
                                return rc;
                        }
 
                        if (type.length() > 0) {
                                return type;
                        }
 
                }
 
                return "java.lang.Object";
 
        }
}
