<!--- 
 *
 * Copyright (c) 2014, the Railo Company Ltd. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either 
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public 
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 * 
 ---><cfcomponent extends="types.Driver" implements="types.IDatasource">
	
	<cfset fields=array()>
    
    <cfset fields=array(
		field("Driver Type","drivertype","thin,oci",true,"Oracle provides the following JDBC drivers:

    <ul>
	<li>
		Thin - It is a pure Java driver used on the client-side, without an Oracle client installation.
	</li>
    <li>
		OCI (Oracle Call Interface) - It is used on the client-side with an Oracle client installation.
	</li>
	</ul>","select")
	)>
    
    
	<cfset this.className="oracle.jdbc.OracleDriver">
	<cfset this.dsn="jdbc:oracle:{drivertype}:@{host}:{port}:{database}">
	<cfset this.dsnOld="jdbc:oracle:thin:@{host}:{port}:{database}">
	
	
	<cfset this.type.port=this.TYPE_FREE>
	<cfset this.value.host="localhost">
	<cfset this.value.port=1521>
	<cfset this.drivertype='thin'>
	
	<cffunction name="onBeforeError" returntype="void" output="no">
		<cfargument name="cfcatch" required="true" type="struct">
        <cfset var msg="can't find class [oracle.jdbc.driver.OracleDriver] for jdbc driver, check if driver (jar file) is inside lib folder">
		<cfif cfcatch.type EQ "java.lang.classnotfoundexception" or msg EQ cfcatch.message>
			<cfset cfcatch.message="cant find class ""oracle.jdbc.driver.OracleDriver"". To use this driver you must download jdbc driver at http://www.oracle.com/technology//software/tech/java/sqlj_jdbc, copy jar file downloaded to your classpath and restart lucee.">
            <cfset cfcatch.detail="">
		</cfif>
	</cffunction>
    
    
	<cffunction name="onBeforeUpdate" returntype="void" output="no">
        <cfset this.drivertype=form.custom_drivertype>
		<!---cfset StructDelete(form,'custom_drivertype')--->
	</cffunction>
    
	
	<cffunction name="getName" returntype="string" output="no"
		hint="returns display name of the driver">
		<cfreturn "Oracle 11g (Release 2)">
	</cffunction>
	
	<cffunction name="getDescription" returntype="string" output="no"
		hint="returns description for the driver">
		<cfreturn "Oracle Database Driver to access a Oracle Database System.">
	</cffunction>
	
	<cffunction name="getFields" returntype="array" output="no"
		hint="returns array of fields">
		<cfreturn fields>
	</cffunction>
	
	<cffunction name="equals" returntype="boolean" output="false"
		hint="return if String class match this">
		
		<cfargument name="className"	required="true">
		<cfargument name="dsn"			required="true">
		
		<cfreturn this.className EQ arguments.className and (this.dsn EQ arguments.dsn or this.dsnOld EQ arguments.dsn)>
	</cffunction>
	
</cfcomponent>