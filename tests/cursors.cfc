component extends="org.lucee.cfml.test.LuceeTestCase" labels="oracle" {
	function run(){
		describe( title="check open cursors",  skip=doSkip(),body=function(){
			it(title="Checking oracle query to select current Date & time", body=function(){
				systemOutput("", true);
				var initial_cursor = checkCursors();
				systemOutput(initial_cursor, true);

				// do some stuff to reproduce the cursor problem

				var post_cursor = checkCursors();
				systemOutput(post_cursor, true);

				expect( initial_cursor.highest_open_cur ).toBe( post_cursor.highest_open_cur );
			});
		});
	}

	private query function checkCursors(){
		var ds = server.getDatasource("oracle");
		var sys_password =  server._getSystemPropOrEnvVars( "SYSTEM_PASSWORD", "ORACLE_" );
		if ( structCount( sys_password ) eq 0 )
			throw "missing env var: [ORACLE_SYSTEM_PASSWORD]";
		ds.password = sys_password.SYSTEM_PASSWORD;
		ds.username = "sys as sysdba";
		
		var cursors = queryExecute(
			"SELECT max(a.value) as highest_open_cur, p.value as max_open_cur 
			FROM 	v$sesstat a, v$statname b, v$parameter p 
			WHERE  	a.statistic## = b.statistic##
				and b.name = 'opened cursors current'
				and p.name= 'open_cursors' 
			group by p.value",
			{}, 
			{datasource=ds}
		);
		return cursors;
	}

	private boolean function doSkip() {
		return structCount(server.getDatasource("oracle"))==0;
	}
}
