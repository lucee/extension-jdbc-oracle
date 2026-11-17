component extends="org.lucee.cfml.test.LuceeTestCase" labels="oracle" {

	// LDEV-6911: 23.26.0.0-ojdbc11 shipped an OSGi bundle importing javax.transaction,
	// which Lucee 8.0/9.0 no longer provide, so the extension did not install there.
	// These specs need no database, so they also run when no Oracle datasource is configured.

	// keep in sync with pom.xml <version> and <mvnVersion>
	variables.extensionId = "D4EDFDBD-A9A3-E9AF-597322D767E0C949";
	variables.extensionVersion = "23.26.4.0.0-ojdbc11";
	variables.mavenDriver = "com.oracle.database.jdbc:ojdbc11:23.26.4.0.0";

	private numeric function luceeMajor() {
		return val( listFirst( server.lucee.version, "." ) );
	}

	function run( testResults, testBox ) {
		describe( title="LDEV-6911 Oracle JDBC extension install", body=function() {

			it( title="the extension is installed on this Lucee version", body=function( currentSpec ) {
				var installed = extensionList().filter( function( row ) {
					return row.id == variables.extensionId;
				} );
				systemOutput( "Lucee #server.lucee.version#, installed Oracle extension: " & serializeJSON( installed ), true );
				expect( installed.recordCount ).toBe( 1, "Oracle JDBC extension is not installed" );
				expect( installed.version[ 1 ] ).toBe( variables.extensionVersion );
			} );

			it(
				title="the driver loads from Maven, without needing javax.transaction",
				skip=( luceeMajor() < 7 ),
				body=function( currentSpec ) {
					var driver = createObject( "java", "oracle.jdbc.OracleDriver", { maven: [ variables.mavenDriver ] } );
					expect( driver.getMajorVersion() ).toBe( 23 );
					expect( driver.acceptsURL( "jdbc:oracle:thin:@localhost:1521:XE" ) ).toBeTrue();
				}
			);
		} );
	}

}
